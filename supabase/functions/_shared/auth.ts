import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// Get auth header helper
export function getAuthHeader(req: Request): string | null {
  const authHeader = req.headers.get("authorization") ?? req.headers.get("Authorization");
  if (!authHeader) {
    return null;
  }
  
  if (!authHeader.startsWith("Bearer ")) {
    return null;
  }
  
  return authHeader;
}

// Single authentication function - reads env vars inside handler
export async function requireUser(req: Request, supabaseAdminClient?: any) {
  // Get environment variables safely inside function
  const SUPABASE_URL = Deno.env.get("SUPABASE_URL");
  const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  
  if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
    return {
      ok: false,
      status: 500,
      body: { ok: false, error: "SERVER_MISCONFIG", detail: "Missing database configuration" }
    };
  }
  
  // Extract Authorization header
  const authHeader = getAuthHeader(req);
  
  console.log('Edge Function: Auth header received:', authHeader ? authHeader.substring(0, 30) + '...' : 'None');
  
  if (!authHeader) {
    console.log('Edge Function: No auth header found');
    return {
      ok: false,
      status: 401,
      body: { ok: false, error: "UNAUTHENTICATED", detail: "Missing or invalid Authorization header" }
    };
  }
  
  // Validate Bearer format
  if (!authHeader.startsWith('Bearer ')) {
    console.log('Edge Function: Invalid auth header format, expected "Bearer <token>"');
    return {
      ok: false,
      status: 401,
      body: { ok: false, error: "INVALID_JWT_FORMAT", detail: "Authorization header must be in format 'Bearer <token>'" }
    };
  }
  
  const token = authHeader.substring(7); // Remove "Bearer "
  console.log('Edge Function: JWT token extracted:', token.substring(0, 20) + '...');
  console.log('Edge Function: JWT token length:', token.length);
  
  // Use provided admin client or create new one
  const supabase = supabaseAdminClient || createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
    auth: { persistSession: false },
    global: {
      headers: {
        'Authorization': authHeader
      }
    }
  });
  
  try {
    // Verify user token - this is the only source of truth
    const { data: { user }, error } = await supabase.auth.getUser();
    
    if (error || !user) {
      return {
        ok: false,
        status: 401,
        body: { ok: false, error: "UNAUTHENTICATED", detail: "Invalid or expired token" }
      };
    }
    
    // Load profile with ONLY these columns: user_id, role, created_at
    const { data: profile, error: profileError } = await supabase
      .from("profiles")
      .select("user_id, role, created_at")
      .eq("user_id", user.id)
      .single();
    
    if (profileError || !profile) {
      return {
        ok: false,
        status: 403,
        body: { ok: false, error: "PROFILE_NOT_FOUND", detail: "User profile not found" }
      };
    }
    
    return {
      ok: true,
      user,
      profile
    };
  } catch (error) {
    return {
      ok: false,
      status: 500,
      body: { ok: false, error: "SERVER_ERROR", detail: String(error) }
    };
  }
}

