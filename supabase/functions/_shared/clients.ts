import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { getSupabaseConfig } from "./env.ts";

export function userClient(authHeader: string) {
  const { SUPABASE_URL, SUPABASE_ANON_KEY } = getSupabaseConfig();
  return createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
    global: { headers: { Authorization: authHeader } },
  });
}

export function adminClient() {
  const { SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY } = getSupabaseConfig();
  return createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
}
