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
    const { usdt_amount } = body;
    
    if (!usdt_amount) {
      return fail(400, { ok: false, error: "MISSING_FIELDS", detail: "usdt_amount is required" });
    }
    
    // Validate USDT amount
    const usdtAmount = parseFloat(usdt_amount);
    if (isNaN(usdtAmount) || usdtAmount <= 0) {
      return fail(400, { ok: false, error: "INVALID_AMOUNT", detail: "USDT amount must be a positive number" });
    }
    
    // Validate user has sufficient USDT balance
    const { data: balances } = await supabase
      .from('wallet_balances')
      .select('balance')
      .eq('user_id', user.id)
      .eq('currency', 'USDT')
      .single();
    
    if (!balances || balances.balance < usdtAmount) {
      return fail(400, { ok: false, error: "INSUFFICIENT_BALANCE", detail: "Insufficient USDT balance" });
    }
    
    // Read fees from app_settings: conversion_fee_fixed_usd, conversion_fee_pct, fx_markup_pct
    const { data: settings } = await supabase
      .from('app_settings')
      .select('conversion_fee_fixed_usd, conversion_fee_pct, fx_markup_pct')
      .eq('id', 1)
      .single();
    
    const feeFixedUSD = parseFloat(settings?.conversion_fee_fixed_usd || '0');
    const feePct = parseFloat(settings?.conversion_fee_pct || '0');
    const fxMarkupPct = parseFloat(settings?.fx_markup_pct || '0');
    
    // Calculate conversion
    const fxRate = 1.0; // USDT to USD rate
    const usdGross = usdtAmount * fxRate;
    const usdGrossAfterMarkup = usdGross * (1 - fxMarkupPct / 100);
    const feeUSD = feeFixedUSD + (feePct / 100) * usdGrossAfterMarkup;
    const usdNet = Math.max(0, usdGrossAfterMarkup - feeUSD);
    
    // Create conversions record with computed fields
    const { data: conversion, error: conversionError } = await supabase
      .from('conversions')
      .insert({
        user_id: user.id,
        usdt_amount: usdtAmount,
        fx_rate: fxRate,
        markup_pct: fxMarkupPct,
        fee_fixed_usd: feeFixedUSD,
        fee_pct: feePct,
        usd_gross: usdGross,
        usd_net: usdNet,
        status: 'completed',
        created_at: new Date().toISOString()
      })
      .select()
      .single();
    
    if (conversionError || !conversion) {
      return fail(500, { ok: false, error: "DB_ERROR", detail: "Failed to create conversion record" });
    }
    
    // Write wallet_ledger: debit USDT (reason='conversion')
    const { error: debitError } = await supabase
      .from('wallet_ledger')
      .insert({
        user_id: user.id,
        currency: 'USDT',
        amount: -usdtAmount,
        reason: 'conversion',
        ref_table: 'conversions',
        ref_id: conversion.id,
        created_at: new Date().toISOString()
      });
    
    if (debitError) {
      return fail(500, { ok: false, error: "DB_ERROR", detail: "Failed to create USDT ledger entry" });
    }
    
    // Write wallet_ledger: credit USD net (reason='conversion')
    const { error: creditError } = await supabase
      .from('wallet_ledger')
      .insert({
        user_id: user.id,
        currency: 'USD',
        amount: usdNet,
        reason: 'conversion',
        ref_table: 'conversions',
        ref_id: conversion.id,
        created_at: new Date().toISOString()
      });
    
    if (creditError) {
      return fail(500, { ok: false, error: "DB_ERROR", detail: "Failed to create USD ledger entry" });
    }
    
    return ok({
      ok: true,
      conversion: {
        id: conversion.id,
        usdt_amount: conversion.usdt_amount,
        fx_rate: conversion.fx_rate,
        markup_pct: conversion.markup_pct,
        fee_fixed_usd: conversion.fee_fixed_usd,
        fee_pct: conversion.fee_pct,
        usd_gross: conversion.usd_gross,
        usd_net: conversion.usd_net,
        status: conversion.status
      }
    });

  } catch (error) {
    return fail(500, { ok: false, error: "SERVER_ERROR", detail: String(error) });
  }
});
