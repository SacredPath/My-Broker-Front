import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { handleOptions, ok, fail } from "../_shared/http.ts";
import { requireUser } from "../_shared/auth.ts";

serve(async (req: Request) => {
  // First line must be OPTIONS handling
  const pre = handleOptions(req); if (pre) return pre;

  try {
    // Auth required
    const auth = await requireUser(req);
    if (!auth.ok) {
      return fail(auth.status, auth.body);
    }
    
    const { user, profile } = auth;
    
    // Check BO role (support/superadmin)
    if (!['support', 'superadmin'].includes(profile.role)) {
      return fail(403, { ok: false, error: "INSUFFICIENT_PERMISSIONS", detail: "BO role required" });
    }
    
    // Get environment variables safely inside handler
    const SUPABASE_URL = Deno.env.get("SUPABASE_URL");
    const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    
    if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
      return fail(500, { ok: false, error: "SERVER_MISCONFIG", detail: "Missing database configuration" });
    }
    
    // Create service client for DB operations
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
      auth: { persistSession: false }
    });
    
    // Parse and validate request body
    const body = await req.json();
    const { withdrawal_id, decision, reason } = body;
    
    // Validate required fields
    if (!withdrawal_id || !decision) {
      return fail(400, { ok: false, error: "MISSING_FIELDS", detail: "withdrawal_id and decision are required" });
    }
    
    // Validate decision
    const validDecisions = ['approve', 'reject'];
    if (!validDecisions.includes(decision)) {
      return fail(400, { ok: false, error: "INVALID_DECISION", detail: `decision must be one of: ${validDecisions.join(', ')}` });
    }
    
    // Load withdrawal
    const { data: withdrawal, error: withdrawalError } = await supabase
      .from('withdrawals')
      .select('*')
      .eq('id', withdrawal_id)
      .single();
    
    if (withdrawalError || !withdrawal) {
      return fail(404, { ok: false, error: "WITHDRAWAL_NOT_FOUND", detail: "Withdrawal not found" });
    }
    
    // Idempotent: if already final status, return ok
    const finalStatuses = ['approved', 'rejected'];
    if (finalStatuses.includes(withdrawal.status)) {
      return ok({
        ok: true,
        withdrawal_id,
        decision,
        new_status: withdrawal.status,
        note: "Withdrawal already decided"
      });
    }
    
    if (decision === 'approve') {
      // Approve withdrawal
      const { error: updateError } = await supabase
        .from('withdrawals')
        .update({ 
          status: 'approved',
          decided_at: new Date().toISOString(),
          decided_by: user.id
        })
        .eq('id', withdrawal_id)
        .eq('status', 'pending'); // Ensure still pending
      
      if (updateError) {
        return fail(500, { ok: false, error: "DB_ERROR", detail: "Failed to approve withdrawal" });
      }
      
    } else if (decision === 'reject') {
      // Reject withdrawal and reverse reserved debit
      const { error: updateError } = await supabase
        .from('withdrawals')
        .update({ 
          status: 'rejected',
          decided_at: new Date().toISOString(),
          decided_by: user.id,
          rejection_reason: reason || 'BO rejection'
        })
        .eq('id', withdrawal_id)
        .eq('status', 'pending'); // Ensure still pending
      
      if (updateError) {
        return fail(500, { ok: false, error: "DB_ERROR", detail: "Failed to reject withdrawal" });
      }
      
      // Reverse reserved debit via wallet_ledger credit with reason 'withdrawal' meta {reversal:true}
      const totalRefund = withdrawal.amount + (withdrawal.fee_amount || 0);
      
      const { error: refundError } = await supabase
        .from('wallet_ledger')
        .insert({
          user_id: withdrawal.user_id,
          currency: withdrawal.currency,
          amount: totalRefund,
          reason: 'withdrawal',
          ref_table: 'withdrawals',
          ref_id: withdrawal.id,
          meta: { reversal: true },
          created_at: new Date().toISOString()
        });
      
      if (refundError) {
        return fail(500, { ok: false, error: "DB_ERROR", detail: "Failed to refund withdrawal" });
      }
    }
    
    // Write audit_log
    await supabase
      .from('audit_log')
      .insert({
        actor_user_id: user.id,
        actor_role: profile.role,
        action: `WITHDRAW_${decision.toUpperCase()}`,
        target_user_id: withdrawal.user_id,
        before: { status: withdrawal.status },
        after: { status: decision === 'approve' ? 'approved' : 'rejected' },
        reason: `BO ${decision} of withdrawal ${withdrawal_id}${reason ? ': ' + reason : ''}`,
        created_at: new Date().toISOString()
      });
    
    // Load updated withdrawal
    const { data: updatedWithdrawal } = await supabase
      .from('withdrawals')
      .select('*')
      .eq('id', withdrawal_id)
      .single();
    
    return ok({
      ok: true,
      withdrawal_id,
      decision,
      new_status: updatedWithdrawal.status,
      decided_at: updatedWithdrawal.decided_at,
      decided_by: user.id
    });

  } catch (error) {
    return fail(500, { ok: false, error: "SERVER_ERROR", detail: String(error) });
  }
});
