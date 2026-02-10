import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { handleOptions, ok, fail } from "../_shared/http.ts";
import { requireUser, adminClient } from "../_shared/auth.ts";

serve(async (req: Request) => {
  if (req.method === "OPTIONS") return handleOptions(req);

  try {
    // Auth required
    await requireUser(req);
    
    // Query active signals
    const supabase = adminClient();
    
    const { data, error } = await supabase
      .from("signals")
      .select("id,title,category,risk_rating,description,price_usdt,access_days,type,pdf_path,is_active,created_at")
      .eq("is_active", true)
      .order("created_at", { ascending: false });

    if (error) {
      return fail(req, 500, "DB_ERROR", "Failed to fetch signals");
    }

    const signals = (data || []).map(s => ({
      ...s,
      price_usdt: parseFloat(s.price_usdt) || 0
    }));

    return ok(req, { 
      signals
    });
  } catch (error) {
    if (error instanceof Response) return error;
    return fail(req, 500, "SERVER_ERROR", String(error));
  }
});
