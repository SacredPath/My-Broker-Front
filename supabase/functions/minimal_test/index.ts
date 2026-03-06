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
    console.log('MINIMAL_TEST: Request received');
    console.log('MINIMAL_TEST: Method:', req.method);
    console.log('MINIMAL_TEST: URL:', req.url);
    
    const allHeaders = Object.fromEntries(req.headers.entries());
    console.log('MINIMAL_TEST: All headers:', allHeaders);
    console.log('MINIMAL_TEST: Authorization header:', req.headers.get('authorization'));
    console.log('MINIMAL_TEST: apikey header:', req.headers.get('apikey'));
    console.log('MINIMAL_TEST: Content-Type header:', req.headers.get('content-type'));
    
    // Check for specific headers that might be stripped
    const authHeader = req.headers.get('authorization');
    if (authHeader) {
      console.log('MINIMAL_TEST: Authorization found:', authHeader.substring(0, 50) + '...');
      console.log('MINIMAL_TEST: Authorization starts with Bearer:', authHeader.startsWith('Bearer '));
    } else {
      console.log('MINIMAL_TEST: NO Authorization header found!');
    }
    
    // Simple response without any shared modules
    return new Response(JSON.stringify({
      ok: true,
      message: "Minimal test function working - no shared modules",
      timestamp: new Date().toISOString(),
      function: "minimal_test",
      method: req.method,
      url: req.url,
      headers_received: allHeaders,
      auth_header_present: !!authHeader,
      auth_header_value: authHeader ? authHeader.substring(0, 50) + '...' : null
    }), {
      status: 200,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
      }
    });

  } catch (error) {
    console.error('MINIMAL_TEST: Error:', error);
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
