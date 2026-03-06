import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { handleOptions, json } from "../_shared/cors.ts";

serve(async (req: Request) => {
  const preflight = handleOptions(req);
  if (preflight) return preflight;

  try {
    // SCHEDULED: Require x-cron-secret header
    const cronSecret = Deno.env.get("CRON_SECRET");
    if (!cronSecret) {
      return json({ok:false,error:"CRON_SECRET_NOT_CONFIGURED"}, 500, req);
    }

    const providedSecret = req.headers.get("x-cron-secret");
    if (providedSecret !== cronSecret) {
      return json({ok:false,error:"UNAUTHORIZED_CRON"}, 401, req);
    }

    // TODO: Implement USDT TRC20 watching (skeleton only)
    console.debug("USDT TRC20 watch executed");

    return json({ ok: true, fn: "usdt_watch_trc20" }, 200, req);
  } catch (error) {
    return json({ok:false,error:"SERVER_ERROR",detail:String(error)}, 500, req);
  }
});
