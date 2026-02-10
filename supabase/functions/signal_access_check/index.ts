import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { handleOptions, ok, fail } from "../_shared/http.ts";
import { requireUser, adminClient } from "../_shared/auth.ts";

serve(async (req: Request) => {
  if (req.method === "OPTIONS") return handleOptions(req);

  try {
    // Auth required
    const { user } = await requireUser(req);
    
    // Get signal_id from query params
    const url = new URL(req.url);
    const signalId = url.searchParams.get('signal_id');
    
    if (!signalId) {
      return fail(req, 400, "BAD_REQUEST", "signal_id parameter required");
    }
    
    const supabase = adminClient();
    
    // Check signal_access
    const { data, error } = await supabase
      .from("signal_access")
      .select("expires_at")
      .eq("user_id", user.id)
      .eq("signal_id", signalId)
      .gt("expires_at", new Date().toISOString())
      .maybeSingle();

    if (error) {
      return fail(req, 500, "DB_ERROR", "Failed to check access");
    }

    return ok(req, {
      has_access: !!data,
      expires_at: data?.expires_at || null
    });

  } catch (error) {
    if (error instanceof Response) return error;
    return fail(req, 500, "SERVER_ERROR", String(error));
  }
});
