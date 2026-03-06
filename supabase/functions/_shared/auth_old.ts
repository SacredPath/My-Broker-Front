import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { getSupabaseConfig } from "./env.ts";

export async function requireUser(req: Request) {
  const authHeader = req.headers.get("Authorization") ?? "";
  if (!authHeader.startsWith("Bearer ")) {

export async function getUserOr401(req: Request) {
  const authHeader = req.headers.get("authorization");
  if (!authHeader?.startsWith("Bearer ")) {
    const origin = req.headers.get("origin") || undefined;
    throw err("UNAUTHENTICATED", 401, "Missing authorization header", origin);
  }

  const token = authHeader.replace("Bearer ", "");
  
  try {
    const { data: { user }, error } = await adminClient.auth.getUser(token);
    if (error || !user) {
      const origin = req.headers.get("origin") || undefined;
      throw err("UNAUTHENTICATED", 401, "Invalid JWT", origin);
    }
    return { user, admin: adminClient };
  } catch (error) {
    const origin = req.headers.get("origin") || undefined;
    throw err("UNAUTHENTICATED", 401, "Invalid JWT", origin);
  }
}

export async function loadProfileOrDefault(userId: string) {
  try {
    const { data: profile, error } = await adminClient
      .from("profiles")
      .select("user_id, role, created_at")
      .eq("user_id", userId)
      .maybeSingle();
    
    if (error) {
      // Table doesn't exist or other DB error - return default
      return { 
        user_id: userId, 
        role: "user", 
        created_at: new Date().toISOString(), 
        missing: true,
        db_error: error.message 
      };
    }
    
    if (!profile) {
      // Profile missing - return default without throwing
      return { 
        user_id: userId, 
        role: "user", 
        created_at: new Date().toISOString(), 
        missing: true 
      };
    }
    
    return { ...profile, missing: false };
  } catch (error: any) {
    // Any error - return default without throwing
    return { 
      user_id: userId, 
      role: "user", 
      created_at: new Date().toISOString(), 
      missing: true,
      db_error: error.message 
    };
  }
}

export async function requireProfile(userId: string) {
  try {
    const { data, error } = await adminClient
      .from("profiles")
      .select("*")
      .eq("user_id", userId)
      .single();
    
    if (error) {
      // If table doesn't exist or other DB error
      if (error.code === "PGRST116") {
        // Profile not found - auto-create minimal profile
        try {
          const { data: newProfile, error: createError } = await adminClient
            .from("profiles")
            .insert({
              user_id: userId,
              role: "user",
              created_at: new Date().toISOString()
            })
            .select("*")
            .single();
          
          if (createError) {
            const storageError = new Error(`Profile storage error: ${createError.message}`);
            (storageError as any).status = 500;
            (storageError as any).code = "PROFILE_STORAGE_ERROR";
            (storageError as any).detail = createError.message;
            throw storageError;
          }
          
          return newProfile;
        } catch (createError) {
          const storageError = new Error(`Profile storage error: ${createError.message}`);
          (storageError as any).status = 500;
          (storageError as any).code = "PROFILE_STORAGE_ERROR";
          (storageError as any).detail = createError.message;
          throw storageError;
        }
      } else {
        const dbError = new Error(`Database error: ${error.message}`);
        (dbError as any).status = 500;
        (dbError as any).code = "PROFILE_STORAGE_ERROR";
        (dbError as any).detail = error.message;
        throw dbError;
      }
    }
    
    if (!data) {
      // Profile not found - auto-create minimal profile
      try {
        const { data: newProfile, error: createError } = await adminClient
          .from("profiles")
          .insert({
            user_id: userId,
            role: "user",
            created_at: new Date().toISOString()
          })
          .select("*")
          .single();
        
        if (createError) {
          const storageError = new Error(`Profile storage error: ${createError.message}`);
          (storageError as any).status = 500;
          (storageError as any).code = "PROFILE_STORAGE_ERROR";
          (storageError as any).detail = createError.message;
          throw storageError;
        }
        
        return newProfile;
      } catch (createError) {
        const storageError = new Error(`Profile storage error: ${createError.message}`);
        (storageError as any).status = 500;
        (storageError as any).code = "PROFILE_STORAGE_ERROR";
        (storageError as any).detail = createError.message;
        throw storageError;
      }
    }
    
    return data;
  } catch (error) {
      if (error instanceof Error) {
        // Re-throw structured errors
        throw error;
      }
      
      const unknownError = new Error("Unknown profile error");
      (unknownError as any).status = 500;
      (unknownError as any).code = "PROFILE_STORAGE_ERROR";
      (unknownError as any).detail = error instanceof Error ? error.message : 'Unknown error';
      throw unknownError;
    }
}
