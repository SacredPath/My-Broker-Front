import { serve } from 'https://deno.land/std@0.224.0/http/server.ts'
import { handleOptions, json } from "../_shared/cors.ts";

serve(async (req) => {
  const preflight = handleOptions(req);
  if (preflight) return preflight;

  try {
    const url = new URL(req.url)
    
    // Selfcheck route - no external calls
    if (url.searchParams.get('selfcheck') === '1') {
      const required = ['STRIPE_SECRET_KEY']
      const stripeSecretKey = Deno.env.get("STRIPE_SECRET_KEY")?.trim()
      const present = stripeSecretKey ? ['STRIPE_SECRET_KEY'] : []
      const missing = required.filter(key => !Deno.env.get(key)?.trim())
      
      return json({ 
        ok: true, 
        code: "OK", 
        message: "Selfcheck", 
        data: { required, present, missing } 
      }, 200, req)
    }

    // Check if Stripe API key is configured
    const stripeSecretKey = Deno.env.get("STRIPE_SECRET_KEY")?.trim()
    
    if (!stripeSecretKey) {
      return json({ 
        ok: false, 
        code: "PROVIDER_NOT_CONFIGURED", 
        message: "Provider not configured", 
        data: { missing: ["STRIPE_SECRET_KEY"] } 
      }, 503, req)
    }

    // Example: Create payment intent
    const { amount, currency = 'usd' } = await req.json()

    if (!amount || amount <= 0) {
      return json({ 
        ok: false, 
        code: "INVALID_REQUEST",
        message: "Invalid amount",
        data: { hint: "amount must be greater than 0" }
      }, 400, req)
    }

    // Prepare headers - only include Authorization if key exists
    const headers: Record<string, string> = {
      'Content-Type': 'application/x-www-form-urlencoded'
    }
    headers["Authorization"] = `Bearer ${stripeSecretKey}`

    const response = await fetch('https://api.stripe.com/v1/payment_intents', {
      method: 'POST',
      headers,
      body: new URLSearchParams({
        amount: Math.round(amount * 100).toString(), // Convert to cents and string
        currency: currency,
        'payment_method_types': 'card'
      })
    })

    if (!response.ok) {
      throw new Error(`Stripe API error: ${response.status}`)
    }

    const paymentIntent = await response.json()

    return json({ 
      ok: true, 
      code: "OK", 
      message: "Success", 
      data: {
        client_secret: paymentIntent.client_secret,
        payment_intent_id: paymentIntent.id,
        amount: paymentIntent.amount,
        currency: paymentIntent.currency
      } 
    }, 200, req)
  } catch (error) {
    console.error('Stripe error:', error)
    
    return json({
      ok: false,
      code: "INTERNAL_ERROR",
      message: "Internal error occurred",
      data: { hint: "check edge logs" }
    }, 500, req)
  }
})
