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
    const { deposit_id, actual_amount } = body;
    
    // Validate required fields
    if (!deposit_id) {
      return fail(400, { ok: false, error: "MISSING_FIELDS", detail: "deposit_id is required" });
    }
    
    // Load deposit
    const { data: deposit, error: depositError } = await supabase
      .from('deposits')
      .select('*')
      .eq('id', deposit_id)
      .single();
    
    if (depositError || !deposit) {
      return fail(404, { ok: false, error: "DEPOSIT_NOT_FOUND", detail: "Deposit not found" });
    }
    
    // Idempotent: if already confirmed, do nothing and return ok
    if (deposit.status === 'confirmed') {
      return ok({
        ok: true,
        deposit_id,
        status: deposit.status,
        note: "Deposit already confirmed"
      });
    }
    
    // Must be pending to confirm
    if (deposit.status !== 'pending') {
      return fail(400, { ok: false, error: "INVALID_STATUS", detail: "Deposit must be pending to confirm" });
    }
    
    // Set deposit status confirmed, confirmed_at=now()
    const { error: updateError } = await supabase
      .from('deposits')
      .update({ 
        status: 'confirmed',
        confirmed_at: new Date().toISOString(),
        confirmed_by: user.id,
        actual_amount: actual_amount || deposit.expected_amount
      })
      .eq('id', deposit_id)
      .eq('status', 'pending'); // Ensure still pending
    
    if (updateError) {
      return fail(500, { ok: false, error: "DB_ERROR", detail: "Failed to confirm deposit" });
    }
    
    // Write wallet_ledger credit:
    const creditAmount = actual_amount || deposit.expected_amount;
    
    const { error: ledgerError } = await supabase
      .from('wallet_ledger')
      .insert({
        user_id: deposit.user_id,
        currency: deposit.currency,
        amount: creditAmount,
        reason: 'deposit',
        ref_table: 'deposits',
        ref_id: deposit.id,
        created_at: new Date().toISOString()
      });
    
    if (ledgerError) {
      return fail(500, { ok: false, error: "DB_ERROR", detail: "Failed to create ledger entry" });
    }
    
    // Write audit_log row
    await supabase
      .from('audit_log')
      .insert({
        actor_user_id: user.id,
        actor_role: profile.role,
        action: 'DEPOSIT_CONFIRM',
        target_user_id: deposit.user_id,
        before: { status: 'pending', amount: deposit.expected_amount },
        after: { status: 'confirmed', amount: creditAmount },
        reason: `Manual confirmation of deposit ${deposit_id}`,
        created_at: new Date().toISOString()
      });
    
    return ok({
      ok: true,
      deposit_id,
      status: 'confirmed',
      confirmed_amount: creditAmount,
      currency: deposit.currency
    });

  } catch (error) {
    return fail(500, { ok: false, error: "SERVER_ERROR", detail: String(error) });
  }
});
