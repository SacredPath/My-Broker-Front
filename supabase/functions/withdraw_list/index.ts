import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { handleOptions } from "../_shared/cors.ts";
import { ok, fail } from "../_shared/respond.ts";
import { requireUser, loadProfile } from "../_shared/auth.ts";
import { adminClient } from "../_shared/auth.ts";

serve(async (req: Request) => {
  const pre = handleOptions(req);
  if (pre) return pre;

  try {
    // Auth required
    const { user } = await requireUser(req);
    
    // Load profile
    const profile = await loadProfile(user.id);
    
    const supabase = adminClient();
    
    // Get user's withdrawal history (limit 100, ordered by created_at desc)
    const { data: withdrawals, error } = await supabase
      .from('withdrawals')
      .select('*')
      .eq('user_id', user.id)
      .order('created_at', { ascending: false })
      .limit(100);
    
    if (error) {
      return fail(500, "DB_ERROR", "Failed to load withdrawal history", undefined, req);
    }
    
    return ok({
      withdrawals: withdrawals || []
    }, req);

  } catch (error: any) {
    if (error instanceof Response) return error;
    return fail(500, "SERVER_ERROR", String(error), undefined, req);
  }
});
