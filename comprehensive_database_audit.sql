-- Comprehensive Database Audit - Check for missing tables, columns, and data values
-- This script will identify what's missing in your new database

-- 1. Check if all expected tables exist
SELECT 'TABLE_EXISTENCE_CHECK' as audit_type,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'admin_balance_updates') THEN 'EXISTS' ELSE 'MISSING' END as admin_balance_updates,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'admin_deposit_method_updates') THEN 'EXISTS' ELSE 'MISSING' END as admin_deposit_method_updates,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'admin_users') THEN 'EXISTS' ELSE 'MISSING' END as admin_users,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'app_settings') THEN 'EXISTS' ELSE 'MISSING' END as app_settings,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'audit_log') THEN 'EXISTS' ELSE 'MISSING' END as audit_log,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'backoffice_roles') THEN 'EXISTS' ELSE 'MISSING' END as backoffice_roles,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'bonuses') THEN 'EXISTS' ELSE 'MISSING' END as bonuses,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'conversion_settings') THEN 'EXISTS' ELSE 'MISSING' END as conversion_settings,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'conversions') THEN 'EXISTS' ELSE 'MISSING' END as conversions,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'daily_autogrowth_log') THEN 'EXISTS' ELSE 'MISSING' END as daily_autogrowth_log;

-- Continue with more tables
SELECT 'TABLE_EXISTENCE_CHECK_2' as audit_type,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'deposit_methods') THEN 'EXISTS' ELSE 'MISSING' END as deposit_methods,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'deposit_requests') THEN 'EXISTS' ELSE 'MISSING' END as deposit_requests,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'deposits') THEN 'EXISTS' ELSE 'MISSING' END as deposits,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'email_verification_requests') THEN 'EXISTS' ELSE 'MISSING' END as email_verification_requests,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'fx_quotes') THEN 'EXISTS' ELSE 'MISSING' END as fx_quotes,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'investment_tiers') THEN 'EXISTS' ELSE 'MISSING' END as investment_tiers,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'kyc_applications') THEN 'EXISTS' ELSE 'MISSING' END as kyc_applications,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'kyc_documents') THEN 'EXISTS' ELSE 'MISSING' END as kyc_documents,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'kyc_submissions') THEN 'EXISTS' ELSE 'MISSING' END as kyc_submissions,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'notification_history') THEN 'EXISTS' ELSE 'MISSING' END as notification_history;

-- Continue with remaining tables
SELECT 'TABLE_EXISTENCE_CHECK_3' as audit_type,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'notification_preferences') THEN 'EXISTS' ELSE 'MISSING' END as notification_preferences,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'notification_settings') THEN 'EXISTS' ELSE 'MISSING' END as notification_settings,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'notifications') THEN 'EXISTS' ELSE 'MISSING' END as notifications,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'payout_methods') THEN 'EXISTS' ELSE 'MISSING' END as payout_methods,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'positions') THEN 'EXISTS' ELSE 'MISSING' END as positions,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'price_cache') THEN 'EXISTS' ELSE 'MISSING' END as price_cache,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'profiles') THEN 'EXISTS' ELSE 'MISSING' END as profiles,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'referrals') THEN 'EXISTS' ELSE 'MISSING' END as referrals,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'signal_access') THEN 'EXISTS' ELSE 'MISSING' END as signal_access,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'signal_purchases') THEN 'EXISTS' ELSE 'MISSING' END as signal_purchases;

-- Final batch of tables
SELECT 'TABLE_EXISTENCE_CHECK_4' as audit_type,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'signal_usdt_purchases') THEN 'EXISTS' ELSE 'MISSING' END as signal_usdt_purchases,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'signals') THEN 'EXISTS' ELSE 'MISSING' END as signals,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'support_tickets') THEN 'EXISTS' ELSE 'MISSING' END as support_tickets,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'tiers') THEN 'EXISTS' ELSE 'MISSING' END as tiers,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'trading_signals') THEN 'EXISTS' ELSE 'MISSING' END as trading_signals,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'transactions') THEN 'EXISTS' ELSE 'MISSING' END as transactions,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'unified_history') THEN 'EXISTS' ELSE 'MISSING' END as unified_history,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'user_balances') THEN 'EXISTS' ELSE 'MISSING' END as user_balances,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'user_positions') THEN 'EXISTS' ELSE 'MISSING' END as user_positions,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'user_withdrawal_methods') THEN 'EXISTS' ELSE 'MISSING' END as user_withdrawal_methods;

-- Last batch
SELECT 'TABLE_EXISTENCE_CHECK_5' as audit_type,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'wallet_balances') THEN 'EXISTS' ELSE 'MISSING' END as wallet_balances,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'wallet_ledger') THEN 'EXISTS' ELSE 'MISSING' END as wallet_ledger,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'withdrawal_methods') THEN 'EXISTS' ELSE 'MISSING' END as withdrawal_methods,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'withdrawal_requests') THEN 'EXISTS' ELSE 'MISSING' END as withdrawal_requests,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'withdrawals') THEN 'EXISTS' ELSE 'MISSING' END as withdrawals;

