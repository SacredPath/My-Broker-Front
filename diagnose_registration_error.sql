-- Diagnostic SQL to identify the exact cause of registration error
-- Run this in Supabase SQL Editor to pinpoint the issue

-- 1. Check if the trigger exists and is active
SELECT '=== CHECKING TRIGGERS ===' as section;
SELECT 
    trigger_schema,
    trigger_name,
    event_manipulation,
    event_object_table,
    action_timing,
    action_statement
FROM information_schema.triggers 
WHERE trigger_name = 'on_auth_user_created'
    AND event_object_table = 'users'
    AND trigger_schema = 'auth';

-- 2. Check the handle_new_user function definition
SELECT '=== CHECKING FUNCTION DEFINITION ===' as section;
SELECT 
    routine_schema,
    routine_name,
    routine_type,
    routine_definition
FROM information_schema.routines 
WHERE routine_schema = 'public' 
    AND routine_name = 'handle_new_user';

-- 3. Check if audit_log_entries table exists and its structure
SELECT '=== CHECKING AUDIT LOG TABLE ===' as section;
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public'
    AND table_name = 'audit_log_entries'
ORDER BY ordinal_position;

-- 4. Check if profiles table exists and its structure
SELECT '=== CHECKING PROFILES TABLE ===' as section;
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public'
    AND table_name = 'profiles'
ORDER BY ordinal_position;

-- 5. Test the trigger function manually with sample data
SELECT '=== TESTING TRIGGER FUNCTION ===' as section;
DO $$
DECLARE
    test_user_id UUID := gen_random_uuid();
    test_email TEXT := 'test@example.com';
    test_phone TEXT := '+1234567890';
    test_created_at TIMESTAMP WITH TIME ZONE := NOW();
BEGIN
    -- Try to call the function directly
    RAISE NOTICE 'Testing handle_new_user function...';
    
    -- Simulate the NEW record from auth.users
    PERFORM public.handle_new_user() FROM (
        SELECT 
            test_user_id as id,
            test_email as email,
            test_phone as phone,
            test_created_at as created_at
    ) as NEW;
    
    RAISE NOTICE 'Function executed successfully';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Function failed with error: %', SQLERRM;
    RAISE NOTICE 'SQLSTATE: %', SQLSTATE;
END $$;

-- 6. Check for any recent failed registrations
SELECT '=== RECENT FAILED REGISTRATIONS ===' as section;
SELECT 
    id,
    email,
    phone,
    created_at,
    email_confirmed_at,
    last_sign_in_at,
    raw_user_meta_data
FROM auth.users 
WHERE created_at >= NOW() - INTERVAL '1 day'
ORDER BY created_at DESC
LIMIT 10;

-- 7. Check for any constraint violations on auth.users
SELECT '=== AUTH USERS CONSTRAINTS ===' as section;
SELECT 
    conname as constraint_name,
    contype as constraint_type,
    pg_get_constraintdef(oid) as definition
FROM pg_constraint 
WHERE conrelid = 'auth.users'::regclass
ORDER BY conname;

-- 8. Check if there are any duplicate phone numbers (common issue)
SELECT '=== DUPLICATE PHONE NUMBERS ===' as section;
SELECT 
    phone,
    COUNT(*) as count,
    ARRAY_AGG(email ORDER BY created_at) as emails
FROM auth.users 
WHERE phone IS NOT NULL
    AND created_at >= NOW() - INTERVAL '7 days'
GROUP BY phone
HAVING COUNT(*) > 1
ORDER BY count DESC;

-- 9. Check RLS policies that might interfere
SELECT '=== RLS POLICIES ===' as section;
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual
FROM pg_policies 
WHERE tablename IN ('users', 'profiles', 'audit_log_entries')
ORDER BY tablename, policyname;

-- 10. Final diagnostic summary
SELECT '=== DIAGNOSTIC SUMMARY ===' as section;
SELECT 
    'Run this complete diagnostic to identify the exact cause of registration errors' as instruction,
    NOW() as diagnostic_run_at;
