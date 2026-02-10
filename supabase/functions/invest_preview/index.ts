import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { preflight, json, err } from "../_shared/http.ts";
import { requireUser, loadProfileSimple, requireNotFrozen } from "../_shared/auth.ts";
import { adminClient } from "../_shared/db.ts";
import { validateUSD } from "../_shared/money.ts";

serve(async (req: Request) => {
  const pre = preflight(req);
  if (pre) return pre;

  try {
    // Auth required
    const { user } = await requireUser(req);
    
    // Load profile and check not frozen
    const profile = await loadProfileSimple(user.id);
    requireNotFrozen(profile);
    
    // Parse request body
    const body = await req.json();
    const { amount_usd, tier_id } = body;
    
    if (!amount_usd || !tier_id) {
      return err(req, 'MISSING_FIELDS', 400, 'amount_usd and tier_id are required');
    }
    
    // Validate amount
    const validatedAmount = validateUSD(amount_usd);
    
    const supabase = adminClient();
    
    // Get tier details
    const { data: tier, error: tierError } = await supabase
      .from("tiers")
      .select("*")
      .eq("id", tier_id)
      .single();
    
    if (tierError || !tier) {
      return err(req, 'TIER_NOT_FOUND', 404, 'Tier not found');
    }
    
    // Check if amount is within tier limits
    if (validatedAmount < tier.min_amount_usd || validatedAmount > tier.max_amount_usd) {
      return err(req, 'INVALID_AMOUNT', 400, `Amount must be between $${tier.min_amount_usd} and $${tier.max_amount_usd}`);
    }
    
    // Check user balance
    const { data: balances } = await supabase
      .from("wallet_balances")
      .select("available")
      .eq("user_id", user.id)
      .eq("currency", "USD")
      .single();
    
    if (!balances || balances.available < validatedAmount) {
      return err(req, 'INSUFFICIENT_BALANCE', 400, 'Insufficient USD balance');
    }
    
    // Calculate investment preview
    const daily_roi = (validatedAmount * tier.daily_roi_pct) / 100;
    const total_roi = daily_roi * tier.maturity_days;
    const matured_amount = validatedAmount + total_roi;
    
    return json(req, { 
      ok: true,
      data: {
        tier: {
          id: tier.id,
          name: tier.tier_name,
          daily_roi_pct: tier.daily_roi_pct,
          maturity_days: tier.maturity_days
        },
        investment: {
          principal_usd: validatedAmount,
          daily_roi_usd: daily_roi,
          total_roi_usd: total_roi,
          matured_amount_usd: matured_amount,
          maturity_date: new Date(Date.now() + tier.maturity_days * 24 * 60 * 60 * 1000).toISOString()
        },
        balance_after: {
          available_usd: balances.available - validatedAmount
        }
      }
    });
  } catch (error: any) {
    if (error.message?.includes('authorization')) {
      return err(req, 'UNAUTHENTICATED', 401, 'Authentication required');
    }
    if (error.message?.includes('frozen')) {
      return err(req, 'ACCOUNT_FROZEN', 403, 'Account is frozen');
    }
    if (error.message?.includes('Invalid USD amount')) {
      return err(req, 'INVALID_AMOUNT', 400, 'Invalid USD amount');
    }
    if (error.message === 'Profile not found') {
      return err(req, 'PROFILE_NOT_FOUND', 404, 'Profile not found');
    }
    return err(req, 'SERVER_ERROR', 500, String(error));
  }
});
