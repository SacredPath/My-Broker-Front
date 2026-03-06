-- Debug the registration issue
-- Check what's happening with the trigger and profiles table

-- 1. Check if the trigger function exists and is working
SELECT 'TRIGGER_FUNCTION_CHECK' as info,
       proname,
       prosrc,
       prosecdef,
       prolang
FROM pg_proc 
WHERE proname = 'handle_new_auth_user';

-- 2. Check the trigger status
SELECT 'TRIGGER_STATUS' as info,
       event_object_table,
       trigger_name,
       action_timing,
       action_condition,
       action_statement
FROM information_schema.triggers 
WHERE trigger_name = 'handle_new_auth_user_trigger';

-- 3. Check profiles table structure
SELECT 'PROFILES_TABLE_STRUCTURE' as info,
       column_name,
       data_type,
       is_nullable,
       column_default
FROM information_schema.columns 
WHERE table_name = 'profiles' 
    AND table_schema = 'public'
ORDER BY ordinal_position;

-- 4. Check RLS policies on profiles table
SELECT 'PROFILES_RLS_POLICIES' as info,
       schemaname,
       tablename,
       policyname,
       permissive,
       roles,
       cmd,
       qual
FROM pg_policies 
WHERE tablename = 'profiles' 
    AND schemaname = 'public';

-- 5. Check if there are any missing columns that might be required
SELECT 'PROFILES_REQUIRED_COLUMNS' as info,
       column_name,
       is_nullable,
       column_default
FROM information_schema.columns 
WHERE table_name = 'profiles' 
    AND table_schema = 'public'
    AND is_nullable = 'NO'
    AND column_default IS NULL;

-- 6. Test the trigger function manually (this will help identify the issue)
SELECT 'TEST_TRIGGER_FUNCTION' as info,
       'Attempting to manually test the trigger function...' as message;

-- 7. Check recent errors in the database
SELECT 'RECENT_ERRORS' as info,
       *
FROM pg_stat_activity 
WHERE state = 'active' 
    AND query LIKE '%ERROR%'
ORDER BY query_start DESC
LIMIT 5;
