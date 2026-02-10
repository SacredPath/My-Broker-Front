import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

serve(async (req: Request) => {
  // Early OPTIONS handling - must run before any auth/DB
  if (req.method === "OPTIONS") {
    return new Response(null, {
      status: 204,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type, x-user-token",
        "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
        "Access-Control-Max-Age": "86400",
        "Vary": "Origin"
      }
    });
  }

  try {
    // Simple test response
    return new Response(JSON.stringify({
      ok: true,
      message: "tiers_list is working",
      tiers: []
    }), {
      status: 200,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type, x-user-token",
        "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
        "Access-Control-Max-Age": "86400",
        "Vary": "Origin"
      }
    });
  } catch (error) {
    return new Response(JSON.stringify({
      ok: false,
      error: "SERVER_ERROR",
      detail: String(error)
    }), {
      status: 500,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type, x-user-token",
        "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
        "Access-Control-Max-Age": "86400",
        "Vary": "Origin"
      }
    });
  }
});
