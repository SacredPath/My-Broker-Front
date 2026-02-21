-- Fix the on_auth_user_created trigger and handle_new_user function
-- This is the actual trigger causing registration error

-- Drop the problematic trigger first
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Drop and recreate the function with minimal implementation
DROP FUNCTION IF EXISTS handle_new_user();

CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    -- Minimal implementation - just return NEW without any database operations
    -- The profile will be created by the application code after signup
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Recreate the trigger with the fixed function
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION handle_new_user();

-- Verify the function was created correctly
SELECT 'HANDLE_NEW_USER_FIXED' as status,
       proname as function_name,
       pg_get_functiondef(oid) as function_definition
FROM pg_proc 
WHERE proname = 'handle_new_user';

-- Show final trigger status
SELECT 'FINAL_TRIGGER_STATUS' as info,
       trigger_name,
       event_manipulation,
       event_object_table,
       action_timing,
       action_statement
FROM information_schema.triggers 
WHERE event_object_table = 'users'
AND trigger_schema = 'auth';
