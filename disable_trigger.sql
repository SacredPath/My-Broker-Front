-- Disable the trigger completely to isolate the issue
-- This will help determine if the trigger is causing the registration error

-- Drop the trigger entirely
DROP TRIGGER IF EXISTS handle_new_auth_user_trigger ON auth.users;

-- Also drop the function to be safe
DROP FUNCTION IF EXISTS handle_new_auth_user();

-- Verify trigger is removed
SELECT 'TRIGGER_REMOVED' as status,
       COUNT(*) as remaining_triggers
FROM information_schema.triggers 
WHERE trigger_name = 'handle_new_auth_user_trigger'
AND trigger_schema = 'auth';

-- Show remaining auth.users triggers (if any)
SELECT 'REMAINING_AUTH_TRIGGERS' as info,
       trigger_name,
       event_manipulation,
       action_timing,
       action_statement
FROM information_schema.triggers 
WHERE event_object_table = 'users'
AND trigger_schema = 'auth';
