import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { json, preflight } from "../_shared/http.ts";

serve(async (req) => {
  const pf = preflight(req);
  if (pf) return pf;

  return json({ ok: false, error: "NOT_IMPLEMENTED" }, 501);
});
