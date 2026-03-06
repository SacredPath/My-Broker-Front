-- COMPLETE DEPLOYMENT VERIFICATION SCRIPT
-- Verifies all tables, columns, roles, triggers, functions are deployed
-- Trading Platform Database Deployment Status

-- =====================================================
-- 1. TABLES DEPLOYMENT STATUS
-- =====================================================
SELECT '=== TABLES DEPLOYMENT STATUS ===' as section;

SELECT 
    table_name,
    'TABLE' as object_type,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.tables 
            WHERE table_schema = 'public' AND table_name = t.table_name
        ) THEN '✅ DEPLOYED'
        ELSE '❌ MISSING'
    END as status,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.tables 
            WHERE table_schema = 'public' AND table_name = t.table_name
        ) THEN (
            SELECT pg_size_pretty(pg_total_relation_size('public.' || table_name)) 
            FROM information_schema.tables 
            WHERE table_schema = 'public' AND table_name = t.table_name
        )
        ELSE 'N/A'
    END as size
FROM (VALUES 
    -- Core User Tables
    ('profiles'), ('kyc_applications'), ('kyc_status'),
    -- Trading Tables
    ('user_positions'), ('investment_tiers'), ('positions'), ('wallet_balances'),
    -- Transaction Tables
    ('deposits'), ('withdrawals'), ('transactions'), ('payout_methods'), ('deposit_addresses'),
    -- Signal Tables
    ('trading_signals'), ('signal_purchases'), ('signal_access'),
    -- Notification Tables
    ('notifications'), ('notification_settings'),
    -- Audit Tables
    ('audit_log_entries'),
    -- Settings Tables
    ('settings'), ('app_settings')
) AS t(table_name)
ORDER BY table_name;

-- =====================================================
-- 2. COLUMNS VERIFICATION FOR CRITICAL TABLES
-- =====================================================
SELECT '=== CRITICAL TABLES COLUMN VERIFICATION ===' as section;

-- Profiles table columns
SELECT 
    'profiles' as table_name,
    'COLUMNS' as object_type,
    STRING_AGG(
        column_name || ':' || 
        CASE 
            WHEN column_name IN ('id', 'user_id', 'email', 'created_at') THEN '✅'
            WHEN column_name IN ('kyc_status', 'tier_level', 'balance', 'phone') THEN '⚠️'
            ELSE '📄'
        END, ', ' ORDER BY ordinal_position
    ) as status
FROM information_schema.columns 
WHERE table_schema = 'public' AND table_name = 'profiles'

UNION ALL

-- KYC applications table columns
SELECT 
    'kyc_applications' as table_name,
    'COLUMNS' as object_type,
    STRING_AGG(
        column_name || ':' || 
        CASE 
            WHEN column_name IN ('id', 'user_id', 'status', 'created_at') THEN '✅'
            WHEN column_name LIKE '%_url' THEN '📄'
            ELSE '📄'
        END, ', ' ORDER BY ordinal_position
    ) as status
FROM information_schema.columns 
WHERE table_schema = 'public' AND table_name = 'kyc_applications'

UNION ALL

-- User positions table columns
SELECT 
    'user_positions' as table_name,
    'COLUMNS' as object_type,
    STRING_AGG(
        column_name || ':' || 
        CASE 
            WHEN column_name IN ('id', 'user_id', 'tier_id', 'amount', 'status') THEN '✅'
            WHEN column_name IN ('unrealized_pnl', 'accrued_roi') THEN '💰'
            ELSE '📄'
        END, ', ' ORDER BY ordinal_position
    ) as status
FROM information_schema.columns 
WHERE table_schema = 'public' AND table_name = 'user_positions'

UNION ALL

-- Investment tiers table columns
SELECT 
    'investment_tiers' as table_name,
    'COLUMNS' as object_type,
    STRING_AGG(
        column_name || ':' || 
        CASE 
            WHEN column_name IN ('id', 'name', 'min_amount', 'daily_roi') THEN '✅'
            WHEN column_name IN ('investment_period_days', 'is_active') THEN '⚠️'
            ELSE '📄'
        END, ', ' ORDER BY ordinal_position
    ) as status
FROM information_schema.columns 
WHERE table_schema = 'public' AND table_name = 'investment_tiers';

-- =====================================================
-- 3. FUNCTIONS DEPLOYMENT STATUS
-- =====================================================
SELECT '=== FUNCTIONS DEPLOYMENT STATUS ===' as section;

