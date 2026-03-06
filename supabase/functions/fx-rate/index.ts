import { serve } from 'https://deno.land/std@0.224.0/http/server.ts'
import { handleOptions, json } from "../_shared/cors.ts";

serve(async (req) => {
  const preflight = handleOptions(req);
  if (preflight) return preflight;

  try {
    const url = new URL(req.url)
    
    // Selfcheck route - no external calls
    if (url.searchParams.get('selfcheck') === '1') {
      const required = ['COINGECKO_API_KEY']
      const coingeckoApiKey = Deno.env.get("COINGECKO_API_KEY")?.trim()
      const present = coingeckoApiKey ? ['COINGECKO_API_KEY'] : []
      const missing = required.filter(key => !Deno.env.get(key)?.trim())
      
      return json({ 
        ok: true, 
        code: "OK", 
        message: "Selfcheck", 
        data: { required, present, missing } 
      }, 200, req)
    }

    // Ping route - no external calls
    if (url.searchParams.get('ping') === '1') {
      return json({ 
        ok: true, 
        code: "OK", 
        message: "fx-rate alive", 
        data: { needsKey: true } 
      }, 200, req)
    }

    // Check if CoinGecko API key is configured
    const coingeckoApiKey = Deno.env.get("COINGECKO_API_KEY")?.trim()
    
    if (!coingeckoApiKey) {
      return json({ 
        ok: false, 
        code: "PROVIDER_NOT_CONFIGURED", 
        message: "Provider not configured", 
        data: { missing: ["COINGECKO_API_KEY"] } 
      }, 503, req)
    }

    // Prepare headers - only include API key if it exists
    const headers: Record<string, string> = { "accept": "application/json" }
    headers["x-cg-demo-api-key"] = coingeckoApiKey

    // Example: Get BTC to USD exchange rate
    const response = await fetch(
      `https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd`,
      { headers }
    )

    if (!response.ok) {
      throw new Error(`CoinGecko API error: ${response.status}`)
    }

    const data = await response.json()

    return json({ 
      ok: true, 
      code: "OK", 
      message: "Success", 
      data: {
        btc_usd: data.bitcoin.usd,
        symbol: 'BTC/USD',
        timestamp: new Date().toISOString()
      } 
    }, 200, req)
  } catch (error) {
    console.error('FX Rate error:', error)
    
    return json({
      ok: false,
      code: "INTERNAL_ERROR",
      message: "Internal error occurred",
      data: { hint: "check edge logs" }
    }, 500, req)
  }
})
