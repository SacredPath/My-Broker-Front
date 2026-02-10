import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { handleOptions, json } from "../_shared/cors.ts";

serve(async (req) => {
  const preflight = handleOptions(req);
  if (preflight) return preflight;

  const requestId = Math.random().toString(36).substring(2, 15) + Date.now().toString(36);
  
  try {
    return json({
      ok: false,
      error: "NOT_IMPLEMENTED",
      fn: "users_create",
      requestId
    }, 501, req);

  } catch (error) {
    console.error('users_create error:', error);
    return json({
      ok: false,
      error: "SERVER_ERROR",
      detail: String(error),
      requestId
    }, 500, req);
  }
});
