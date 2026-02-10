import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { handleOptions, json } from "../_shared/cors.ts";
import { getUserOr401, loadProfile } from "../_shared/auth.ts";

serve(async (req) => {
  const preflight = handleOptions(req);
  if (preflight) return preflight;

  try {
    // Auth required
    const authResult = await getUserOr401(req);
    if (authResult instanceof Response) return authResult;
    
    const { user, supabase } = authResult;
    
    // Load profile
    const profileResult = await loadProfile(req, supabase, user.id);
    if (profileResult.missing) {
      return json({ 
        ok: false, 
        error: "PROFILE_NOT_FOUND",
        user_id: user.id
      }, 200, req);
    }
    
    const { missing, ...profile } = profileResult;

    return json({ 
      ok: false, 
      error: "NOT_IMPLEMENTED"
    }, 501, req);

  } catch (error) {
    return json({ok:false,error:"SERVER_ERROR",detail:String(error)}, 500, req);
  }
});
