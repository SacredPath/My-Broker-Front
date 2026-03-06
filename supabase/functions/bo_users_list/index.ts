import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { preflight, json, err } from "../_shared/http.ts";
import { requireUser, loadProfileSimple, requireRole } from "../_shared/auth.ts";
import { adminClient } from "../_shared/db.ts";

serve(async (req: Request) => {
  const pre = preflight(req);
  if (pre) return pre;

  try {
    // Auth required
    const { user } = await requireUser(req);
    
    // Load profile and check BO permissions
    const profile = await loadProfileSimple(user.id);
    requireRole(profile, ['support', 'superadmin']);
    
    // Parse query parameters
    const url = new URL(req.url);
    const limit = parseInt(url.searchParams.get('limit') || '50');
    const offset = parseInt(url.searchParams.get('offset') || '0');
    const search = url.searchParams.get('search');
    
    // Query users from profiles
    const supabase = adminClient();
    let query = supabase
      .from("profiles")
      .select("user_id,email,full_name,role,kyc_status,is_frozen,created_at")
      .order("created_at", { ascending: false })
      .range(offset, offset + limit - 1);
    
    // Optional search filter
    if (search) {
      query = query.or(`email.ilike.%${search}%,full_name.ilike.%${search}%`);
    }
    
    const { data, error } = await query;

    if (error) {
      return err(req, 'DB_ERROR', 500, 'Failed to fetch users');
    }

    return json(req, { 
      ok: true,
      data: data || [],
      pagination: {
        limit,
        offset,
        hasMore: (data?.length || 0) === limit
      }
    });
  } catch (error: any) {
    if (error.message?.includes('authorization')) {
      return err(req, 'UNAUTHENTICATED', 401, 'Authentication required');
    }
    if (error.message?.includes('permissions')) {
      return err(req, 'INSUFFICIENT_PERMISSIONS', 403, 'BO access required');
    }
    return err(req, 'SERVER_ERROR', 500, String(error));
  }
});
