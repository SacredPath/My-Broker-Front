import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { options204, corsHeaders } from "../_shared/http.ts";
import { verifySupabaseJWT } from "../_shared/auth.ts";

serve(async (req: Request) => {
  // Handle OPTIONS
  if (req.method === "OPTIONS") {
    return options204(req);
  }

  // Get token from query parameter (for testing only)
  const url = new URL(req.url);
  const token = url.searchParams.get("token");
  
  if (!token) {
    return new Response(JSON.stringify({
      ok: false,
      error: "Missing token parameter",
      usage: "Add ?token=<your-jwt> to the URL"
    }), {
      status: 400,
      headers: {
        "content-type": "application/json",
        ...corsHeaders(req)
      }
    });
  }

  // Test custom JWT verification
  try {
    const payload = await verifySupabaseJWT(token);
    
    return new Response(JSON.stringify({
      ok: true,
      message: "JWT verification successful",
      payload,
      requestId: crypto.randomUUID()
    }), {
      status: 200,
      headers: {
        "content-type": "application/json",
        ...corsHeaders(req)
      }
    });
  } catch (error) {
    return new Response(JSON.stringify({
      ok: false,
      error: "JWT verification failed",
      detail: (error as Error).message,
      requestId: crypto.randomUUID()
    }), {
      status: 401,
      headers: {
        "content-type": "application/json",
        ...corsHeaders(req)
      }
    });
  }
});
