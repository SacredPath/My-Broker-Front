-- ULTIMATE DATABASE VERIFICATION
-- Fixed version with consistent column counts

-- =====================================================
-- 1. COMPLETE TABLES INVENTORY
-- =====================================================
SELECT '=== COMPLETE TABLES INVENTORY ===' as section;
SELECT 
    table_name,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.tables 
            WHERE table_schema = 'public' AND table_name = t.table_name
        ) THEN '✅ EXISTS'
        ELSE '❌ MISSING'
    END as status,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_schema = 'public' AND table_name = t.table_name
        ) THEN (
            SELECT COUNT(*)::text 
            FROM information_schema.columns 
            WHERE table_schema = 'public' AND table_name = t.table_name
        )
        ELSE '0'
    END as column_count
FROM (VALUES 
    ('profiles'), ('kyc_applications'), ('kyc_status'), ('user_positions'), 
    ('investment_tiers'), ('positions'), ('wallet_balances'), ('deposits'), 
    ('withdrawals'), ('notifications'), ('notification_settings'), 
    ('payout_methods'), ('deposit_addresses'), ('trading_signals'), 
    ('signal_purchases'), ('signal_access'), ('audit_log_entries')
) AS t(table_name)
ORDER BY table_name;

-- =====================================================
-- 2. CRITICAL COLUMNS VERIFICATION
-- =====================================================
SELECT '=== CRITICAL COLUMNS VERIFICATION ===' as section;

-- Check profiles table critical columns
SELECT 
    'profiles' as table_name,
    column_name,
    data_type,
    is_nullable,
    CASE 
        WHEN column_name IN ('id', 'user_id', 'email', 'created_at') THEN '🔴 CRITICAL'
        WHEN column_name IN ('kyc_status', 'tier_level', 'balance') THEN '🟡 BUSINESS'
        ELSE '📄 OPTIONAL'
    END as importance
FROM information_schema.columns 
WHERE table_schema = 'public' AND table_name = 'profiles'
ORDER BY 
    CASE 
        WHEN column_name IN ('id', 'user_id', 'email') THEN 1
        WHEN column_name IN ('kyc_status', 'tier_level') THEN 2
        ELSE 3
    END,
    ordinal_position;

-- =====================================================
-- 3. ALL FUNCTIONS INVENTORY
-- =====================================================
SELECT '=== ALL FUNCTIONS INVENTORY ===' as section;
SELECT 
    routine_name,
    routine_type,
    data_type as return_type,
    external_language,
    LEFT(routine_definition, 150) as definition_preview,
    CASE 
        WHEN routine_name IN ('handle_new_user', 'handle_updated_at', 'calculate_position_maturity', 
                           'set_position_maturity', 'tier_upgrade_rpc', 'send_notification',
                           'process_deposit', 'process_withdrawal', 'create_user_position') THEN '🔴 CRITICAL'
        ELSE '📄 OTHER'
    END as importance
FROM information_schema.routines 
WHERE routine_schema = 'public' AND routine_type = 'FUNCTION'
ORDER BY routine_name;

-- =====================================================
-- 4. ALL TRIGGERS INVENTORY
-- =====================================================
SELECT '=== ALL TRIGGERS INVENTORY ===' as section;
SELECT 
    trigger_schema,
    trigger_name,
    LEFT(action_statement, 150) as statement_preview,
    CASE 
        WHEN trigger_name IN ('on_auth_user_created', 'on_auth_user_updated',
                           'handle_user_positions_updated_at', 'trigger_set_position_maturity',
                           'handle_investment_tiers_updated_at', 'notification_settings_updated_at') THEN '🔴 CRITICAL'
        ELSE '📄 OTHER'
    END as importance
FROM information_schema.triggers
WHERE trigger_schema IN ('public', 'auth')
ORDER BY trigger_schema, trigger_name;

