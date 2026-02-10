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
    
    // Get current UTC date for today's calculations
    const today = new Date().toISOString().split('T')[0];
    const todayStart = new Date(`${today}T00:00:00.000Z`).toISOString();
    
    // Get balances from wallet_balances view (single source of truth)
    const { data: balances, error: balancesError } = await supabase
      .from("wallet_balances")
      .select("currency, balance")
      .eq("user_id", user.id);

    if (balancesError) {
      console.error('Dashboard balances error:', balancesError);
      return fail(500, { 
        ok: false, 
        error: "DATABASE_ERROR", 
        detail: "Failed to fetch balances" 
      });
    }
    
    // Get positions with ROI calculations
    const { data: positions, error: positionsError } = await supabase
      .from("positions")
      .select(`
        id,
        principal_usd,
        accrued_roi_usd,
        status,
        started_at,
        matures_at,
        last_accrued_at,
        tier_id,
        tiers!inner (
          tier_name,
          daily_roi_pct,
          maturity_days
        )
      `)
      .eq("user_id", user.id)
      .in("status", ["active", "matured"]);

    if (positionsError) {
      console.error('Dashboard positions error:', positionsError);
      return fail(500, { 
        ok: false, 
        error: "DATABASE_ERROR", 
        detail: "Failed to fetch positions" 
      });
    }
    
    // Get pending transactions counts
    const [pendingDeposits, pendingWithdrawals] = await Promise.all([
      supabase
        .from("deposits")
        .select("id")
        .eq("user_id", user.id)
        .eq("status", "pending"),
      
      supabase
        .from("withdrawals")
        .select("id")
        .eq("user_id", user.id)
        .eq("status", "pending")
    ]);
    
    // Calculate balances map
    const balancesMap = (balances || []).reduce((acc, b) => {
      acc[b.currency] = parseFloat(b.balance) || 0;
      return acc;
    }, {} as Record<string, number>);
    
    // Calculate positions summary and today's growth
    const positionsSummary = (positions || []).reduce((acc, pos) => {
      const principal = parseFloat(pos.principal_usd) || 0;
      const accruedRoi = parseFloat(pos.accrued_roi_usd) || 0;
      
      acc.totalPrincipal += principal;
      acc.totalRoi += accruedRoi;
      acc.activeCount += pos.status === 'active' ? 1 : 0;
      
      // Calculate today's growth (ROI accrued since 00:00 UTC)
      if (pos.status === 'active' && pos.last_accrued_at) {
        const lastAccrued = new Date(pos.last_accrued_at);
        const todayStartUTC = new Date(todayStart);
        
        if (lastAccrued >= todayStartUTC) {
          // Simple approximation: assume linear accrual throughout the day
          const tier = pos.tiers as any;
          const dailyRoiRate = parseFloat(tier.daily_roi_pct) / 100;
          const dailyRoiAmount = principal * dailyRoiRate;
          
          // Calculate proportion of day's ROI that was accrued today
          const dayProgress = Math.min(
            (lastAccrued.getTime() - todayStartUTC.getTime()) / (24 * 60 * 60 * 1000),
            1
          );
          
          acc.todayGrowth += dailyRoiAmount * dayProgress;
        }
      }
      
      return acc;
    }, { 
      totalPrincipal: 0, 
      totalRoi: 0, 
      activeCount: 0, 
      todayGrowth: 0 
    });
    
    // Calculate totals
    const availableBalanceUSD = balancesMap.USD || 0;
    const availableBalanceUSDT = balancesMap.USDT || 0;
    const totalEquityUSD = availableBalanceUSD + positionsSummary.totalPrincipal + positionsSummary.totalRoi;
    
    // Calculate ROI percentages
    const totalInvestedUSD = positionsSummary.totalPrincipal;
    const totalRoiUSD = positionsSummary.totalRoi;
    const todayGrowthUSD = positionsSummary.todayGrowth;
    
    const totalRoiPercent = totalInvestedUSD > 0 ? (totalRoiUSD / totalInvestedUSD) * 100 : 0;
    const todayGrowthPercent = totalInvestedUSD > 0 ? (todayGrowthUSD / totalInvestedUSD) * 100 : 0;

    return ok({
      ok: true,
      user_id: user.id,
      
      // Balances (single source of truth)
      total_balance_usd: totalEquityUSD,
      available_balance_usd: availableBalanceUSD,
      available_balance_usdt: availableBalanceUSDT,
      total_equity_usd: totalEquityUSD,
      
      // Investment summary
      invested_usd: totalInvestedUSD,
      active_positions_count: positionsSummary.activeCount,
      
      // ROI calculations (server-side only)
      today_pnl_usd: todayGrowthUSD,
      today_pnl_percent: todayGrowthPercent,
      total_pnl_usd: totalRoiUSD,
      total_pnl_percent: totalRoiPercent,
      
      // Pending transactions
      pending_deposits_count: pendingDeposits.data?.length || 0,
      pending_withdrawals_count: pendingWithdrawals.data?.length || 0,
      
      // User status
      kyc_status: profile?.kyc_status || 'not_submitted',
      email_verified: profile?.email_verified || false,
      is_growth_paused: profile?.is_growth_paused || false,
      
      // Timestamp
      last_updated: new Date().toISOString()
    });

  } catch (error) {
    console.error('Dashboard summary error:', error);
    return fail(500, { 
      ok: false, 
      error: "SERVER_ERROR", 
      detail: "Internal server error" 
    });
  }
});
