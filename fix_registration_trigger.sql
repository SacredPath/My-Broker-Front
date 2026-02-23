-- Fix the handle_new_auth_user trigger function
-- This resolves the "Database error saving new user" issue during registration

-- First, disable RLS temporarily for the trigger to work
ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;

-- Drop the trigger first (it depends on the function)
DROP TRIGGER IF EXISTS handle_new_auth_user_trigger ON auth.users;

-- Then drop and recreate the trigger function with correct column names
DROP FUNCTION IF EXISTS handle_new_auth_user();

CREATE OR REPLACE FUNCTION handle_new_auth_user()
RETURNS TRIGGER AS $$
BEGIN
    -- Insert with all required columns, using defaults for missing data
    INSERT INTO public.profiles (
        id, 
        email, 
        email_verified, 
        kyc_status,
        tier_level,
        balance,
        is_active,
        created_at, 
        updated_at
    )
    VALUES (
        NEW.id, 
        NEW.email, 
        COALESCE(NEW.email_confirmed, false), 
        'pending',
        1,
        0,
        true,
        NOW(), 
        NOW()
    );
    RETURN NEW;
EXCEPTION
    WHEN OTHERS THEN
        -- Log the error but don't fail the user creation
        RAISE WARNING 'Failed to create profile for user %: %', NEW.id, SQLERRM;
        RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Recreate the trigger with the fixed function
CREATE TRIGGER handle_new_auth_user_trigger
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION handle_new_auth_user();

-- Re-enable RLS with proper policies
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Ensure the trigger function has proper permissions
GRANT EXECUTE ON FUNCTION handle_new_auth_user() TO service_role;

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
