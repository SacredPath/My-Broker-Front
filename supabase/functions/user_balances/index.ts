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
    
    // Query wallet_balances view for USD + USDT
    let balances = { USD: 0, USDT: 0 };
    try {
      const { data } = await supabase
        .from("wallet_balances")
        .select("currency,balance")
        .eq("user_id", user.id)
        .in("currency", ["USD", "USDT"]);
      
      if (data) {
        data.forEach(item => {
          if (item.currency === "USD") balances.USD = Number(item.balance);
          if (item.currency === "USDT") balances.USDT = Number(item.balance);
        });
      }
    } catch {
      // View missing or error - balances remain at 0
    }

    return ok({ 
      ok: true,
      balances
    });
  } catch (error) {
    return fail(500, { ok: false, error: "SERVER_ERROR", detail: String(error) });
  }
});
