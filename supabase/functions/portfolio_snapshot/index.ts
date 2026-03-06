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
    
    const { user, profile } = auth;
    
    const supabase = adminClient();
    
    // Get balances from wallet_balances view
    const { data: balances } = await supabase
      .from("wallet_balances")
      .select("*")
      .eq("user_id", user.id);
    
    // Get positions
    const { data: positions } = await supabase
      .from("positions")
      .select("id,tier_id,principal_usd,started_at,matures_at,last_accrued_at,accrued_roi_usd,status,created_at")
      .eq("user_id", user.id)
      .order("created_at", { ascending: false });
    
    // Get prices
    const { data: prices } = await supabase
      .from("price_cache")
      .select("symbol,asset_type,price_usd,source,as_of")
      .order("symbol", { ascending: true });

    return ok({
      ok: true,
      user_id: user.id,
      balances: (balances || []).reduce((acc: any, b: any) => {
        acc[b.currency] = parseFloat(b.available) || 0;
        return acc;
      }, { USD: 0, USDT: 0 }),
      positions: positions || [],
      prices: (prices || []).map((p: any) => ({
        ...p,
        price_usd: parseFloat(p.price_usd) || 0
      })),
      last_updated: new Date().toISOString()
    });
  } catch (error) {
    console.error('Portfolio snapshot error:', error);
    return fail(500, { 
      ok: false, 
      error: "SERVER_ERROR", 
      detail: "Internal server error" 
    });
  }
});
