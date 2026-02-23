-- Comprehensive fix for registration issue
-- Check for all possible triggers and constraints that might be interfering

-- 1. Check for any remaining triggers on auth.users
SELECT 'CHECKING_AUTH_TRIGGERS' as info,
       trigger_name,
       event_manipulation,
       event_object_table,
       action_timing,
       action_statement
FROM information_schema.triggers 
WHERE event_object_table = 'users' 
    AND trigger_schema = 'auth'
ORDER BY trigger_name;

-- 2. Check for any triggers on public.profiles that might interfere
SELECT 'CHECKING_PROFILES_TRIGGERS' as info,
       trigger_name,
       event_manipulation,
       event_object_table,
       action_timing,
       action_statement
FROM information_schema.triggers 
WHERE event_object_table = 'profiles' 
    AND trigger_schema = 'public'
ORDER BY trigger_name;

-- 3. Check for any foreign key constraints that might be causing issues
SELECT 'CHECKING_CONSTRAINTS' as info,
       tc.table_name,
       tc.constraint_name,
       tc.constraint_type,
       kcu.column_name,
       ccu.table_name AS foreign_table_name,
       ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc 
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
LEFT JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
    AND ccu.table_schema = tc.table_schema
WHERE tc.table_schema = 'public'
    AND tc.table_name IN ('profiles', 'users')
    AND tc.constraint_type IN ('FOREIGN KEY', 'CHECK')
ORDER BY tc.table_name, tc.constraint_name;

-- 4. Check if there are any other database functions that might be called during user creation
SELECT 'CHECKING_USER_FUNCTIONS' as info,
       proname,
       prosrc
FROM pg_proc 
WHERE proname LIKE '%user%' 
    OR proname LIKE '%auth%' 
    OR proname LIKE '%profile%'
    AND pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')
ORDER BY proname;

-- 5. Check the exact error by looking at recent database activity
SELECT 'RECENT_ERRORS' as info,
       query,
       state,
       backend_start,
       query_start
FROM pg_stat_activity 
WHERE state = 'active' 
    AND (query LIKE '%ERROR%' OR query LIKE '%INSERT%profiles%')
ORDER BY query_start DESC
LIMIT 10;

-- 6. Test a simple user creation manually to isolate the issue
SELECT 'TESTING_SIMPLE_INSERT' as info,
       'Attempting to test profile insert with minimal data...' as message;
