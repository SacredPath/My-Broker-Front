import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { handleOptions, json } from "../_shared/cors.ts";

serve(async (req: Request) => {
  const preflight = handleOptions(req);
  if (preflight) return preflight;

  try {
    // Check if this is a scheduled cron call or manual refresh
    const cronSecret = Deno.env.get("CRON_SECRET");
    const providedSecret = req.headers.get("x-cron-secret");
    
    // If cron secret is configured, verify it for scheduled calls
    if (cronSecret && providedSecret) {
      if (providedSecret !== cronSecret) {
        return json({ok:false,error:"UNAUTHORIZED_CRON"}, 401, req);
      }
      console.debug("Scheduled price refresh executed");
    } else {
      // Manual refresh from frontend - no auth required
      console.debug("Manual price refresh executed");
    }

    // TODO: Implement price refreshing (skeleton only)
    return json({ ok: true, fn: "prices_refresh" }, 200, req);
  } catch (error) {
    return json({ok:false,error:"SERVER_ERROR",detail:String(error)}, 500, req);
  }
});
