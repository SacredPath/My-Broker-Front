import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { preflight, json, err } from "../_shared/http.ts";
import { requireUser, loadProfileSimple, requireRole } from "../_shared/auth.ts";
import { adminClient } from "../_shared/db.ts";

serve(async (req: Request) => {
  const pre = preflight(req);
  if (pre) return pre;

  try {
    // Auth required
    const { user } = await requireUser(req);
    
    // Load profile and check BO permissions
    const profile = await loadProfileSimple(user.id);
    requireRole(profile, ['support', 'superadmin']);
    
    // Parse target user_id from query
    const url = new URL(req.url);
    const targetUserId = url.searchParams.get('user_id');
    
    if (!targetUserId) {
      return err(req, 'MISSING_USER_ID', 400, 'user_id query parameter required');
    }
    
    const supabase = adminClient();
    
    // Get target user profile
    const { data: targetProfile, error: profileError } = await supabase
      .from("profiles")
      .select("*")
      .eq("user_id", targetUserId)
      .single();
    
    if (profileError || !targetProfile) {
      return err(req, 'USER_NOT_FOUND', 404, 'Target user not found');
    }
    
    // Get balances
    const { data: balances } = await supabase
      .from("wallet_balances")
      .select("*")
      .eq("user_id", targetUserId);
    
    // Get recent activity (last 50 each)
    const [positions, deposits, withdrawals, ledger] = await Promise.all([
      supabase.from("positions").select("*").eq("user_id", targetUserId).order("created_at", { ascending: false }).limit(50),
      supabase.from("deposits").select("*").eq("user_id", targetUserId).order("created_at", { ascending: false }).limit(50),
      supabase.from("withdrawals").select("*").eq("user_id", targetUserId).order("created_at", { ascending: false }).limit(50),
      supabase.from("wallet_ledger").select("*").eq("user_id", targetUserId).order("created_at", { ascending: false }).limit(50)
    ]);

    return json(req, { 
      ok: true,
      data: {
        profile: targetProfile,
        balances: balances || [],
        recent_activity: {
          positions: positions.data || [],
          deposits: deposits.data || [],
          withdrawals: withdrawals.data || [],
          ledger: ledger.data || []
        }
      }
    });
  } catch (error: any) {
    if (error.message?.includes('authorization')) {
      return err(req, 'UNAUTHENTICATED', 401, 'Authentication required');
    }
    if (error.message?.includes('permissions')) {
      return err(req, 'INSUFFICIENT_PERMISSIONS', 403, 'BO access required');
    }
    return err(req, 'SERVER_ERROR', 500, String(error));
  }
});
