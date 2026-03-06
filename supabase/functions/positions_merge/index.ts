import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { preflight, json, err } from "../_shared/http.ts";
import { requireUser, loadProfileSimple, requireNotFrozen } from "../_shared/auth.ts";
import { adminClient } from "../_shared/db.ts";
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
    const { position_ids, target_tier_id } = body;
    
    if (!position_ids || !Array.isArray(position_ids) || position_ids.length < 2) {
      return err(req, 'INVALID_POSITIONS', 400, 'At least 2 position IDs required');
    }
    
    if (!target_tier_id) {
      return err(req, 'MISSING_TIER', 400, 'target_tier_id is required');
    }
    
    const supabase = adminClient();
    
    // Get all positions to merge
    const { data: positions, error: positionsError } = await supabase
      .from("positions")
      .select("*")
      .eq("user_id", user.id)
      .eq("status", "active")
      .in("id", position_ids);
    
    if (positionsError || !positions || positions.length !== position_ids.length) {
      return err(req, 'POSITIONS_NOT_FOUND', 404, 'One or more active positions not found');
    }
    
    // Get target tier
    const { data: targetTier, error: tierError } = await supabase
      .from("tiers")
      .select("*")
      .eq("id", target_tier_id)
      .single();
    
    if (tierError || !targetTier) {
      return err(req, 'TIER_NOT_FOUND', 404, 'Target tier not found');
    }
    
    // Calculate merged values
    const totalPrincipal = positions.reduce((sum, p) => sum + (p.principal_usd || 0), 0);
    const totalRoi = positions.reduce((sum, p) => sum + (p.accrued_roi_usd || 0), 0);
    
    // Check if merged amount fits target tier
    if (totalPrincipal < targetTier.min_amount_usd || totalPrincipal > targetTier.max_amount_usd) {
      return err(req, 'INVALID_MERGE_AMOUNT', 400, 'Merged amount outside target tier limits');
    }
    
    // Calculate new daily ROI for merged position
    const newDailyRoi = (totalPrincipal * targetTier.daily_roi_pct) / 100;
    
    // Start transaction
    const { error: txError } = await supabase.rpc('merge_positions', {
      p_user_id: user.id,
      p_position_ids: position_ids,
      p_target_tier_id: target_tier_id,
      p_new_principal: totalPrincipal,
      p_new_daily_roi: newDailyRoi,
      p_preserved_roi: totalRoi
    });
    
    if (txError) {
      // Fallback to manual updates if RPC doesn't exist
      // Mark old positions as merged
      await supabase
        .from("positions")
        .update({
          status: "merged",
          merged_into: null, // Will be set after creating new position
          merged_at: new Date().toISOString()
        })
        .in("id", position_ids);
      
      // Create new merged position
      const { data: newPosition } = await supabase
        .from("positions")
        .insert({
          user_id: user.id,
          tier_id: target_tier_id,
          principal_usd: totalPrincipal,
          accrued_roi_usd: totalRoi,
          daily_roi_usd: newDailyRoi,
          daily_roi_pct: targetTier.daily_roi_pct,
          status: "active",
          created_at: new Date().toISOString()
        })
        .select()
        .single();
      
      // Update old positions with reference to new position
      await supabase
        .from("positions")
        .update({ merged_into: newPosition.id })
        .in("id", position_ids);
    }
    
    // Write audit
    await writeAudit({
      actor_user_id: user.id,
      actor_role: profile.role,
      action: "POSITIONS_MERGE",
      target_user_id: user.id,
      before: { positions_merged: position_ids },
      after: { 
        new_principal: totalPrincipal,
        new_tier: target_tier_id,
        preserved_roi: totalRoi
      },
      reason: `Merged ${position_ids.length} positions into tier ${targetTier.tier_name}`
    });

    return json(req, { 
      ok: true,
      data: {
        merged_positions: position_ids,
        new_position: {
          tier_id: target_tier_id,
          tier_name: targetTier.tier_name,
          principal_usd: totalPrincipal,
          accrued_roi_usd: totalRoi,
          daily_roi_usd: newDailyRoi,
          daily_roi_pct: targetTier.daily_roi_pct
        },
        merged_at: new Date().toISOString()
      }
    });
  } catch (error: any) {
    if (error.message?.includes('authorization')) {
      return err(req, 'UNAUTHENTICATED', 401, 'Authentication required');
    }
    if (error.message?.includes('frozen')) {
      return err(req, 'ACCOUNT_FROZEN', 403, 'Account is frozen');
    }
    if (error.message === 'Profile not found') {
      return err(req, 'PROFILE_NOT_FOUND', 404, 'Profile not found');
    }
    return err(req, 'SERVER_ERROR', 500, String(error));
  }
});
