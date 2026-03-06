-- DEPLOYMENT EXECUTION PLAN
-- Run these scripts in order to fix missing database objects

-- =====================================================
-- STEP 1: Create Core Tables (Dependencies First)
-- =====================================================

-- 1. Create audit_log_entries table (referenced by functions)
-- Run: create_audit_log_table.sql

-- 2. Create profiles table (required by handle_new_user function)
-- Run: create_profiles_table.sql

-- 3. Create user_positions table
-- Run: create_user_positions.sql

-- 4. Create investment_tiers table
-- Run: create_investment_tiers.sql

-- =====================================================
-- STEP 2: Create Functions
-- =====================================================

-- 5. Create handle_new_user function
-- Run: create_handle_new_user.sql

-- =====================================================
-- STEP 3: Create Additional Tables
-- =====================================================

-- 6. Create notification system
-- Run: create_notifications_system.sql

-- =====================================================
-- STEP 4: Verify Deployment
-- =====================================================

-- 7. Run final verification
-- Run: FINAL_WORKING_VERIFICATION.sql

-- =====================================================
-- QUICK EXECUTION - ALL IN ONE SCRIPT
-- =====================================================

-- NOTE: If you want to run everything at once, 
-- copy the contents of each script in the order above
-- or run them individually to better track any errors

-- =====================================================
-- CURRENT STATUS CHECK
-- =====================================================

-- Check what we have right now
SELECT '=== CURRENT DEPLOYMENT STATUS ===' as section;

SELECT 
    'Tables' as component,
    (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE')::text as current_count,
    '17' as needed,
    CASE 
        WHEN (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE') >= 15 THEN '✅ GOOD'
        WHEN (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE') >= 10 THEN '⚠️ PARTIAL'
        ELSE '❌ NEEDS WORK'
    END as status

UNION ALL

SELECT 
    'Functions' as component,
    (SELECT COUNT(*) FROM information_schema.routines WHERE routine_schema = 'public' AND routine_type = 'FUNCTION')::text as current_count,
    '9' as needed,
    CASE 
        WHEN (SELECT COUNT(*) FROM information_schema.routines WHERE routine_schema = 'public' AND routine_type = 'FUNCTION') >= 7 THEN '✅ GOOD'
        WHEN (SELECT COUNT(*) FROM information_schema.routines WHERE routine_schema = 'public' AND routine_type = 'FUNCTION') >= 4 THEN '⚠️ PARTIAL'
        ELSE '❌ NEEDS WORK'
    END as status

UNION ALL

SELECT 
    'Triggers' as component,
    (SELECT COUNT(*) FROM information_schema.triggers WHERE trigger_schema IN ('public', 'auth'))::text as current_count,
    '6' as needed,
    CASE 
        WHEN (SELECT COUNT(*) FROM information_schema.triggers WHERE trigger_schema IN ('public', 'auth')) >= 4 THEN '✅ GOOD'
        WHEN (SELECT COUNT(*) FROM information_schema.triggers WHERE trigger_schema IN ('public', 'auth')) >= 2 THEN '⚠️ PARTIAL'
        ELSE '❌ NEEDS WORK'
    END as status;

-- =====================================================
-- PRIORITY ACTIONS
-- =====================================================

SELECT '=== PRIORITY ACTIONS ===' as section;

SELECT 
    priority,
    action,
    script_to_run,
    reason
FROM (VALUES 
    (1, 'Create audit_log_entries table', 'create_audit_log_table.sql', 'Required by existing functions'),
    (2, 'Create profiles table', 'create_profiles_table.sql', 'Core user management'),
    (3, 'Create handle_new_user function', 'create_handle_new_user.sql', 'User registration workflow'),
    (4, 'Create user_positions table', 'create_user_positions.sql', 'Trading functionality'),
    (5, 'Create investment_tiers table', 'create_investment_tiers.sql', 'Investment system'),
    (6, 'Run final verification', 'FINAL_WORKING_VERIFICATION.sql', 'Confirm all objects deployed')
) AS priority_actions(priority, action, script_to_run, reason)
ORDER BY priority;
