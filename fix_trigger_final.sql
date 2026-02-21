-- Fix the trigger to use correct primary key and handle potential duplicates
-- This resolves profile creation issues

-- Drop current trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Drop and recreate function with proper handling
DROP FUNCTION IF EXISTS handle_new_user();

CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if profile already exists to avoid duplicates
    IF EXISTS (SELECT 1 FROM profiles WHERE id = NEW.id) THEN
        RETURN NEW;
    END IF;
    
    -- Create profile with basic user information using correct primary key
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
        COALESCE(NEW.raw_user_meta_data->>'display_name', split_part(NEW.email, '@', 1)),
        NEW.email_confirmed,
        'user',
        NOW(), 
        NOW()
    );
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Recreate the trigger
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION handle_new_user();

-- Show current profiles to check for duplicates
SELECT 'CURRENT_PROFILES' as info,
       id,
       email,
       display_name,
       created_at
FROM profiles 
ORDER BY created_at DESC
LIMIT 5;

-- Verify trigger is working
SELECT 'TRIGGER_FIXED' as status,
       trigger_name,
       event_manipulation,
       action_timing
FROM information_schema.triggers 
WHERE trigger_name = 'on_auth_user_created'
AND trigger_schema = 'auth';
