import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { handleOptions, ok, fail } from "../_shared/http.ts";
import { requireUser, adminClient } from "../_shared/auth.ts";

serve(async (req: Request) => {
  if (req.method === "OPTIONS") return handleOptions(req);

  try {
    // Auth required
    const { user } = await requireUser(req);
    
    const supabase = adminClient();
    
    const { data, error } = await supabase
      .from("wallet_ledger")
      .select("id,currency,amount,reason,ref_table,ref_id,meta,created_at")
      .eq("user_id", user.id)
      .order("created_at", { ascending: false })
      .limit(50);

    if (error) {
      return fail(req, 500, "DB_ERROR", "Failed to fetch history");
    }

    const ledger = (data || []).map(entry => ({
      ...entry,
      amount: parseFloat(entry.amount) || 0
    }));

    return ok(req, { ledger });
  } catch (error) {
    if (error instanceof Response) return error;
    return fail(req, 500, "SERVER_ERROR", String(error));
  }
});
