-- FINAL DATABASE CHECK - Uses only confirmed existing columns
-- Run this to check current deployment status

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
-- 3. TRIGGERS STATUS (Safe Version)
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
-- 4. SHOW ACTUAL TRIGGERS
-- =====================================================
SELECT '=== ACTUAL TRIGGERS FOUND ===' as section;
SELECT 
    trigger_schema,
    trigger_name,
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
-- 6. INVESTMENT TIERS VERIFICATION
-- =====================================================
SELECT '=== INVESTMENT TIERS VERIFICATION ===' as section;
SELECT 
    id,
    name,
    min_amount,
    max_amount,
    daily_roi,
    investment_period_days,
    sort_order,
    is_active,
    CASE 
        WHEN investment_period_days = 3 AND name = 'Tier 1' THEN '✅ CORRECT'
        WHEN investment_period_days = 7 AND name = 'Tier 2' THEN '✅ CORRECT'
        WHEN investment_period_days = 14 AND name = 'Tier 3' THEN '✅ CORRECT'
        WHEN investment_period_days = 30 AND name = 'Tier 4' THEN '✅ CORRECT'
        WHEN investment_period_days = 365 AND name = 'Tier 5' THEN '✅ CORRECT'
        ELSE '❌ INCORRECT PERIOD'
    END as period_status
FROM public.investment_tiers
ORDER BY sort_order;

-- =====================================================
-- 7. DEPLOYMENT SUMMARY
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
-- 8. REMAINING CRITICAL ITEMS
-- =====================================================
SELECT '=== REMAINING CRITICAL ITEMS ===' as section;
SELECT 
    CASE 
        WHEN NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'profiles')
        THEN '🔴 CREATE profiles table - Critical for user management'
        WHEN NOT EXISTS (SELECT 1 FROM information_schema.routines WHERE routine_schema = 'public' AND routine_name = 'handle_new_user' AND routine_type = 'FUNCTION')
        THEN '🔴 CREATE handle_new_user function - Required for user registration'
        WHEN NOT EXISTS (SELECT 1 FROM information_schema.triggers WHERE trigger_schema = 'auth' AND trigger_name = 'on_auth_user_created')
        THEN '🔴 CREATE on_auth_user_created trigger - Essential for user setup'
        WHEN NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'audit_log_entries')
        THEN '🔴 CREATE audit_log_entries table - Referenced by existing functions'
        WHEN NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'user_positions')
        THEN '🟡 CREATE user_positions table - Required for trading functionality'
        WHEN NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'profiles')
        THEN '🟡 ADD RLS policies to profiles table - Security requirement'
        ELSE '✅ All critical objects appear to be deployed correctly'
    END as action_required;
