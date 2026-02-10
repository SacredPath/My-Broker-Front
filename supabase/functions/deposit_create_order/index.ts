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
    const { method, currency, expected_amount } = body;
    
    // Validate required fields
    if (!method || !currency || !expected_amount) {
      return fail(400, { ok: false, error: "MISSING_FIELDS", detail: "method, currency, and expected_amount are required" });
    }
    
    // Validate enum values
    const validMethods = ['bank', 'stripe', 'paypal', 'usdt_trc20'];
    if (!validMethods.includes(method)) {
      return fail(400, { ok: false, error: "INVALID_METHOD", detail: `method must be one of: ${validMethods.join(', ')}` });
    }
    
    const validCurrencies = ['USD', 'USDT'];
    if (!validCurrencies.includes(currency)) {
      return fail(400, { ok: false, error: "INVALID_CURRENCY", detail: `currency must be one of: ${validCurrencies.join(', ')}` });
    }
    
    // Validate amount is positive number
    const amount = parseFloat(expected_amount);
    if (isNaN(amount) || amount <= 0) {
      return fail(400, { ok: false, error: "INVALID_AMOUNT", detail: "Amount must be a positive number" });
    }
    
    // Generate unique_amount for USDT using small random fractional
    let unique_amount = amount;
    if (method === 'usdt_trc20' && currency === 'USDT') {
      // Add small random fractional within tolerance (0.000001 to 0.000999)
      const randomFraction = Math.random() * 0.000998 + 0.000001;
      unique_amount = amount + randomFraction;
      unique_amount = Math.round(unique_amount * 1000000) / 1000000; // Round to 6 decimal places
    }
    
    // Insert into deposits with status=pending
    const { data: deposit, error } = await supabase
      .from('deposits')
      .insert({
        user_id: user.id,
        method,
        currency,
        expected_amount: amount,
        unique_amount: method === 'usdt_trc20' ? unique_amount : null,
        status: 'pending',
        created_at: new Date().toISOString()
      })
      .select()
      .single();
    
    if (error || !deposit) {
      return fail(500, { ok: false, error: "DB_ERROR", detail: "Failed to create deposit order" });
    }
    
    // Get payment instructions from app_settings
    const { data: settings } = await supabase
      .from('app_settings')
      .select('usdt_trc20_address,bank_details,stripe_hosted_link,paypal_invoice_link')
      .eq('id', 1)
      .single();
    
    // Return created deposit id + payment instructions
    let payment_instructions = null;
    if (method === 'usdt_trc20' && settings?.usdt_trc20_address) {
      payment_instructions = {
        network: 'TRC20',
        address: settings.usdt_trc20_address,
        amount: unique_amount,
        memo: `DEP-${deposit.id}`
      };
    } else if (method === 'bank' && settings?.bank_details) {
      payment_instructions = {
        bank_details: settings.bank_details,
        reference: `DEP-${deposit.id}`
      };
    } else if (method === 'stripe' && settings?.stripe_hosted_link) {
      payment_instructions = {
        hosted_url: settings.stripe_hosted_link,
        amount: amount,
        currency: currency.toLowerCase()
      };
    } else if (method === 'paypal' && settings?.paypal_invoice_link) {
      payment_instructions = {
        invoice_url: settings.paypal_invoice_link,
        amount: amount,
        currency: currency.toLowerCase()
      };
    }
    
    return ok({
      ok: true,
      deposit_id: deposit.id,
      status: deposit.status,
      method: deposit.method,
      currency: deposit.currency,
      expected_amount: deposit.expected_amount,
      unique_amount: deposit.unique_amount,
      payment_instructions
    });

  } catch (error) {
    return fail(500, { ok: false, error: "SERVER_ERROR", detail: String(error) });
  }
});
