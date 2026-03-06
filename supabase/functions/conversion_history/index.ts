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
    
    const { user } = auth;
    
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
    
    // Read from conversions for the user ordered by created_at desc
    const { data, error } = await supabase
      .from("conversions")
      .select("id,usdt_amount,fx_rate,markup_pct,fee_fixed_usd,fee_pct,usd_gross,usd_net,status,created_at")
      .eq("user_id", user.id)
      .order("created_at", { ascending: false })
      .limit(50);

    if (error) {
      return ok({ conversions: [] });
    }

    const conversions = (data || []).map((c: any) => ({
      ...c,
      usdt_amount: parseFloat(c.usdt_amount) || 0,
      fx_rate: parseFloat(c.fx_rate) || 0,
      markup_pct: parseFloat(c.markup_pct) || 0,
      fee_fixed_usd: parseFloat(c.fee_fixed_usd) || 0,
      fee_pct: parseFloat(c.fee_pct) || 0,
      usd_gross: parseFloat(c.usd_gross) || 0,
      usd_net: parseFloat(c.usd_net) || 0
    }));

    return ok({ 
      ok: true,
      conversions 
    });
  } catch (error) {
    return fail(500, { ok: false, error: "SERVER_ERROR", detail: String(error) });
  }
});
