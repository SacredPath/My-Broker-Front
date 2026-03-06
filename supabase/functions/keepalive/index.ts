import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { handleOptions, ok, fail } from "../_shared/http.ts";
import { adminClient } from "../_shared/clients.ts";

serve(async (req: Request) => {
  // First line must be OPTIONS handling
  const pre = handleOptions(req); if (pre) return pre;

  try {
    // Create admin client for database access
    const supabase = adminClient();
    
    // Query app_settings table as specified in requirements
    const { data, error } = await supabase
      .from('app_settings')
      .select('id, updated_at')
      .eq('id', 1)
      .single();

    if (error) {
      console.error('Keepalive database error:', error);
      return fail(500, { 
        ok: false, 
        error: 'DATABASE_ERROR',
        detail: 'Failed to query app_settings'
      });
    }

    // Return success with database verification
    return ok({
      ok: true,
      pong: true,
      timestamp: new Date().toISOString(),
      database_connected: true,
      app_settings_id: data?.id,
      app_settings_updated: data?.updated_at,
      note: "keepalive ping successful - database verified"
    });

  } catch (error) {
    console.error('Keepalive error:', error);
    return fail(500, { 
      ok: false, 
      error: 'SERVER_ERROR',
      detail: 'Internal server error during keepalive'
    });
  }
});