-- 2. Check critical table column structures (for tables that should exist)
SELECT 'DEPOSIT_METHODS_COLUMNS' as audit_type, column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'deposit_methods' 
ORDER BY ordinal_position;

SELECT 'PROFILES_COLUMNS' as audit_type, column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'profiles' 
ORDER BY ordinal_position;

SELECT 'ADMIN_USERS_COLUMNS' as audit_type, column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'admin_users' 
ORDER BY ordinal_position;

SELECT 'USER_BALANCES_COLUMNS' as audit_type, column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'user_balances' 
ORDER BY ordinal_position;

SELECT 'TRANSACTIONS_COLUMNS' as audit_type, column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'transactions' 
ORDER BY ordinal_position;

-- 3. Check for critical data values and data integrity
SELECT 'CRITICAL_DATA_CHECK' as audit_type,
    'deposit_methods' as table_name,
    COUNT(*) as total_records,
    COUNT(CASE WHEN is_active = true THEN 1 END) as active_records,
    COUNT(CASE WHEN method_type = 'crypto' THEN 1 END) as crypto_methods,
    COUNT(CASE WHEN method_type = 'bank' THEN 1 END) as bank_methods,
    COUNT(CASE WHEN method_type = 'paypal' THEN 1 END) as paypal_methods
FROM deposit_methods;

SELECT 'PROFILES_DATA_CHECK' as audit_type,
    'profiles' as table_name,
    COUNT(*) as total_users,
    COUNT(CASE WHEN email_verified = true THEN 1 END) as verified_users,
    COUNT(CASE WHEN kyc_status = 'approved' THEN 1 END) as kyc_approved,
    COUNT(CASE WHEN is_frozen = false THEN 1 END) as active_users,
    COUNT(CASE WHEN last_login > NOW() - INTERVAL '30 days' THEN 1 END) as recent_logins
FROM profiles;

SELECT 'ADMIN_USERS_DATA_CHECK' as audit_type,
    'admin_users' as table_name,
    COUNT(*) as total_admins,
    COUNT(CASE WHEN is_active = true THEN 1 END) as active_admins,
    STRING_AGG(DISTINCT role, ', ') as roles_present
FROM admin_users;

SELECT 'USER_BALANCES_DATA_CHECK' as audit_type,
    'user_balances' as table_name,
    COUNT(*) as total_balance_records,
    COUNT(DISTINCT user_id) as unique_users_with_balances,
    COUNT(DISTINCT currency) as unique_currencies,
    SUM(CASE WHEN amount > 0 THEN 1 END) as positive_balances,
    SUM(amount) as total_balance_sum
FROM user_balances;

SELECT 'TRANSACTIONS_DATA_CHECK' as audit_type,
    'transactions' as table_name,
    COUNT(*) as total_transactions,
    COUNT(DISTINCT user_id) as unique_users_with_transactions,
    COUNT(DISTINCT type) as transaction_types,
    COUNT(DISTINCT currency) as currencies_used,
    COUNT(CASE WHEN status = 'completed' THEN 1 END) as completed_transactions,
    COUNT(CASE WHEN status = 'pending' THEN 1 END) as pending_transactions
FROM transactions;

-- 4. Check for missing critical data that should exist
SELECT 'MISSING_CRITICAL_DATA' as audit_type,
    'Missing active deposit methods' as issue,
    CASE 
        WHEN (SELECT COUNT(*) FROM deposit_methods WHERE is_active = true) = 0 THEN 'CRITICAL'
        WHEN (SELECT COUNT(*) FROM deposit_methods WHERE is_active = true) < 2 THEN 'WARNING'
        ELSE 'OK'
    END as severity;

SELECT 'MISSING_CRITICAL_DATA' as audit_type,
    'Missing admin users' as issue,
    CASE 
        WHEN (SELECT COUNT(*) FROM admin_users WHERE is_active = true) = 0 THEN 'CRITICAL'
        ELSE 'OK'
    END as severity;

SELECT 'MISSING_CRITICAL_DATA' as audit_type,
    'Missing user profiles' as issue,
    CASE 
        WHEN (SELECT COUNT(*) FROM profiles) = 0 THEN 'WARNING'
        ELSE 'OK'
    END as severity;

-- 5. Check for data consistency issues
SELECT 'DATA_CONSISTENCY_CHECK' as audit_type,
    'Orphaned user_balances' as issue,
    COUNT(*) as count
FROM user_balances ub
LEFT JOIN profiles p ON ub.user_id = p.user_id
WHERE p.user_id IS NULL;

SELECT 'DATA_CONSISTENCY_CHECK' as audit_type,
    'Orphaned transactions' as issue,
    COUNT(*) as count
FROM transactions t
LEFT JOIN profiles p ON t.user_id = p.user_id
WHERE p.user_id IS NULL;

SELECT 'DATA_CONSISTENCY_CHECK' as audit_type,
    'Invalid KYC statuses' as issue,
    COUNT(*) as count
FROM profiles
WHERE kyc_status NOT IN ('pending', 'approved', 'rejected', 'not_submitted');

-- 6. Summary report
SELECT 'AUDIT_SUMMARY' as audit_type,
    'Database audit completed' as status,
    NOW() as audit_timestamp,
    'Review all sections above for missing items' as recommendation;
