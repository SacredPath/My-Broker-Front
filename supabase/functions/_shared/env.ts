export function getEnv(name: string): string {
  const value = Deno.env.get(name)?.trim();
  if (!value) {
    throw new Error(`ENV_MISSING:${name}`);
  }
  return value;
}

export function getSupabaseConfig() {
  const SUPABASE_URL = getEnv("SUPABASE_URL");
  const SUPABASE_ANON_KEY = getEnv("SUPABASE_ANON_KEY");
  const SUPABASE_SERVICE_ROLE_KEY = getEnv("SUPABASE_SERVICE_ROLE_KEY");
  
  return { SUPABASE_URL, SUPABASE_ANON_KEY, SUPABASE_SERVICE_ROLE_KEY };
}
