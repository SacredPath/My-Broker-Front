import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { handleOptions, ok, fail } from "../_shared/http.ts";
import { requireUser } from "../_shared/auth.ts";
import { adminClient } from "../_shared/clients.ts";

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
    
    const supabase = adminClient();
    
    const { data, error } = await supabase
      .from("price_cache")
      .select("symbol,asset_type,price_usd,source,as_of")
      .order("symbol", { ascending: true });

    if (error) {
      console.error('Prices get error:', error);
      return fail(500, { 
        ok: false, 
        error: "DATABASE_ERROR", 
        detail: "Failed to fetch prices" 
      });
    }

    const prices = (data || []).map((p: any) => ({
      ...p,
      price_usd: parseFloat(p.price_usd) || 0
    }));

    return ok({
      ok: true,
      prices,
      last_updated: new Date().toISOString()
    });
  } catch (error) {
    console.error('Prices get error:', error);
    return fail(500, { 
      ok: false, 
      error: "SERVER_ERROR", 
      detail: "Internal server error" 
    });
  }
});
