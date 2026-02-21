-- Fix the trigger to create a proper profile with basic user info
-- This ensures profile is auto-populated from registration

-- Drop the current minimal trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Drop the function
DROP FUNCTION IF EXISTS handle_new_user();

-- Create improved function that populates profile with basic user info
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    -- Create profile with basic user information from auth.users
    INSERT INTO profiles (
        id, 
        email, 
        display_name,
        email_verified,
        role,
        created_at, 
        updated_at
    ) VALUES (
        NEW.id, 
        NEW.email, 
        COALESCE(NEW.raw_user_meta_data->>'display_name', NEW.email),
        NEW.email_confirmed,
        'user',
        NOW(), 
        NOW()
    );
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Recreate the trigger with improved function
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION handle_new_user();

-- Verify the function was created correctly
SELECT 'HANDLE_NEW_USER_IMPROVED' as status,
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
WHERE trigger_name = 'on_auth_user_created'
AND trigger_schema = 'auth';
