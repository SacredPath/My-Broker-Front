-- Create Missing Row Level Security (RLS) Policies
-- Ensure proper data access control for all tables

-- 1. Enable RLS and create policies for tables without policies

-- admin_balance_updates
ALTER TABLE admin_balance_updates ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can manage admin balance updates" ON admin_balance_updates;
CREATE POLICY "Admins can manage admin balance updates" ON admin_balance_updates
    FOR ALL USING (auth.jwt() ->> 'role' IN ('support', 'superadmin'));

-- admin_deposit_method_updates (already has RLS disabled, enable it)
ALTER TABLE admin_deposit_method_updates ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can manage admin deposit method updates" ON admin_deposit_method_updates;
CREATE POLICY "Admins can manage admin deposit method updates" ON admin_deposit_method_updates
    FOR ALL USING (auth.jwt() ->> 'role' IN ('support', 'superadmin'));

-- admin_users
ALTER TABLE admin_users ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can manage admin users" ON admin_users;
CREATE POLICY "Admins can manage admin users" ON admin_users
    FOR ALL USING (auth.jwt() ->> 'role' IN ('support', 'superadmin'));

-- app_settings
ALTER TABLE app_settings ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can view app settings" ON app_settings;
CREATE POLICY "Anyone can view app settings" ON app_settings
    FOR SELECT USING (true);
DROP POLICY IF EXISTS "Admins can manage app settings" ON app_settings;
CREATE POLICY "Admins can manage app settings" ON app_settings
    FOR ALL USING (auth.jwt() ->> 'role' IN ('support', 'superadmin'));

-- audit_log
ALTER TABLE audit_log ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can view audit log" ON audit_log;
CREATE POLICY "Admins can view audit log" ON audit_log
    FOR SELECT USING (auth.jwt() ->> 'role' IN ('support', 'superadmin'));
DROP POLICY IF EXISTS "System can insert audit log" ON audit_log;
CREATE POLICY "System can insert audit log" ON audit_log
    FOR INSERT WITH CHECK (true);

-- bonuses
ALTER TABLE bonuses ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view own bonuses" ON bonuses;
CREATE POLICY "Users can view own bonuses" ON bonuses
    FOR SELECT USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "Admins can manage bonuses" ON bonuses;
CREATE POLICY "Admins can manage bonuses" ON bonuses
    FOR ALL USING (auth.jwt() ->> 'role' IN ('support', 'superadmin'));

-- conversion_settings
ALTER TABLE conversion_settings ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can view conversion settings" ON conversion_settings;
CREATE POLICY "Anyone can view conversion settings" ON conversion_settings
    FOR SELECT USING (true);
DROP POLICY IF EXISTS "Admins can manage conversion settings" ON conversion_settings;
CREATE POLICY "Admins can manage conversion settings" ON conversion_settings
    FOR ALL USING (auth.jwt() ->> 'role' IN ('support', 'superadmin'));

-- daily_autogrowth_log
ALTER TABLE daily_autogrowth_log ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can view autogrowth log" ON daily_autogrowth_log;
CREATE POLICY "Admins can view autogrowth log" ON daily_autogrowth_log
    FOR SELECT USING (auth.jwt() ->> 'role' IN ('support', 'superadmin'));
DROP POLICY IF EXISTS "System can insert autogrowth log" ON daily_autogrowth_log;
CREATE POLICY "System can insert autogrowth log" ON daily_autogrowth_log
    FOR INSERT WITH CHECK (true);

-- deposits
ALTER TABLE deposits ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view own deposits" ON deposits;
CREATE POLICY "Users can view own deposits" ON deposits
    FOR SELECT USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "Admins can manage deposits" ON deposits;
CREATE POLICY "Admins can manage deposits" ON deposits
    FOR ALL USING (auth.jwt() ->> 'role' IN ('support', 'superadmin'));
DROP POLICY IF EXISTS "System can insert deposits" ON deposits;
CREATE POLICY "System can insert deposits" ON deposits
    FOR INSERT WITH CHECK (true);

-- fx_quotes
ALTER TABLE fx_quotes ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can view fx quotes" ON fx_quotes;
CREATE POLICY "Anyone can view fx quotes" ON fx_quotes
    FOR SELECT USING (true);
DROP POLICY IF EXISTS "System can manage fx quotes" ON fx_quotes;
CREATE POLICY "System can manage fx quotes" ON fx_quotes
    FOR ALL USING (auth.jwt() ->> 'role' = 'service_role');

-- investment_tiers
ALTER TABLE investment_tiers ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can view investment tiers" ON investment_tiers;
CREATE POLICY "Anyone can view investment tiers" ON investment_tiers
    FOR SELECT USING (true);
DROP POLICY IF EXISTS "Admins can manage investment tiers" ON investment_tiers;
CREATE POLICY "Admins can manage investment tiers" ON investment_tiers
    FOR ALL USING (auth.jwt() ->> 'role' IN ('support', 'superadmin'));

-- notification_settings
ALTER TABLE notification_settings ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can manage own notification settings" ON notification_settings;
CREATE POLICY "Users can manage own notification settings" ON notification_settings
    FOR ALL USING (auth.uid() = user_id);

-- notifications
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view own notifications" ON notifications;
CREATE POLICY "Users can view own notifications" ON notifications
    FOR SELECT USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "System can insert notifications" ON notifications;
CREATE POLICY "System can insert notifications" ON notifications
    FOR INSERT WITH CHECK (true);
DROP POLICY IF EXISTS "Users can update own notifications" ON notifications;
CREATE POLICY "Users can update own notifications" ON notifications
    FOR UPDATE USING (auth.uid() = user_id);

