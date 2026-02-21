-- Simplified trigger fix - only insert essential columns that definitely exist
-- This resolves the "Database error saving new user" issue during registration

-- Drop the trigger first (it depends on the function)
DROP TRIGGER IF EXISTS handle_new_auth_user_trigger ON auth.users;

-- Then drop and recreate the trigger function with minimal columns
DROP FUNCTION IF EXISTS handle_new_auth_user();

CREATE OR REPLACE FUNCTION handle_new_auth_user()
RETURNS TRIGGER AS $$
BEGIN
    -- Only insert columns that we know exist in the profiles table
    INSERT INTO profiles (id, email, created_at, updated_at)
    VALUES (NEW.id, NEW.email, NOW(), NOW());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Recreate the trigger with the fixed function
CREATE TRIGGER handle_new_auth_user_trigger
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION handle_new_auth_user();

-- Verify the function was created correctly
SELECT 'TRIGGER_FUNCTION_FIXED' as status,
       proname as function_name,
       pg_get_functiondef(oid) as function_definition
FROM pg_proc 
WHERE proname = 'handle_new_auth_user';

-- Show the current trigger status
SELECT 'TRIGGER_STATUS' as info,
       trigger_name,
       event_manipulation,
       event_object_table,
       action_timing,
       action_condition,
       action_statement
FROM information_schema.triggers 
WHERE trigger_name = 'handle_new_auth_user_trigger'
AND trigger_schema = 'auth';
