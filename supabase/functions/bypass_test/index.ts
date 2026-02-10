import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

serve(async (req: Request) => {
  // Handle CORS manually without shared modules
  if (req.method === "OPTIONS") {
    return new Response(null, { 
      status: 204, 
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
        "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
      }
    });
  }

  try {
    console.log('BYPASS_TEST: Request received');
    console.log('BYPASS_TEST: Method:', req.method);
    console.log('BYPASS_TEST: URL:', req.url);
    
    const allHeaders = Object.fromEntries(req.headers.entries());
    console.log('BYPASS_TEST: All headers:', allHeaders);
    
    // Return success without ANY auth validation
    return new Response(JSON.stringify({
      ok: true,
      message: "Bypass test working - no auth validation",
      timestamp: new Date().toISOString(),
      function: "bypass_test",
      method: req.method,
      url: req.url,
      headers_received: allHeaders,
      note: "This function bypasses all auth validation"
    }), {
      status: 200,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
      }
    });

  } catch (error) {
    console.error('BYPASS_TEST: Error:', error);
    return new Response(JSON.stringify({ 
      ok: false, 
      error: "SERVER_ERROR",
      detail: error.message
    }), {
      status: 500,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      }
    });
  }
});
