import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { handleOptions, ok, fail } from "../_shared/http.ts";
import { requireUser, adminClient } from "../_shared/auth.ts";

serve(async (req: Request) => {
  if (req.method === "OPTIONS") return handleOptions(req);

  try {
    // Auth required
    await requireUser(req);
    
    const supabase = adminClient();
    
    const { data, error } = await supabase
      .from("app_settings")
      .select("conversion_fee_fixed_usd, conversion_fee_pct, fx_markup_pct")
      .eq("id", 1)
      .single();

    if (error || !data) {
      return ok(req, {
        settings: {
          conversion_fee_fixed_usd: 0,
          conversion_fee_pct: 0,
          fx_markup_pct: 0
        }
      });
    }

    return ok(req, {
      settings: {
        conversion_fee_fixed_usd: parseFloat(data.conversion_fee_fixed_usd) || 0,
        conversion_fee_pct: parseFloat(data.conversion_fee_pct) || 0,
        fx_markup_pct: parseFloat(data.fx_markup_pct) || 0
      }
    });
  } catch (error) {
    if (error instanceof Response) return error;
    return fail(req, 500, "SERVER_ERROR", String(error));
  }
});