SELECT 
    routine_name,
    'FUNCTION' as object_type,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.routines 
            WHERE routine_schema = 'public' AND routine_name = f.routine_name AND routine_type = 'FUNCTION'
        ) THEN '✅ DEPLOYED'
        ELSE '❌ MISSING'
    END as status,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.routines 
            WHERE routine_schema = 'public' AND routine_name = f.routine_name AND routine_type = 'FUNCTION'
        ) THEN (
            SELECT external_language FROM information_schema.routines 
            WHERE routine_schema = 'public' AND routine_name = f.routine_name AND routine_type = 'FUNCTION'
        )
        ELSE 'N/A'
    END as language
FROM (VALUES 
    -- Auth Functions
    ('handle_new_user'), ('handle_updated_at'),
    -- Trading Functions
    ('calculate_position_maturity'), ('set_position_maturity'), ('create_user_position'),
    -- Tier Functions
    ('tier_upgrade_rpc'), ('calculate_autogrowth'),
    -- Notification Functions
    ('send_notification'), ('update_notification_settings_updated_at'),
    -- Transaction Functions
    ('process_deposit'), ('process_withdrawal'),
    -- Signal Functions
    ('validate_signal_access'), ('create_signal_purchase')
) AS f(routine_name)
ORDER BY routine_name;

-- =====================================================
-- 4. TRIGGERS DEPLOYMENT STATUS
-- =====================================================
SELECT '=== TRIGGERS DEPLOYMENT STATUS ===' as section;

SELECT 
    trigger_name,
    'TRIGGER' as object_type,
    event_object_table as table_name,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.triggers 
            WHERE trigger_schema IN ('public', 'auth') AND trigger_name = t.trigger_name
        ) THEN '✅ DEPLOYED'
        ELSE '❌ MISSING'
    END as status,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.triggers 
            WHERE trigger_schema IN ('public', 'auth') AND trigger_name = t.trigger_name
        ) THEN (
            SELECT action_timing FROM information_schema.triggers 
            WHERE trigger_schema IN ('public', 'auth') AND trigger_name = t.trigger_name
        )
        ELSE 'N/A'
    END as timing
FROM (VALUES 
    -- Auth Triggers
    ('on_auth_user_created'), ('on_auth_user_updated'),
    -- Table Triggers
    ('handle_user_positions_updated_at'), ('trigger_set_position_maturity'),
    ('handle_investment_tiers_updated_at'), ('notification_settings_updated_at'),
    -- Audit Triggers
    ('audit_trigger_profiles'), ('audit_trigger_positions'), ('audit_trigger_transactions')
) AS t(trigger_name)
ORDER BY trigger_name;

-- =====================================================
-- 5. ROLES AND PERMISSIONS
-- =====================================================
SELECT '=== ROLES AND PERMISSIONS ===' as section;

-- Check for custom roles
SELECT 
    rolname as role_name,
    'ROLE' as object_type,
    CASE 
        WHEN rolname IN ('authenticated', 'service_role', 'anon') THEN '✅ SUPABASE ROLE'
        WHEN rolname LIKE '%admin%' OR rolname LIKE '%service%' THEN '⚠️ CUSTOM ROLE'
        ELSE '📄 OTHER ROLE'
    END as status,
    rolcreaterole as can_create_role,
    rolcreatedb as can_create_db,
    rolsuper as is_superuser
FROM pg_roles 
WHERE rolname NOT LIKE 'pg_%'
ORDER BY rolname;

-- =====================================================
-- 6. RLS POLICIES STATUS
-- =====================================================
SELECT '=== RLS POLICIES STATUS ===' as section;

SELECT 
    tablename as table_name,
    'RLS_POLICY' as object_type,
    COUNT(*) as policy_count,
    CASE 
        WHEN COUNT(*) > 0 THEN '✅ PROTECTED'
        ELSE '❌ UNPROTECTED'
    END as status,
    STRING_AGG(policyname, ', ' ORDER BY policyname) as policies
FROM pg_policies 
WHERE schemaname = 'public'
GROUP BY tablename
ORDER BY tablename;

-- =====================================================
-- 7. INDEXES STATUS
-- =====================================================
SELECT '=== CRITICAL INDEXES STATUS ===' as section;

SELECT 
    tablename,
    'INDEX' as object_type,
    COUNT(*) as index_count,
    CASE 
        WHEN COUNT(*) >= 2 THEN '✅ OPTIMIZED'
        WHEN COUNT(*) >= 1 THEN '⚠️ MINIMAL'
        ELSE '❌ NO INDEXES'
    END as status
