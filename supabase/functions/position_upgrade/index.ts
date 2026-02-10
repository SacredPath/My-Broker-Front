import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { preflight, json, err } from "../_shared/http.ts";
import { requireUser, loadProfileSimple, requireNotFrozen } from "../_shared/auth.ts";
import { adminClient } from "../_shared/db.ts";
import { validateUSD } from "../_shared/money.ts";
import { writeAudit } from "../_shared/audit.ts";

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
    const { position_id, additional_amount_usd } = body;
    
    if (!position_id || !additional_amount_usd) {
      return err(req, 'MISSING_FIELDS', 400, 'position_id and additional_amount_usd are required');
    }
    
    // Validate additional amount
    const validatedAmount = validateUSD(additional_amount_usd);
    
    const supabase = adminClient();
    
    // Get position details
    const { data: position, error: positionError } = await supabase
      .from("positions")
      .select("*")
      .eq("id", position_id)
      .eq("user_id", user.id)
      .eq("status", "active")
      .single();
    
    if (positionError || !position) {
      return err(req, 'POSITION_NOT_FOUND', 404, 'Active position not found');
    }
    
    // Get tier details for validation
    const { data: tier } = await supabase
      .from("tiers")
      .select("max_amount_usd")
      .eq("id", position.tier_id)
      .single();
    
    // Check if new total would exceed tier max
    const newTotal = position.principal_usd + validatedAmount;
    if (tier && newTotal > tier.max_amount_usd) {
      return err(req, 'EXCEEDS_TIER_LIMIT', 400, 'Upgrade would exceed tier maximum');
    }
    
    // Check user balance (accept both USD and USDT)
    const { data: balances } = await supabase
      .from("wallet_balances")
      .select("available")
      .eq("user_id", user.id)
      .in("currency", ["USD", "USDT"])
      .single();
    
    if (!balances || balances.available < validatedAmount) {
      return err(req, 'INSUFFICIENT_BALANCE', 400, 'Insufficient USD balance');
    }
    
    // Calculate new daily ROI
    const newDailyRoi = (newTotal * position.daily_roi_pct) / 100;
    
    // Start transaction
    const { error: txError } = await supabase.rpc('upgrade_position', {
      p_position_id: position_id,
      p_additional_amount: validatedAmount,
      p_new_principal: newTotal,
      p_new_daily_roi: newDailyRoi
    });
    
    if (txError) {
      // Fallback to manual updates if RPC doesn't exist
      await supabase
        .from("positions")
        .update({
          principal_usd: newTotal,
          daily_roi_usd: newDailyRoi,
          upgraded_at: new Date().toISOString()
        })
        .eq("id", position_id);
      
      // Create ledger entry for upgrade
      await supabase
        .from("wallet_ledger")
        .insert({
          user_id: user.id,
          currency: "USD",
          amount: -validatedAmount,
          type: "position_upgrade",
          reference_id: position_id,
          created_at: new Date().toISOString()
        });
    }
    
    // Write audit
    await writeAudit({
      actor_user_id: user.id,
      actor_role: profile.role,
      action: "POSITION_UPGRADE",
      target_user_id: user.id,
      before: { principal_usd: position.principal_usd },
      after: { principal_usd: newTotal },
      reason: `Position ${position_id} upgraded by $${validatedAmount}`
    });

    return json(req, { 
      ok: true,
      data: {
        position_id,
        previous_principal: position.principal_usd,
        additional_amount: validatedAmount,
        new_principal: newTotal,
        new_daily_roi: newDailyRoi,
        upgraded_at: new Date().toISOString()
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