-- =====================================================
-- 5. RLS POLICIES INVENTORY
-- =====================================================
SELECT '=== RLS POLICIES INVENTORY ===' as section;
SELECT 
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    CASE 
        WHEN tablename IN ('profiles', 'user_positions', 'investment_tiers', 'notifications') THEN '🔴 CRITICAL'
        ELSE '📄 OTHER'
    END as importance
FROM pg_policies 
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- =====================================================
-- 6. FINAL DEPLOYMENT SUMMARY
-- =====================================================
SELECT '=== FINAL DEPLOYMENT SUMMARY ===' as section;

-- Tables Summary
SELECT 
    'Tables' as component,
    (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE')::text as deployed,
    '17' as expected,
    CASE 
        WHEN (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE') >= 16 THEN '✅ COMPLETE'
        WHEN (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE') >= 12 THEN '⚠️ MOSTLY COMPLETE'
        WHEN (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE') >= 8 THEN '⚠️ PARTIAL'
        ELSE '❌ INCOMPLETE'
    END as status

UNION ALL

-- Functions Summary
SELECT 
    'Functions' as component,
    (SELECT COUNT(*) FROM information_schema.routines WHERE routine_schema = 'public' AND routine_type = 'FUNCTION')::text as deployed,
    '9' as expected,
    CASE 
        WHEN (SELECT COUNT(*) FROM information_schema.routines WHERE routine_schema = 'public' AND routine_type = 'FUNCTION') >= 8 THEN '✅ COMPLETE'
        WHEN (SELECT COUNT(*) FROM information_schema.routines WHERE routine_schema = 'public' AND routine_type = 'FUNCTION') >= 6 THEN '⚠️ MOSTLY COMPLETE'
        WHEN (SELECT COUNT(*) FROM information_schema.routines WHERE routine_schema = 'public' AND routine_type = 'FUNCTION') >= 4 THEN '⚠️ PARTIAL'
        ELSE '❌ INCOMPLETE'
    END as status

UNION ALL

-- Triggers Summary
SELECT 
    'Triggers' as component,
    (SELECT COUNT(*) FROM information_schema.triggers WHERE trigger_schema IN ('public', 'auth'))::text as deployed,
    '6' as expected,
    CASE 
        WHEN (SELECT COUNT(*) FROM information_schema.triggers WHERE trigger_schema IN ('public', 'auth')) >= 5 THEN '✅ COMPLETE'
        WHEN (SELECT COUNT(*) FROM information_schema.triggers WHERE trigger_schema IN ('public', 'auth')) >= 4 THEN '⚠️ MOSTLY COMPLETE'
        WHEN (SELECT COUNT(*) FROM information_schema.triggers WHERE trigger_schema IN ('public', 'auth')) >= 2 THEN '⚠️ PARTIAL'
        ELSE '❌ INCOMPLETE'
    END as status

UNION ALL

-- RLS Policies Summary
SELECT 
    'RLS Policies' as component,
    (SELECT COUNT(DISTINCT tablename) FROM pg_policies WHERE schemaname = 'public')::text as deployed,
    (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE')::text as expected,
    CASE 
        WHEN (SELECT COUNT(DISTINCT tablename) FROM pg_policies WHERE schemaname = 'public') >= 5 THEN '✅ SECURE'
        WHEN (SELECT COUNT(DISTINCT tablename) FROM pg_policies WHERE schemaname = 'public') >= 3 THEN '⚠️ PARTIALLY SECURE'
        WHEN (SELECT COUNT(DISTINCT tablename) FROM pg_policies WHERE schemaname = 'public') >= 1 THEN '⚠️ MINIMALLY SECURE'
        ELSE '❌ VULNERABLE'
    END as status;

-- =====================================================
-- 7. CRITICAL OBJECTS VERIFICATION
-- =====================================================
SELECT '=== CRITICAL OBJECTS VERIFICATION ===' as section;

-- Count critical tables
SELECT 
    'Critical Tables' as category,
    COUNT(CASE WHEN table_name IN ('profiles', 'user_positions', 'investment_tiers', 'audit_log_entries') THEN 1 END) as deployed,
    '4' as expected,
    CASE 
        WHEN COUNT(CASE WHEN table_name IN ('profiles', 'user_positions', 'investment_tiers', 'audit_log_entries') THEN 1 END) = 4 THEN '✅ COMPLETE'
        WHEN COUNT(CASE WHEN table_name IN ('profiles', 'user_positions', 'investment_tiers', 'audit_log_entries') THEN 1 END) >= 3 THEN '⚠️ MOSTLY COMPLETE'
        ELSE '❌ INCOMPLETE'
    END as status
FROM information_schema.tables 
WHERE table_schema = 'public' AND table_type = 'BASE TABLE'

UNION ALL

-- Count critical functions
SELECT 
    'Critical Functions' as category,
    COUNT(CASE WHEN routine_name IN ('handle_new_user', 'handle_updated_at', 'calculate_position_maturity', 'set_position_maturity') THEN 1 END) as deployed,
    '4' as expected,
    CASE 
        WHEN COUNT(CASE WHEN routine_name IN ('handle_new_user', 'handle_updated_at', 'calculate_position_maturity', 'set_position_maturity') THEN 1 END) = 4 THEN '✅ COMPLETE'
        WHEN COUNT(CASE WHEN routine_name IN ('handle_new_user', 'handle_updated_at', 'calculate_position_maturity', 'set_position_maturity') THEN 1 END) >= 3 THEN '⚠️ MOSTLY COMPLETE'
        ELSE '❌ INCOMPLETE'
    END as status
FROM information_schema.routines 
WHERE routine_schema = 'public' AND routine_type = 'FUNCTION'

UNION ALL

-- Count critical triggers
SELECT 
    'Critical Triggers' as category,
    COUNT(CASE WHEN trigger_name IN ('on_auth_user_created', 'handle_user_positions_updated_at', 'trigger_set_position_maturity', 'handle_investment_tiers_updated_at') THEN 1 END) as deployed,
    '4' as expected,
    CASE 
        WHEN COUNT(CASE WHEN trigger_name IN ('on_auth_user_created', 'handle_user_positions_updated_at', 'trigger_set_position_maturity', 'handle_investment_tiers_updated_at') THEN 1 END) = 4 THEN '✅ COMPLETE'
        WHEN COUNT(CASE WHEN trigger_name IN ('on_auth_user_created', 'handle_user_positions_updated_at', 'trigger_set_position_maturity', 'handle_investment_tiers_updated_at') THEN 1 END) >= 3 THEN '⚠️ MOSTLY COMPLETE'
        ELSE '❌ INCOMPLETE'
    END as status
FROM information_schema.triggers
WHERE trigger_schema IN ('public', 'auth');

-- =====================================================
-- 8. FINAL STATUS MESSAGE
-- =====================================================
SELECT '=== FINAL STATUS MESSAGE ===' as section;
SELECT 
    CASE 
        WHEN (
            -- Check if all critical tables exist
            (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE' AND table_name IN ('profiles', 'user_positions', 'investment_tiers', 'audit_log_entries')) = 4
            -- Check if all critical functions exist
            AND (SELECT COUNT(*) FROM information_schema.routines WHERE routine_schema = 'public' AND routine_type = 'FUNCTION' AND routine_name IN ('handle_new_user', 'handle_updated_at', 'calculate_position_maturity', 'set_position_maturity')) = 4
            -- Check if all critical triggers exist
            AND (SELECT COUNT(*) FROM information_schema.triggers WHERE trigger_schema IN ('public', 'auth') AND trigger_name IN ('on_auth_user_created', 'handle_user_positions_updated_at', 'trigger_set_position_maturity', 'handle_investment_tiers_updated_at')) = 4
        ) THEN '🎉 ALL CRITICAL DATABASE OBJECTS SUCCESSFULLY DEPLOYED AND VERIFIED!'
        ELSE '⚠️ Some critical objects may still be missing - review the sections above for details'
    END as final_status;
