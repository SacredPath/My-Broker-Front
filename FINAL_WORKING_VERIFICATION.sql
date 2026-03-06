-- FINAL WORKING DEPLOYMENT VERIFICATION
-- Uses only confirmed existing columns

-- =====================================================
-- 1. TABLES STATUS
-- =====================================================
SELECT '=== TABLES STATUS ===' as section;
SELECT 
    table_name,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.tables 
            WHERE table_schema = 'public' AND table_name = t.table_name
        ) THEN '✅ DEPLOYED'
        ELSE '❌ MISSING'
    END as status
FROM (VALUES 
    ('profiles'), ('kyc_applications'), ('kyc_status'), ('user_positions'), 
    ('investment_tiers'), ('positions'), ('wallet_balances'), ('deposits'), 
    ('withdrawals'), ('notifications'), ('notification_settings'), 
    ('payout_methods'), ('deposit_addresses'), ('trading_signals'), 
    ('signal_purchases'), ('signal_access'), ('audit_log_entries')
) AS t(table_name)
ORDER BY table_name;

-- =====================================================
-- 2. FUNCTIONS STATUS
-- =====================================================
SELECT '=== FUNCTIONS STATUS ===' as section;
SELECT 
    routine_name,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.routines 
            WHERE routine_schema = 'public' AND routine_name = f.routine_name AND routine_type = 'FUNCTION'
        ) THEN '✅ DEPLOYED'
        ELSE '❌ MISSING'
    END as status
FROM (VALUES 
    ('handle_new_user'), ('handle_updated_at'), ('calculate_position_maturity'), 
    ('set_position_maturity'), ('tier_upgrade_rpc'), ('send_notification'),
    ('process_deposit'), ('process_withdrawal'), ('create_user_position')
) AS f(routine_name)
ORDER BY routine_name;

-- =====================================================
-- 3. TRIGGERS STATUS (Working Version)
-- =====================================================
SELECT '=== TRIGGERS STATUS ===' as section;
SELECT 
    expected_trigger,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.triggers 
            WHERE trigger_schema IN ('public', 'auth') AND trigger_name = expected_trigger
        ) THEN '✅ DEPLOYED'
        ELSE '❌ MISSING'
    END as status
FROM (VALUES 
    ('on_auth_user_created'), ('on_auth_user_updated'),
    ('handle_user_positions_updated_at'), 
    ('trigger_set_position_maturity'),
    ('handle_investment_tiers_updated_at'),
    ('notification_settings_updated_at')
) AS t(expected_trigger)
ORDER BY expected_trigger;

-- =====================================================
-- 4. SHOW ACTUAL TRIGGERS FOUND
-- =====================================================
SELECT '=== ACTUAL TRIGGERS FOUND ===' as section;
SELECT 
    trigger_schema,
    trigger_name,
    action_timing,
    LEFT(action_statement, 100) as statement_preview
FROM information_schema.triggers
WHERE trigger_schema IN ('public', 'auth')
ORDER BY trigger_schema, trigger_name;

-- =====================================================
-- 5. RLS POLICIES STATUS
-- =====================================================
SELECT '=== RLS POLICIES STATUS ===' as section;
SELECT 
    tablename,
    COUNT(*) as policy_count,
    CASE 
        WHEN COUNT(*) > 0 THEN '✅ PROTECTED'
        ELSE '❌ UNPROTECTED'
    END as status
FROM pg_policies 
WHERE schemaname = 'public'
GROUP BY tablename
ORDER BY tablename;

