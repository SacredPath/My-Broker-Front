import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { handleOptions } from "../_shared/cors.ts";
import { ok, fail } from "../_shared/respond.ts";
import { requireUser, loadProfile, requireBO } from "../_shared/auth.ts";
import { adminClient } from "../_shared/auth.ts";
import { writeAudit } from "../_shared/audit.ts";

serve(async (req: Request) => {
  const pre = handleOptions(req);
  if (pre) return pre;

  try {
    // Auth required
    const { user } = await requireUser(req);
    
    // Load profile and check BO permissions
    const profile = await loadProfile(user.id);
    requireBO(profile);
    
    // Parse and validate request body
    const body = await req.json();
    const { deposit_id, decision, reason, tx_hash, actual_amount } = body;
    
    // Validate required fields
    if (!deposit_id || !decision) {
      return fail(400, "MISSING_FIELDS", "deposit_id and decision are required", undefined, req);
    }
    
    // Validate decision
    const validDecisions = ['confirm', 'reject'];
    if (!validDecisions.includes(decision)) {
      return fail(400, "INVALID_DECISION", `decision must be one of: ${validDecisions.join(', ')}`, undefined, req);
    }
    
    const supabase = adminClient();
    
    // Load deposit
    const { data: deposit, error: depositError } = await supabase
      .from('deposits')
      .select('*')
      .eq('id', deposit_id)
      .single();
    
    if (depositError || !deposit) {
      return fail(404, "DEPOSIT_NOT_FOUND", "Deposit not found", undefined, req);
    }
    
    // Idempotent: if not pending, return existing state
    if (deposit.status !== 'pending') {
      return ok({
        deposit_id,
        decision: deposit.status === 'confirmed' ? 'confirm' : 'reject',
        new_status: deposit.status,
        actual_amount: deposit.actual_amount,
        note: "Deposit already decided"
      }, req);
    }
    
    // Store before state for audit
    const beforeState = { status: deposit.status, expected_amount: deposit.expected_amount };
    
    if (decision === 'confirm') {
      // Confirm deposit with idempotent update
      const updateData: any = {
        status: 'confirmed',
        confirmed_at: new Date().toISOString(),
        confirmed_by: user.id
      };
      
      if (tx_hash) {
        updateData.tx_hash = tx_hash;
      }
      
      if (actual_amount) {
        updateData.actual_amount = actual_amount;
      }
      
      const { error: updateError, count } = await supabase
        .from('deposits')
        .update(updateData)
        .eq('id', deposit_id)
        .eq('status', 'pending'); // Ensure still pending
      
      if (updateError || count === 0) {
        return fail(500, "DB_ERROR", "Failed to confirm deposit", undefined, req);
      }
      
      // Create wallet ledger credit entry
      const creditAmount = actual_amount || deposit.expected_amount;
      
      const { error: ledgerError } = await supabase
        .from('wallet_ledger')
        .insert({
          user_id: deposit.user_id,
          currency: deposit.currency,
          amount: Number(creditAmount),
          type: 'deposit',
          reference_id: deposit.id,
          created_at: new Date().toISOString()
        });
      
      if (ledgerError) {
        return fail(500, "DB_ERROR", "Failed to create ledger entry", undefined, req);
      }
      
    } else {
      // Reject deposit with idempotent update
      const { error: rejectError, count } = await supabase
        .from('deposits')
        .update({ 
          status: 'rejected',
          rejected_at: new Date().toISOString(),
          rejected_by: user.id,
          rejection_reason: reason || 'Manual rejection'
        })
        .eq('id', deposit_id)
        .eq('status', 'pending'); // Ensure still pending
      
      if (rejectError || count === 0) {
        return fail(500, "DB_ERROR", "Failed to reject deposit", undefined, req);
      }
    }
    
    // Load after state for audit
    const { data: updatedDeposit } = await supabase
      .from('deposits')
      .select('*')
      .eq('id', deposit_id)
      .single();
    
    // Write audit log
    await writeAudit({
      actor_user_id: user.id,
      actor_role: profile.role,
      action: decision === 'confirm' ? 'DEPOSIT_CONFIRM' : 'DEPOSIT_REJECT',
      target_user_id: deposit.user_id,
      before: beforeState,
      after: { 
        status: updatedDeposit.status,
        actual_amount: updatedDeposit.actual_amount,
        confirmed_by: user.id
      },
      reason: `Manual ${decision} of deposit ${deposit_id}${reason ? ': ' + reason : ''}`
    });
    
    // Get current wallet balances for user
    const { data: balances } = await supabase
      .from('wallet_balances')
      .select('*')
      .eq('user_id', deposit.user_id);
    
    return ok({
      deposit_id,
      decision,
      new_status: updatedDeposit.status,
      actual_amount: updatedDeposit.actual_amount,
      wallet_balances: balances
    }, req);

  } catch (error: any) {
    if (error instanceof Response) return error;
    return fail(500, "SERVER_ERROR", String(error), undefined, req);
  }
});
