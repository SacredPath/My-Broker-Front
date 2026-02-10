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
    
    // Read withdrawal_fee_pct, withdrawal_daily_cap_usd, withdrawal_daily_cap_usdt from app_settings
    const { data: settings, error } = await supabase
      .from('app_settings')
      .select('withdrawal_fee_pct, withdrawal_daily_cap_usd, withdrawal_daily_cap_usdt')
      .eq('id', 1)
      .single();
    
    if (error || !settings) {
      return ok({
        ok: true,
        withdrawal_fee_pct: 0,
        withdrawal_daily_cap_usd: 0,
        withdrawal_daily_cap_usdt: 0
      });
    }
    
    return ok({
      ok: true,
      withdrawal_fee_pct: parseFloat(settings.withdrawal_fee_pct) || 0,
      withdrawal_daily_cap_usd: parseFloat(settings.withdrawal_daily_cap_usd) || 0,
      withdrawal_daily_cap_usdt: parseFloat(settings.withdrawal_daily_cap_usdt) || 0
    });

  } catch (error) {
    return fail(500, { ok: false, error: "SERVER_ERROR", detail: String(error) });
  }
});