FROM pg_indexes 
WHERE schemaname = 'public'
GROUP BY tablename
ORDER BY tablename;

-- =====================================================
-- 8. CONSTRAINTS STATUS
-- =====================================================
SELECT '=== CONSTRAINTS STATUS ===' as section;

SELECT 
    table_name,
    'CONSTRAINTS' as object_type,
    COUNT(*) as constraint_count,
    STRING_AGG(constraint_type, ', ' ORDER BY constraint_type) as types
FROM information_schema.table_constraints 
WHERE table_schema = 'public'
GROUP BY table_name
ORDER BY table_name;

-- =====================================================
-- 9. DEPLOYMENT SUMMARY
-- =====================================================
SELECT '=== DEPLOYMENT SUMMARY ===' as section;

SELECT 
    'Total Tables' as metric,
    COUNT(*)::text as deployed,
    (
        SELECT COUNT(*) FROM (VALUES 
            ('profiles'), ('kyc_applications'), ('kyc_status'), ('user_positions'), 
            ('investment_tiers'), ('positions'), ('wallet_balances'), ('deposits'), 
            ('withdrawals'), ('notifications'), ('audit_log_entries')
        ) AS t(table_name) WHERE EXISTS (
            SELECT 1 FROM information_schema.tables 
            WHERE table_schema = 'public' AND table_name = t.table_name
        )
    )::text as expected,
    CASE 
        WHEN COUNT(*) >= 10 THEN '✅ COMPLETE'
        WHEN COUNT(*) >= 7 THEN '⚠️ PARTIAL'
        ELSE '❌ INCOMPLETE'
    END as status
FROM information_schema.tables 
WHERE table_schema = 'public' AND table_type = 'BASE TABLE'

UNION ALL

SELECT 
    'Critical Functions' as metric,
    COUNT(*)::text as deployed,
    '8' as expected,
    CASE 
        WHEN COUNT(*) >= 6 THEN '✅ COMPLETE'
        WHEN COUNT(*) >= 4 THEN '⚠️ PARTIAL'
        ELSE '❌ INCOMPLETE'
    END as status
FROM information_schema.routines 
WHERE routine_schema = 'public' AND routine_type = 'FUNCTION'
    AND routine_name IN ('handle_new_user', 'handle_updated_at', 'calculate_position_maturity', 
                        'set_position_maturity', 'tier_upgrade_rpc', 'send_notification')

UNION ALL

SELECT 
    'Critical Triggers' as metric,
    COUNT(*)::text as deployed,
    '6' as expected,
    CASE 
        WHEN COUNT(*) >= 4 THEN '✅ COMPLETE'
        WHEN COUNT(*) >= 2 THEN '⚠️ PARTIAL'
        ELSE '❌ INCOMPLETE'
    END as status
FROM information_schema.triggers 
WHERE trigger_schema IN ('public', 'auth')
    AND trigger_name IN ('on_auth_user_created', 'handle_user_positions_updated_at', 
                        'trigger_set_position_maturity', 'handle_investment_tiers_updated_at')

UNION ALL

SELECT 
    'RLS Protected Tables' as metric,
    COUNT(DISTINCT tablename)::text as deployed,
    (
        SELECT COUNT(*) FROM information_schema.tables 
        WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
    )::text as expected,
    CASE 
        WHEN COUNT(DISTINCT tablename) >= 5 THEN '✅ SECURE'
        WHEN COUNT(DISTINCT tablename) >= 2 THEN '⚠️ PARTIAL'
        ELSE '❌ VULNERABLE'
    END as status
FROM pg_policies 
WHERE schemaname = 'public';

-- =====================================================
-- 10. IMMEDIATE ACTION ITEMS
-- =====================================================
SELECT '=== IMMEDIATE ACTION ITEMS ===' as section;

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
        WHEN NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'profiles')
        THEN '🟡 Add RLS policies to profiles table - Security requirement'
        WHEN NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'user_positions')
        THEN '🟡 CREATE user_positions table - Required for trading functionality'
        WHEN NOT EXISTS (SELECT 1 FROM information_schema.routines WHERE routine_schema = 'public' AND routine_name = 'calculate_position_maturity')
        THEN '🟡 CREATE calculate_position_maturity function - Trading logic'
        ELSE '✅ All critical objects deployed successfully'
    END as action_required;

-- =====================================================
-- END OF DEPLOYMENT VERIFICATION
-- =====================================================