-- positions
ALTER TABLE positions ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view own positions" ON positions;
CREATE POLICY "Users can view own positions" ON positions
    FOR SELECT USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "Admins can manage positions" ON positions;
CREATE POLICY "Admins can manage positions" ON positions
    FOR ALL USING (auth.jwt() ->> 'role' IN ('support', 'superadmin'));

-- price_cache
ALTER TABLE price_cache ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can view price cache" ON price_cache;
CREATE POLICY "Anyone can view price cache" ON price_cache
    FOR SELECT USING (true);
DROP POLICY IF EXISTS "System can manage price cache" ON price_cache;
CREATE POLICY "System can manage price cache" ON price_cache
    FOR ALL USING (auth.jwt() ->> 'role' = 'service_role');

-- profiles
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
CREATE POLICY "Users can view own profile" ON profiles
    FOR SELECT USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
CREATE POLICY "Users can update own profile" ON profiles
    FOR UPDATE USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "Admins can view all profiles" ON profiles;
CREATE POLICY "Admins can view all profiles" ON profiles
    FOR SELECT USING (auth.jwt() ->> 'role' IN ('support', 'superadmin'));

-- referrals
ALTER TABLE referrals ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view own referrals" ON referrals;
CREATE POLICY "Users can view own referrals" ON referrals
    FOR SELECT USING (auth.uid() = referrer_user_id OR auth.uid() = referred_user_id);
DROP POLICY IF EXISTS "Admins can manage referrals" ON referrals;
CREATE POLICY "Admins can manage referrals" ON referrals
    FOR ALL USING (auth.jwt() ->> 'role' IN ('support', 'superadmin'));

-- signal_access
ALTER TABLE signal_access ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view own signal access" ON signal_access;
CREATE POLICY "Users can view own signal access" ON signal_access
    FOR SELECT USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "System can manage signal access" ON signal_access;
CREATE POLICY "System can manage signal access" ON signal_access
    FOR ALL USING (auth.jwt() ->> 'role' = 'service_role');

-- signals
ALTER TABLE signals ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can view active signals" ON signals;
CREATE POLICY "Anyone can view active signals" ON signals
    FOR SELECT USING (is_active = true);
DROP POLICY IF EXISTS "Admins can manage signals" ON signals;
CREATE POLICY "Admins can manage signals" ON signals
    FOR ALL USING (auth.jwt() ->> 'role' IN ('support', 'superadmin'));

-- tiers
ALTER TABLE tiers ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can view tiers" ON tiers;
CREATE POLICY "Anyone can view tiers" ON tiers
    FOR SELECT USING (true);
DROP POLICY IF EXISTS "Admins can manage tiers" ON tiers;
CREATE POLICY "Admins can manage tiers" ON tiers
    FOR ALL USING (auth.jwt() ->> 'role' IN ('support', 'superadmin'));

-- trading_signals
ALTER TABLE trading_signals ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can view trading signals" ON trading_signals;
CREATE POLICY "Anyone can view trading signals" ON trading_signals
    FOR SELECT USING (true);
DROP POLICY IF EXISTS "Admins can manage trading signals" ON trading_signals;
CREATE POLICY "Admins can manage trading signals" ON trading_signals
    FOR ALL USING (auth.jwt() ->> 'role' IN ('support', 'superadmin'));

-- user_balances (already has policy, but ensure it's correct)
DROP POLICY IF EXISTS "Users can manage own user balances" ON user_balances;
CREATE POLICY "Users can manage own user balances" ON user_balances
    FOR ALL USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "Admins can view all user balances" ON user_balances;
CREATE POLICY "Admins can view all user balances" ON user_balances
    FOR SELECT USING (auth.jwt() ->> 'role' IN ('support', 'superadmin'));

-- user_withdrawal_methods
ALTER TABLE user_withdrawal_methods ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can manage own withdrawal methods" ON user_withdrawal_methods;
CREATE POLICY "Users can manage own withdrawal methods" ON user_withdrawal_methods
    FOR ALL USING (auth.uid() = user_id);

-- withdrawal_requests
ALTER TABLE withdrawal_requests ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view own withdrawal requests" ON withdrawal_requests;
CREATE POLICY "Users can view own withdrawal requests" ON withdrawal_requests
    FOR SELECT USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "Users can create withdrawal requests" ON withdrawal_requests;
CREATE POLICY "Users can create withdrawal requests" ON withdrawal_requests
    FOR INSERT WITH CHECK (auth.uid() = user_id);
DROP POLICY IF EXISTS "Admins can manage withdrawal requests" ON withdrawal_requests;
CREATE POLICY "Admins can manage withdrawal requests" ON withdrawal_requests
    FOR ALL USING (auth.jwt() ->> 'role' IN ('support', 'superadmin'));

-- withdrawals
ALTER TABLE withdrawals ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view own withdrawals" ON withdrawals;
CREATE POLICY "Users can view own withdrawals" ON withdrawals
    FOR SELECT USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "Admins can manage withdrawals" ON withdrawals;
CREATE POLICY "Admins can manage withdrawals" ON withdrawals
    FOR ALL USING (auth.jwt() ->> 'role' IN ('support', 'superadmin'));
DROP POLICY IF EXISTS "System can insert withdrawals" ON withdrawals;
CREATE POLICY "System can insert withdrawals" ON withdrawals
    FOR INSERT WITH CHECK (true);

-- Verify RLS policies were created
SELECT 'RLS_POLICIES_CREATED' as status,
       COUNT(*) as policy_count
FROM pg_policies 
WHERE schemaname = 'public';
