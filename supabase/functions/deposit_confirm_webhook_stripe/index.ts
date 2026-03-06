import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { json, preflight, err } from "../_shared/http.ts";

serve(async (req) => {
  const pf = preflight(req);
  if (pf) return pf;

  try {
    // WEBHOOK: Require stripe-signature header
    const stripeSignature = req.headers.get("stripe-signature");
    const origin = req.headers.get("origin") || undefined;
    
    if (!stripeSignature) {
      return err("WEBHOOK_MISSING_SIGNATURE", 400, "Missing stripe-signature header", origin);
    }

    return err("NOT_IMPLEMENTED", 501, "Stripe webhook processing not implemented yet", origin);
  } catch (error) {
    const origin = req.headers.get("origin") || undefined;
    return err("SERVER_ERROR", 500, String(error), origin);
  }
});