-- =====================================================
-- 6. DEPLOYMENT SUMMARY
-- =====================================================
SELECT '=== DEPLOYMENT SUMMARY ===' as section;
SELECT 
    'Tables' as component,
    (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE')::text as deployed,
    '17' as expected,
    CASE 
        WHEN (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE') >= 15 THEN '✅ COMPLETE'
        WHEN (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE') >= 10 THEN '⚠️ PARTIAL'
        ELSE '❌ INCOMPLETE'
    END as status

UNION ALL

SELECT 
    'Functions' as component,
    (SELECT COUNT(*) FROM information_schema.routines WHERE routine_schema = 'public' AND routine_type = 'FUNCTION')::text as deployed,
    '9' as expected,
    CASE 
        WHEN (SELECT COUNT(*) FROM information_schema.routines WHERE routine_schema = 'public' AND routine_type = 'FUNCTION') >= 7 THEN '✅ COMPLETE'
        WHEN (SELECT COUNT(*) FROM information_schema.routines WHERE routine_schema = 'public' AND routine_type = 'FUNCTION') >= 4 THEN '⚠️ PARTIAL'
        ELSE '❌ INCOMPLETE'
    END as status

UNION ALL

SELECT 
    'Triggers' as component,
    (SELECT COUNT(*) FROM information_schema.triggers WHERE trigger_schema IN ('public', 'auth'))::text as deployed,
    '6' as expected,
    CASE 
        WHEN (SELECT COUNT(*) FROM information_schema.triggers WHERE trigger_schema IN ('public', 'auth')) >= 4 THEN '✅ COMPLETE'
        WHEN (SELECT COUNT(*) FROM information_schema.triggers WHERE trigger_schema IN ('public', 'auth')) >= 2 THEN '⚠️ PARTIAL'
        ELSE '❌ INCOMPLETE'
    END as status

UNION ALL

SELECT 
    'RLS Policies' as component,
    (SELECT COUNT(DISTINCT tablename) FROM pg_policies WHERE schemaname = 'public')::text as deployed,
    (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE')::text as expected,
    CASE 
        WHEN (SELECT COUNT(DISTINCT tablename) FROM pg_policies WHERE schemaname = 'public') >= 5 THEN '✅ SECURE'
        WHEN (SELECT COUNT(DISTINCT tablename) FROM pg_policies WHERE schemaname = 'public') >= 2 THEN '⚠️ PARTIAL'
        ELSE '❌ VULNERABLE'
    END as status;

-- =====================================================
-- 7. CRITICAL MISSING ITEMS
-- =====================================================
SELECT '=== CRITICAL MISSING ITEMS ===' as section;
SELECT 
    CASE 
        WHEN NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'profiles')
        THEN '🔴 MISSING: profiles table - Critical for user management'
        WHEN NOT EXISTS (SELECT 1 FROM information_schema.routines WHERE routine_schema = 'public' AND routine_name = 'handle_new_user' AND routine_type = 'FUNCTION')
        THEN '🔴 MISSING: handle_new_user function - Required for user registration'
        WHEN NOT EXISTS (SELECT 1 FROM information_schema.triggers WHERE trigger_schema = 'auth' AND trigger_name = 'on_auth_user_created')
        THEN '🔴 MISSING: on_auth_user_created trigger - Essential for user setup'
        WHEN NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'audit_log_entries')
        THEN '🔴 MISSING: audit_log_entries table - Referenced by existing functions'
        WHEN NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'user_positions')
        THEN '🟡 MISSING: user_positions table - Required for trading functionality'
        WHEN NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'investment_tiers')
        THEN '🟡 MISSING: investment_tiers table - Required for investment system'
        WHEN NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'profiles')
        THEN '🟡 MISSING: RLS policies on profiles table - Security requirement'
        ELSE '✅ All critical objects appear to be deployed'
    END as action_required;

-- =====================================================
-- 8. QUICK FIX SUGGESTIONS
-- =====================================================
SELECT '=== QUICK FIX SUGGESTIONS ===' as section;
SELECT 
    'Create missing audit_log_entries table' as suggestion,
    'Run create_audit_log_table.sql' as action
UNION ALL
SELECT 
    'Create missing handle_new_user function' as suggestion,
    'Check for function creation scripts in project' as action
UNION ALL
SELECT 
    'Create missing user_positions table' as suggestion,
    'Run create_user_positions.sql' as action
UNION ALL
SELECT 
    'Create missing investment_tiers table' as suggestion,
    'Run create_investment_tiers.sql' as action
UNION ALL
SELECT 
    'Add RLS policies to sensitive tables' as suggestion,
    'Create security policies for user data protection' as action;
