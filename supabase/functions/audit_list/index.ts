import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { handleOptions, ok, fail } from "../_shared/http.ts";
import { requireUser, loadProfileMinimal, adminClient } from "../_shared/auth.ts";
import { requireRole } from "../_shared/rbac.ts";

serve(async (req: Request) => {
  if (req.method === "OPTIONS") return handleOptions(req);

  try {
    // Auth required
    const { user } = await requireUser(req);
    
    // Load minimal profile and check BO permissions
    const profile = await loadProfileMinimal(user.id);
    
    // RBAC check - only support and superadmin can access
    if (!requireRole(profile.role, ['support', 'superadmin'])) {
      return fail(req, 403, "FORBIDDEN", "Insufficient permissions");
    }
    
    const supabase = adminClient();
    
    const { data, error } = await supabase
      .from("audit_log")
      .select("id,actor_user_id,actor_role,action,target_user_id,reason,created_at,before,after")
      .order("created_at", { ascending: false })
      .limit(100);

    if (error) {
      return fail(req, 500, "DB_ERROR", "Failed to fetch audit log");
    }

    return ok(req, { 
      audits: data || []
    });
  } catch (error) {
    if (error instanceof Response) return error;
    return fail(req, 500, "SERVER_ERROR", String(error));
  }
});
