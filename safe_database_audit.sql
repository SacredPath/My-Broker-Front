-- Safe Database Audit - Only queries existing tables
-- This script first checks what exists, then runs safe queries

-- 1. Check which tables actually exist
SELECT 'TABLE_EXISTENCE_CHECK' as audit_type,
    table_name,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = t.table_name) THEN 'EXISTS' 
        ELSE 'MISSING' 
    END as status
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
ORDER BY table_name;

-- 2. Only check columns for tables that exist
DO $$
DECLARE
    table_record RECORD;
    sql_query TEXT;
BEGIN
    FOR table_record IN 
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name IN ('deposit_methods', 'profiles', 'admin_users', 'user_balances', 'transactions')
        ORDER BY table_name
    LOOP
        sql_query := format(
            'SELECT ''%s_COLUMNS'' as audit_type, column_name, data_type, is_nullable
             FROM information_schema.columns 
             WHERE table_name = ''%s'' 
             ORDER BY ordinal_position;',
            UPPER(table_record.table_name), table_record.table_name
        );
        
        RAISE NOTICE '=== Columns for %s ===', table_record.table_name;
        EXECUTE sql_query;
    END LOOP;
END $$;

-- 3. Safe data checks - only for existing tables
SELECT 'EXISTING_TABLES_DATA_CHECK' as audit_type,
    table_name,
    (SELECT COUNT(*) FROM information_schema.tables WHERE table_name = t.table_name) as exists_count
FROM (VALUES 
    ('deposit_methods'),
    ('profiles'), 
    ('admin_users'),
    ('user_balances'),
    ('transactions')
) AS t(table_name);

-- 4. Check data only in tables that exist
DO $$
DECLARE
    table_exists BOOLEAN;
BEGIN
    -- Check deposit_methods
    SELECT EXISTS(SELECT 1 FROM information_schema.tables WHERE table_name = 'deposit_methods') INTO table_exists;
    IF table_exists THEN
        RAISE NOTICE '=== DEPOSIT_METHODS DATA ===';
        RAISE NOTICE 'Total records: %', (SELECT COUNT(*) FROM deposit_methods);
        RAISE NOTICE 'Active records: %', (SELECT COUNT(*) FROM deposit_methods WHERE is_active = true);
    END IF;
    
    -- Check profiles
    SELECT EXISTS(SELECT 1 FROM information_schema.tables WHERE table_name = 'profiles') INTO table_exists;
    IF table_exists THEN
        RAISE NOTICE '=== PROFILES DATA ===';
        RAISE NOTICE 'Total users: %', (SELECT COUNT(*) FROM profiles);
        RAISE NOTICE 'Verified users: %', (SELECT COUNT(*) FROM profiles WHERE email_verified = true);
    END IF;
    
    -- Check admin_users
    SELECT EXISTS(SELECT 1 FROM information_schema.tables WHERE table_name = 'admin_users') INTO table_exists;
    IF table_exists THEN
        RAISE NOTICE '=== ADMIN_USERS DATA ===';
        RAISE NOTICE 'Total admins: %', (SELECT COUNT(*) FROM admin_users);
        RAISE NOTICE 'Active admins: %', (SELECT COUNT(*) FROM admin_users WHERE is_active = true);
    END IF;
    
    -- Check user_balances
    SELECT EXISTS(SELECT 1 FROM information_schema.tables WHERE table_name = 'user_balances') INTO table_exists;
    IF table_exists THEN
        RAISE NOTICE '=== USER_BALANCES DATA ===';
        RAISE NOTICE 'Total balance records: %', (SELECT COUNT(*) FROM user_balances);
        RAISE NOTICE 'Users with balances: %', (SELECT COUNT(DISTINCT user_id) FROM user_balances);
    END IF;
    
    -- Check transactions
    SELECT EXISTS(SELECT 1 FROM information_schema.tables WHERE table_name = 'transactions') INTO table_exists;
    IF table_exists THEN
        RAISE NOTICE '=== TRANSACTIONS DATA ===';
        RAISE NOTICE 'Total transactions: %', (SELECT COUNT(*) FROM transactions);
        RAISE NOTICE 'Completed transactions: %', (SELECT COUNT(*) FROM transactions WHERE status = 'completed');
    ELSE
        RAISE NOTICE '=== TRANSACTIONS TABLE MISSING ===';
    END IF;
END $$;

-- 5. Show what's missing completely
SELECT 'MISSING_TABLES_SUMMARY' as audit_type,
    COUNT(*) as total_expected_tables,
    (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public') as actual_tables,
    (42 - (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public')) as missing_tables
FROM (VALUES (1)) AS dummy;
