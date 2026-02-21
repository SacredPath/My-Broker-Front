-- Check the handle_new_user function that's causing the issue
SELECT 'CHECKING_HANDLE_NEW_USER_FUNCTION' as info,
       proname as function_name,
       pg_get_functiondef(oid) as function_definition
FROM pg_proc 
WHERE proname = 'handle_new_user'
AND pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public');

-- Also check if there are any other auth.users triggers
SELECT 'ALL_AUTH_USERS_TRIGGERS' as info,
       trigger_name,
       event_manipulation,
       action_timing,
       action_statement
FROM information_schema.triggers 
WHERE event_object_table = 'users'
AND trigger_schema = 'auth';
