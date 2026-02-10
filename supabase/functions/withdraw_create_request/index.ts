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
    
    const { user } = auth;
    
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
    const { currency, amount, method_id } = body;
    
    // Validate required fields
    if (!currency || !amount || !method_id) {
      return fail(400, { ok: false, error: "MISSING_FIELDS", detail: "currency, amount, and method_id are required" });
    }
    
    // Validate enum values
    const validCurrencies = ['USD', 'USDT'];
    if (!validCurrencies.includes(currency)) {
      return fail(400, { ok: false, error: "INVALID_CURRENCY", detail: `currency must be one of: ${validCurrencies.join(', ')}` });
    }
    
    // Validate amount
    const withdrawalAmount = parseFloat(amount);
    if (isNaN(withdrawalAmount) || withdrawalAmount <= 0) {
      return fail(400, { ok: false, error: "INVALID_AMOUNT", detail: "Amount must be a positive number" });
    }
    
    // Validate method exists in withdrawal_methods for the user
    const { data: method } = await supabase
      .from('withdrawal_methods')
      .select('id,method')
      .eq('user_id', user.id)
      .eq('id', method_id)
      .single();
    
    if (!method) {
      return fail(400, { ok: false, error: "INVALID_METHOD", detail: "Withdrawal method not found" });
    }
    
    // Read withdrawal settings
    const { data: settings } = await supabase
      .from('app_settings')
      .select('withdrawal_fee_pct, withdrawal_daily_cap_usd, withdrawal_daily_cap_usdt')
      .eq('id', 1)
      .single();
    
    const feePct = parseFloat(settings?.withdrawal_fee_pct || '0');
    const dailyCapUSD = parseFloat(settings?.withdrawal_daily_cap_usd || '10000');
    const dailyCapUSDT = parseFloat(settings?.withdrawal_daily_cap_usdt || '10000');
    
    // Calculate fee
    const feeAmount = withdrawalAmount * (feePct / 100);
    const totalDebit = withdrawalAmount + feeAmount;
    
    // Validate daily cap using withdrawals sum for today per currency
    const today = new Date().toISOString().split('T')[0];
    const { data: todayWithdrawals } = await supabase
      .from('withdrawals')
      .select('amount')
      .eq('user_id', user.id)
      .eq('currency', currency)
      .gte('created_at', today)
      .in('status', ['pending', 'approved']);
    
    const todayTotal = todayWithdrawals?.reduce((sum: number, w: any) => sum + parseFloat(w.amount), 0) || 0;
    const dailyCap = currency === 'USD' ? dailyCapUSD : dailyCapUSDT;
    
    if (todayTotal + totalDebit > dailyCap) {
      return fail(400, { ok: false, error: "DAILY_CAP_EXCEEDED", detail: `Daily withdrawal limit exceeded` });
    }
    
    // Validate sufficient balance
    const { data: balances } = await supabase
      .from('wallet_balances')
      .select('balance')
      .eq('user_id', user.id)
      .eq('currency', currency)
      .single();
    
    if (!balances || balances.balance < totalDebit) {
      return fail(400, { ok: false, error: "INSUFFICIENT_BALANCE", detail: "Insufficient balance" });
    }
    
    // Insert into withdrawals (pending)
    const { data: withdrawal, error: withdrawalError } = await supabase
      .from('withdrawals')
      .insert({
        user_id: user.id,
        currency,
        amount: withdrawalAmount,
        fee_amount: feeAmount,
        method: method.method,
        method_id: method_id,
        status: 'pending',
        created_at: new Date().toISOString()
      })
      .select()
      .single();
    
    if (withdrawalError || !withdrawal) {
      return fail(500, { ok: false, error: "DB_ERROR", detail: "Failed to create withdrawal request" });
    }
    
    // Write wallet_ledger debit immediately to reserve funds
    const { error: ledgerError } = await supabase
      .from('wallet_ledger')
      .insert({
        user_id: user.id,
        currency,
        amount: -totalDebit,
        reason: 'withdrawal',
        ref_table: 'withdrawals',
        ref_id: withdrawal.id,
        created_at: new Date().toISOString()
      });
    
    if (ledgerError) {
      return fail(500, { ok: false, error: "DB_ERROR", detail: "Failed to create ledger entry" });
    }
    
    return ok({
      ok: true,
      withdrawal: {
        id: withdrawal.id,
        status: withdrawal.status,
        currency: withdrawal.currency,
        amount: withdrawal.amount,
        fee_amount: withdrawal.fee_amount,
        method: withdrawal.method,
        created_at: withdrawal.created_at
      }
    });

  } catch (error) {
    return fail(500, { ok: false, error: "SERVER_ERROR", detail: String(error) });
  }
});
