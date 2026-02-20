-- Identify exactly which tables are missing from your database

SELECT 'MISSING_TABLES_LIST' as audit_type, table_name as missing_table
FROM (VALUES 
    ('admin_balance_updates'),
    ('admin_deposit_method_updates'),
    ('admin_users'),
    ('app_settings'),
    ('audit_log'),
    ('backoffice_roles'),
    ('bonuses'),
    ('conversion_settings'),
    ('conversions'),
    ('daily_autogrowth_log'),
    ('deposit_methods'),
    ('deposit_requests'),
    ('deposits'),
    ('email_verification_requests'),
    ('fx_quotes'),
    ('investment_tiers'),
    ('kyc_applications'),
    ('kyc_documents'),
    ('kyc_submissions'),
    ('notification_history'),
    ('notification_preferences'),
    ('notification_settings'),
    ('notifications'),
    ('payout_methods'),
    ('positions'),
    ('price_cache'),
    ('profiles'),
    ('referrals'),
    ('signal_access'),
    ('signal_purchases'),
    ('signal_usdt_purchases'),
    ('signals'),
    ('support_tickets'),
    ('tiers'),
    ('trading_signals'),
    ('transactions'),
    ('unified_history'),
    ('user_balances'),
    ('user_positions'),
    ('user_withdrawal_methods'),
    ('wallet_balances'),
    ('wallet_ledger'),
    ('withdrawal_methods'),
    ('withdrawal_requests'),
    ('withdrawals')
) AS t(table_name)
WHERE NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = t.table_name AND table_schema = 'public')
ORDER BY table_name;

-- Also show which tables DO exist for comparison
SELECT 'EXISTING_TABLES_LIST' as audit_type, table_name as existing_table
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN (
    'admin_balance_updates', 'admin_deposit_method_updates', 'admin_users', 'app_settings', 'audit_log',
    'backoffice_roles', 'bonuses', 'conversion_settings', 'conversions', 'daily_autogrowth_log',
    'deposit_methods', 'deposit_requests', 'deposits', 'email_verification_requests', 'fx_quotes',
    'investment_tiers', 'kyc_applications', 'kyc_documents', 'kyc_submissions', 'notification_history',
    'notification_preferences', 'notification_settings', 'notifications', 'payout_methods', 'positions',
    'price_cache', 'profiles', 'referrals', 'signal_access', 'signal_purchases', 'signal_usdt_purchases',
    'signals', 'support_tickets', 'tiers', 'trading_signals', 'transactions', 'unified_history',
    'user_balances', 'user_positions', 'user_withdrawal_methods', 'wallet_balances', 'wallet_ledger',
    'withdrawal_methods', 'withdrawal_requests', 'withdrawals'
)
ORDER BY table_name;
