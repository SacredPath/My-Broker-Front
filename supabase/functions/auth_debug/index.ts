import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { handleOptions, ok, fail } from "../_shared/http.ts";
import { getAuthHeader } from "../_shared/auth.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

serve(async (req: Request) => {
  // First line must be OPTIONS handling
  const pre = handleOptions(req); if (pre) return pre;

  const requestId = Math.random().toString(36).substring(2, 15) + Date.now().toString(36);
  
  try {
    // Read headers for diagnostics
    const authHeader = getAuthHeader(req);
    const hasAuthHeader = authHeader !== null;
    const authHeaderPrefix = authHeader ? authHeader.substring(0, 20) : null;
    
    const apiKeyHeader = req.headers.get("apikey") ?? req.headers.get("Apikey") ?? req.headers.get("APIKEY");
    const hasApiKey = apiKeyHeader !== null;
    const apiKeyPrefix = apiKeyHeader ? apiKeyHeader.substring(0, 10) : null;

    // Get environment variables
    const SUPABASE_URL = Deno.env.get("SUPABASE_URL");
    const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    
    if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
      return ok({
        ok: false,
        stage: "config",
        hasAuthHeader,
        authHeaderPrefix,
        hasApiKey,
        apiKeyPrefix,
        userId: null,
        error: "SERVER_ERROR",
        detail: "Missing database configuration",
        requestId
      });
    }

    // If no auth header, return early with diagnostics
    if (!authHeader) {
      return ok({
        ok: false,
        stage: "header",
        hasAuthHeader,
        authHeaderPrefix,
        hasApiKey,
        apiKeyPrefix,
        userId: null,
        error: "UNAUTHENTICATED",
        detail: "Missing Authorization header",
        requestId
      });
    }

    // Try to get user with admin client
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
      auth: { persistSession: false },
      global: {
        headers: {
          'Authorization': authHeader
        }
      }
    });

    try {
      const { data: { user }, error } = await supabase.auth.getUser();
      
      if (error || !user) {
        return ok({
          ok: false,
          stage: "getUser",
          hasAuthHeader,
          authHeaderPrefix,
          hasApiKey,
          apiKeyPrefix,
          userId: null,
          error: "UNAUTHENTICATED",
          detail: error?.message || "Invalid or expired token",
          requestId
        });
      }

      // Success
      return ok({
        ok: true,
        stage: "getUser",
        hasAuthHeader,
        authHeaderPrefix,
        hasApiKey,
        apiKeyPrefix,
        userId: user.id,
        error: null,
        detail: null,
        requestId
      });

    } catch (getUserError) {
      return ok({
        ok: false,
        stage: "getUser",
        hasAuthHeader,
        authHeaderPrefix,
        hasApiKey,
        apiKeyPrefix,
        userId: null,
        error: "SERVER_ERROR",
        detail: String(getUserError),
        requestId
      });
    }

  } catch (error) {
    return ok({
      ok: false,
      stage: "config",
      hasAuthHeader: false,
      authHeaderPrefix: null,
      hasApiKey: false,
      apiKeyPrefix: null,
      userId: null,
      error: "SERVER_ERROR",
      detail: String(error),
      requestId
    });
  }
});
