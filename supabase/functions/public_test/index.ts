import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { handleOptions, ok, fail } from "../_shared/http.ts";

serve(async (req: Request) => {
  // First line must be OPTIONS handling
  const pre = handleOptions(req); if (pre) return pre;

  try {
    // Log incoming request details for debugging
    console.log('PUBLIC_TEST: Request received');
    console.log('PUBLIC_TEST: Method:', req.method);
    console.log('PUBLIC_TEST: URL:', req.url);
    console.log('PUBLIC_TEST: Headers:', Object.fromEntries(req.headers.entries()));
    
    // Simple response without any auth
    return ok({
      ok: true,
      message: "Public test function working - no auth required",
      timestamp: new Date().toISOString(),
      function: "public_test",
      method: req.method,
      url: req.url,
      headers_received: Object.fromEntries(req.headers.entries())
    });

  } catch (error) {
    console.error('PUBLIC_TEST: Error:', error);
    return fail(500, { 
      ok: false, 
      error: "SERVER_ERROR",
      detail: error.message
    });
  }
});
