import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { options204, corsHeaders } from "../_shared/http.ts";

serve(async (req: Request) => {
  // Handle OPTIONS
  if (req.method === "OPTIONS") {
    return options204(req);
  }

  // Return simple response without any auth
  return new Response(JSON.stringify({
    ok: true,
    message: "JWT verification disabled test",
    timestamp: new Date().toISOString(),
    requestId: crypto.randomUUID()
  }), {
    status: 200,
    headers: {
      "content-type": "application/json",
      ...corsHeaders(req)
    }
  });
});
