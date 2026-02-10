import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { handleOptions } from "../_shared/cors.ts";
import { ok, fail } from "../_shared/respond.ts";
import { requireUser, loadProfile } from "../_shared/auth.ts";
import { adminClient } from "../_shared/auth.ts";
import { parseUSD, parseUSDT, safeNumber } from "../_shared/money.ts";

serve(async (req: Request) => {
  const pre = handleOptions(req);
  if (pre) return pre;

  try {
    // Auth required
    const { user } = await requireUser(req);
    
    // Load profile
    const profile = await loadProfile(user.id);
    
    const supabase = adminClient();
    
    // Load app settings for daily caps
    const { data: settings } = await supabase
      .from('app_settings')
      .select('withdrawal_daily_cap_usd, withdrawal_daily_cap_usdt')
      .eq('id', 1)
      .single();
    
    const dailyCapUSD = safeNumber(settings?.withdrawal_daily_cap_usd || 10000);
    const dailyCapUSDT = safeNumber(settings?.withdrawal_daily_cap_usdt || 10000);
    
    // Compute today's totals (UTC date) from withdrawals
    const todayUTC = new Date().toISOString().split('T')[0];
    const { data: todayWithdrawals } = await supabase
      .from('withdrawals')
      .select('currency, amount, fee_amount')
      .eq('user_id', user.id)
      .in('status', ['pending', 'approved', 'paid'])
      .gte('created_at', todayUTC)
      .lt('created_at', todayUTC + 'T23:59:59.999Z');
    
    let usedTodayUSD = 0;
    let usedTodayUSDT = 0;
    
    if (todayWithdrawals) {
      for (const withdrawal of todayWithdrawals) {
        if (withdrawal.currency === 'USD') {
          usedTodayUSD += safeNumber(withdrawal.amount) + safeNumber(withdrawal.fee_amount || 0);
        } else if (withdrawal.currency === 'USDT') {
          usedTodayUSDT += safeNumber(withdrawal.amount) + safeNumber(withdrawal.fee_amount || 0);
        }
      }
    }
    
    const remainingTodayUSD = Math.max(0, dailyCapUSD - usedTodayUSD);
    const remainingTodayUSDT = Math.max(0, dailyCapUSDT - usedTodayUSDT);
    
    return ok({
      caps: {
        USD: dailyCapUSD,
        USDT: dailyCapUSDT
      },
      used_today: {
        USD: usedTodayUSD,
        USDT: usedTodayUSDT
      },
      remaining_today: {
        USD: remainingTodayUSD,
        USDT: remainingTodayUSDT
      }
    }, req);

  } catch (error: any) {
    if (error instanceof Response) return error;
    return fail(500, "SERVER_ERROR", String(error), undefined, req);
  }
});
