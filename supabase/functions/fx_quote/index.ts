import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { handleOptions, json } from "../_shared/cors.ts";

serve(async (req) => {
  const preflight = handleOptions(req);
  if (preflight) return preflight;

  const requestId = Math.random().toString(36).substring(2, 15) + Date.now().toString(36);
  
  try {
    // Parse request body
    let body;
    try {
      body = await req.json();
    } catch (parseError) {
      return json({
        ok: false,
        error: "INVALID_JSON",
        detail: "Invalid JSON in request body"
      }, 400, req);
    }
    
    const { from_currency, to_currency, amount } = body;
    
    // Validate input
    if (!from_currency || !to_currency || !amount) {
      return json({
        ok: false,
        error: "INVALID_INPUT",
        detail: "Missing required fields: from_currency, to_currency, amount"
      }, 400, req);
    }

    // For now, return a simple 1:1 conversion rate
    // In production, this would call a real FX API
    const rate = 1.0;
    const converted_amount = amount * rate;
    
    return json({ 
      ok: true, 
      from_currency,
      to_currency,
      amount,
      rate,
      converted_amount,
      timestamp: new Date().toISOString()
    }, 200, req);

  } catch (error) {
    console.error('fx_quote error:', error);
    return json({
      ok: false,
      error: "SERVER_ERROR",
      detail: String(error),
      requestId
    }, 500, req);
  }
});
