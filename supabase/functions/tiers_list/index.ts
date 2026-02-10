import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { handleOptions, ok, fail } from "../_shared/http.ts";
import { requireUser } from "../_shared/auth.ts";
import { adminClient } from "../_shared/clients.ts";

serve(async (req: Request) => {
  // First line must be OPTIONS handling
  const pre = handleOptions(req); if (pre) return pre;

  try {
    // Auth required - validates JWT and loads profile
    const auth = await requireUser(req);
    
    // Check if auth failed
    if (!auth.ok) {
      return fail(auth.status, auth.body);
    }
    
    const { user, profile } = auth;
    
    // Check if user is frozen
    if (profile?.is_frozen) {
      return fail(403, { 
        ok: false, 
        error: "ACCOUNT_FROZEN", 
        detail: "Account is frozen" 
      });
    }
    
    const supabase = adminClient();
    
    // Get all tiers (read-only)
    const { data: tiers, error: tiersError } = await supabase
      .from("tiers")
      .select(`
        id,
        tier_name,
        min_amount_usd,
        max_amount_usd,
        maturity_days,
        daily_roi_pct,
        allocation,
        created_at,
        updated_at
      `)
      .order("id", { ascending: true });

    if (tiersError) {
      console.error('Tiers list error:', tiersError);
      return fail(500, { 
        ok: false, 
        error: "DATABASE_ERROR", 
        detail: "Failed to fetch tiers" 
      });
    }
    
    // Get user's current positions to determine current tier
    const { data: positions, error: positionsError } = await supabase
      .from("positions")
      .select(`
        tier_id,
        principal_usd,
        status,
        started_at,
        matures_at
      `)
      .eq("user_id", user.id)
      .eq("status", "active");

    if (positionsError) {
      console.error('User positions error:', positionsError);
      return fail(500, { 
        ok: false, 
        error: "DATABASE_ERROR", 
        detail: "Failed to fetch user positions" 
      });
    }
    
    // Get user's current balance from wallet_balances view
    const { data: balances, error: balancesError } = await supabase
      .from("wallet_balances")
      .select("currency, balance")
      .eq("user_id", user.id)
      .eq("currency", "USD");

    if (balancesError) {
      console.error('User balances error:', balancesError);
      return fail(500, { 
        ok: false, 
        error: "DATABASE_ERROR", 
        detail: "Failed to fetch user balances" 
      });
    }
    
    // Calculate user's total equity (available USD + invested USD)
    const availableBalanceUSD = (balances || []).reduce((sum, b) => sum + parseFloat(b.balance), 0);
    const investedUSD = (positions || []).reduce((sum, p) => sum + parseFloat(p.principal_usd), 0);
    const totalEquityUSD = availableBalanceUSD + investedUSD;
    
    // Determine user's current tier (highest tier among active positions)
    const activePositionTiers = (positions || []).map(p => p.tier_id);
    const currentTierId = activePositionTiers.length > 0 ? Math.max(...activePositionTiers) : null;
    
    // Enhance tiers with user-specific information
    const enhancedTiers = (tiers || []).map(tier => {
      const tierId = tier.id;
      const minAmount = parseFloat(tier.min_amount_usd);
      const maxAmount = parseFloat(tier.max_amount_usd);
      
      // Check if user is currently in this tier
      const isCurrentTier = currentTierId === tierId;
      
      // Check eligibility based on total equity
      const isEligible = totalEquityUSD >= minAmount && totalEquityUSD <= maxAmount;
      
      // Calculate shortfall or excess
      let shortfall = 0;
      let excess = 0;
      
      if (totalEquityUSD < minAmount) {
        shortfall = minAmount - totalEquityUSD;
      } else if (totalEquityUSD > maxAmount) {
        excess = totalEquityUSD - maxAmount;
      }
      
      // Count active positions in this tier
      const activePositionsInTier = (positions || []).filter(p => p.tier_id === tierId).length;
      
      return {
        id: tier.id,
        name: tier.tier_name,
        level: tier.id,
        min_balance_usd: minAmount,
        max_balance_usd: maxAmount,
        maturity_days: tier.maturity_days,
        daily_roi_percent: parseFloat(tier.daily_roi_pct),
        allocation: tier.allocation,
        
        // User-specific data
        is_current: isCurrentTier,
        is_eligible: isEligible,
        shortfall_usd: shortfall,
        excess_usd: excess,
        active_positions_count: activePositionsInTier,
        
        // Timestamps
        created_at: tier.created_at,
        updated_at: tier.updated_at
      };
    });
    
    // Sort by level (ascending)
    enhancedTiers.sort((a, b) => a.level - b.level);

    return ok({
      ok: true,
      user_id: user.id,
      
      // User's financial context
      user_equity_usd: totalEquityUSD,
      available_balance_usd: availableBalanceUSD,
      invested_usd: investedUSD,
      current_tier_id: currentTierId,
      
      // Enhanced tiers list
      tiers: enhancedTiers,
      
      // Summary
      total_tiers: enhancedTiers.length,
      eligible_tiers_count: enhancedTiers.filter(t => t.is_eligible).length,
      
      // Timestamp
      last_updated: new Date().toISOString()
    });

  } catch (error) {
    console.error('Tiers list error:', error);
    return fail(500, { 
      ok: false, 
      error: "SERVER_ERROR", 
      detail: "Internal server error" 
    });
  }
});
