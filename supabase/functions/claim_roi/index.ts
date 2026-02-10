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
    const { position_id } = body;
    
    if (!position_id) {
      return err(req, 'MISSING_POSITION_ID', 400, 'position_id is required');
    }
    
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
    
    // Check if there's ROI to claim
    if (!position.accrued_roi_usd || position.accrued_roi_usd <= 0) {
      return err(req, 'NO_ROI_TO_CLAIM', 400, 'No ROI available to claim');
    }
    
    const roiAmount = position.accrued_roi_usd;
    
    // Start transaction
    const { error: txError } = await supabase.rpc('claim_roi', {
      p_position_id: position_id,
      p_roi_amount: roiAmount
    });
    
    if (txError) {
      // Fallback to manual updates if RPC doesn't exist
      // Reset ROI on position
      await supabase
        .from("positions")
        .update({
          accrued_roi_usd: 0,
          last_accrued_at: new Date().toISOString()
        })
        .eq("id", position_id);
      
      // Add ROI to user balance (create ledger entry)
      await supabase
        .from("wallet_ledger")
        .insert({
          user_id: user.id,
          currency: "USD",
          amount: roiAmount,
          type: "roi_claim",
          reference_id: position_id,
          created_at: new Date().toISOString()
        });
    }
    
    // Write audit
    await writeAudit({
      actor_user_id: user.id,
      actor_role: profile.role,
      action: "ROI_CLAIM",
      target_user_id: user.id,
      before: { accrued_roi_usd: roiAmount },
      after: { accrued_roi_usd: 0 },
      reason: `ROI claimed from position ${position_id}`
    });

    return json(req, { 
      ok: true,
      data: {
        position_id,
        roi_claimed: roiAmount,
        claimed_at: new Date().toISOString()
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
