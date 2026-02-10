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
    
    // Get positions with tier information
    const { data: positions, error: positionsError } = await supabase
      .from("positions")
      .select(`
        id,
        tier_id,
        principal_usd,
        started_at,
        matures_at,
        last_accrued_at,
        accrued_roi_usd,
        status,
        auto_reinvest_claimed_roi,
        created_at,
        updated_at,
        tiers!inner (
          tier_name,
          daily_roi_pct,
          maturity_days,
          allocation
        )
      `)
      .eq("user_id", user.id)
      .order("created_at", { ascending: false });

    if (positionsError) {
      console.error('Positions list error:', positionsError);
      return fail(500, { 
        ok: false, 
        error: "DATABASE_ERROR", 
        detail: "Failed to fetch positions" 
      });
    }
    
    // Get current UTC time for calculations
    const now = new Date();
    const nowUTC = now.toISOString();
    
    // Enhance positions with calculated values
    const enhancedPositions = (positions || []).map(position => {
      const principal = parseFloat(position.principal_usd) || 0;
      const accruedRoi = parseFloat(position.accrued_roi_usd) || 0;
      const tier = position.tiers as any;
      const dailyRoiRate = parseFloat(tier.daily_roi_pct) / 100;
      
      // Calculate time-based values
      const startedAt = new Date(position.started_at);
      const maturesAt = new Date(position.matures_at);
      const lastAccruedAt = new Date(position.last_accrued_at);
      
      // Calculate total potential ROI (if held to maturity)
      const maturityDays = parseInt(tier.maturity_days);
      const totalPotentialRoi = principal * dailyRoiRate * maturityDays;
      
      // Calculate remaining time to maturity
      const timeToMaturityMs = maturesAt.getTime() - now.getTime();
      const daysToMaturity = Math.max(0, Math.ceil(timeToMaturityMs / (24 * 60 * 60 * 1000)));
      
      // Calculate progress percentage
      const totalDurationMs = maturesAt.getTime() - startedAt.getTime();
      const elapsedMs = now.getTime() - startedAt.getTime();
      const progressPercent = Math.min(100, Math.max(0, (elapsedMs / totalDurationMs) * 100));
      
      // Calculate current total value (principal + accrued ROI)
      const currentValueUSD = principal + accruedRoi;
      
      // Calculate ROI percentage
      const roiPercent = principal > 0 ? (accruedRoi / principal) * 100 : 0;
      
      // Determine if position can claim ROI
      const canClaimRoi = position.status === 'active' && accruedRoi > 0;
      
      // Calculate daily accrual amount
      const dailyAccrualUSD = principal * dailyRoiRate;
      
      return {
        id: position.id,
        
        // Basic position info
        tier_id: position.tier_id,
        tier_name: tier.tier_name,
        principal_usd: principal,
        status: position.status,
        
        // ROI calculations (server-side only)
        accrued_roi_usd: accruedRoi,
        roi_percent: roiPercent,
        daily_roi_percent: parseFloat(tier.daily_roi_pct),
        daily_accrual_usd: dailyAccrualUSD,
        total_potential_roi_usd: totalPotentialRoi,
        
        // Current value
        current_value_usd: currentValueUSD,
        
        // Timing information
        started_at: position.started_at,
        matures_at: position.matures_at,
        last_accrued_at: position.last_accrued_at,
        days_to_maturity: daysToMaturity,
        progress_percent: progressPercent,
        
        // User options
        can_claim_roi: canClaimRoi,
        auto_reinvest_claimed_roi: position.auto_reinvest_claimed_roi,
        
        // Tier allocation
        allocation: tier.allocation,
        
        // Timestamps
        created_at: position.created_at,
        updated_at: position.updated_at
      };
    });
    
    // Calculate summary statistics
    const summary = enhancedPositions.reduce((acc, pos) => {
      if (pos.status === 'active') {
        acc.active_count++;
        acc.active_principal += pos.principal_usd;
        acc.active_accrued_roi += pos.accrued_roi_usd;
        acc.active_current_value += pos.current_value_usd;
      } else if (pos.status === 'matured') {
        acc.matured_count++;
        acc.matured_principal += pos.principal_usd;
        acc.matured_accrued_roi += pos.accrued_roi_usd;
        acc.matured_current_value += pos.current_value_usd;
      }
      
      acc.total_positions++;
      acc.total_principal += pos.principal_usd;
      acc.total_accrued_roi += pos.accrued_roi_usd;
      acc.total_current_value += pos.current_value_usd;
      
      return acc;
    }, {
      total_positions: 0,
      total_principal: 0,
      total_accrued_roi: 0,
      total_current_value: 0,
      active_count: 0,
      active_principal: 0,
      active_accrued_roi: 0,
      active_current_value: 0,
      matured_count: 0,
      matured_principal: 0,
      matured_accrued_roi: 0,
      matured_current_value: 0
    });
    
    // Calculate overall ROI percentage
    const overallRoiPercent = summary.total_principal > 0 
      ? (summary.total_accrued_roi / summary.total_principal) * 100 
      : 0;

    return ok({
      ok: true,
      user_id: user.id,
      
      // Enhanced positions list
      positions: enhancedPositions,
      
      // Summary statistics
      summary: {
        total_positions: summary.total_positions,
        total_principal_usd: summary.total_principal,
        total_accrued_roi_usd: summary.total_accrued_roi,
        total_current_value_usd: summary.total_current_value,
        overall_roi_percent: overallRoiPercent,
        
        active: {
          count: summary.active_count,
          principal_usd: summary.active_principal,
          accrued_roi_usd: summary.active_accrued_roi,
          current_value_usd: summary.active_current_value
        },
        
        matured: {
          count: summary.matured_count,
          principal_usd: summary.matured_principal,
          accrued_roi_usd: summary.matured_accrued_roi,
          current_value_usd: summary.matured_current_value
        }
      },
      
      // User context
      is_growth_paused: profile?.is_growth_paused || false,
      
      // Timestamp
      last_updated: new Date().toISOString()
    });

  } catch (error) {
    console.error('Positions list error:', error);
    return fail(500, { 
      ok: false, 
      error: "SERVER_ERROR", 
      detail: "Internal server error" 
    });
  }
});
