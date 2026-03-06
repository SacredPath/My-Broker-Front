import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { handleOptions, ok, fail } from "../_shared/http.ts";
import { requireUser } from "../_shared/auth.ts";

serve(async (req: Request) => {
  // First line must be OPTIONS handling
  const pre = handleOptions(req); if (pre) return pre;

  try {
    // Auth required - validates JWT and loads profile
    const auth = await requireUser(req);
    
    // Check if auth failed
    if (!auth.ok) {
      return fail(auth.status, auth.body);
    }
    
    const { user, profile } = auth;
    const role = profile?.role || 'user';
    
    // Define permissions based on role
    const permissions = getRolePermissions(role);
    
    return ok({
      ok: true,
      user_id: profile?.user_id || user.id,
      role: role,
      permissions: permissions,
      profile: {
        user_id: profile?.user_id || user.id,
        role: role,
        created_at: profile?.created_at,
        email_verified: profile?.email_verified || false,
        kyc_status: profile?.kyc_status || 'not_submitted',
        is_frozen: profile?.is_frozen || false,
        is_growth_paused: profile?.is_growth_paused || false
      }
    });
  } catch (error) {
    console.error('RBAC_ME error:', error);
    return fail(500, { ok: false, error: "SERVER_ERROR", detail: "Internal server error" });
  }
});

// Role-based permissions mapping
function getRolePermissions(role: string): string[] {
  switch (role) {
    case 'superadmin':
      return [
        // User management
        'users:read', 'users:write', 'users:delete',
        'users:verify_email', 'users:approve_kyc', 'users:freeze',
        'users:adjust_balances', 'users:override_tier',
        
        // Financial operations
        'deposits:approve', 'deposits:reject',
        'withdrawals:approve', 'withdrawals:reject',
        'conversions:read', 'conversions:write',
        
        // System settings
        'settings:read', 'settings:write',
        'rates:read', 'rates:write',
        'fees:read', 'fees:write',
        
        // Audit and monitoring
        'audit:read', 'audit:write',
        'reports:read', 'system:monitor',
        
        // Back Office access
        'backoffice:access'
      ];
      
    case 'support':
      return [
        // User management (limited)
        'users:read',
        'users:approve_kyc',
        
        // Financial operations (limited)
        'deposits:read', 'deposits:approve',
        'withdrawals:read',
        'conversions:read',
        
        // Settings (read-only)
        'settings:read',
        'rates:read',
        'fees:read',
        
        // Audit (read-only)
        'audit:read',
        'reports:read',
        
        // Back Office access
        'backoffice:access'
      ];
      
    case 'user':
    default:
      return [
        // Basic user permissions
        'profile:read', 'profile:write',
        'balances:read',
        'positions:read',
        'deposits:create', 'deposits:read',
        'withdrawals:create', 'withdrawals:read',
        'conversions:create', 'conversions:read',
        'signals:read', 'signals:purchase',
        'history:read'
      ];
  }
}
