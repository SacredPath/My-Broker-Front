import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { handleOptions, ok, fail } from "../_shared/http.ts";
import { requireUser } from "../_shared/auth.ts";

serve(async (req: Request) => {
  // First line must be OPTIONS handling
  const pre = handleOptions(req); if (pre) return pre;

  try {
    // Auth required
    const auth = await requireUser(req);
    if (!auth.ok) {
      return fail(auth.status, auth.body);
    }
    
    const { user } = auth;
    
    // Get request body
    const { method, details } = await req.json();
    
    if (!method || !details) {
      return fail(400, { ok: false, error: "INVALID_REQUEST", detail: "Method and details are required" });
    }
    
    // Get environment variables safely inside handler
    const SUPABASE_URL = Deno.env.get("SUPABASE_URL");
    const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    
    if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
      return fail(500, { ok: false, error: "SERVER_MISCONFIG", detail: "Missing database configuration" });
    }
    
    // Create service client for DB operations
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
      auth: { persistSession: false }
    });
    
    // Insert new withdrawal method
    const { data: result, error } = await supabase
      .from('withdrawal_methods')
      .insert({
        user_id: user.id,
        method: method,
        details: details,
        is_active: true
      })
      .select('id,method,details,created_at,updated_at')
      .single();
    
    if (error) {
      console.error('Database error:', error);
      return fail(500, { ok: false, error: "DATABASE_ERROR", detail: error.message });
    }
    
    return ok({ 
      ok: true,
      method: result
    });

  } catch (error) {
    console.error('Server error:', error);
    return fail(500, { ok: false, error: "SERVER_ERROR", detail: String(error) });
  }
});
