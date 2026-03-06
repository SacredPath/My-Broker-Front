-- Verify the complete profile system is working
-- Check if user profile exists and is properly populated

SELECT 'PROFILE_SYSTEM_VERIFICATION' as status;

-- Check if profile exists for current user (replace with actual user ID)
SELECT 
    id,
    email,
    display_name,
    first_name,
    last_name,
    phone,
    country,
    role,
    created_at,
    updated_at
FROM profiles 
WHERE id = '1fdaf99a-bfec-4240-8de8-e066ad73a4fe' -- Current user ID from logs
LIMIT 1;

-- Check trigger is working
SELECT 'TRIGGER_STATUS' as info,
       trigger_name,
       event_manipulation,
       action_timing
FROM information_schema.triggers 
WHERE trigger_name = 'on_auth_user_created'
AND trigger_schema = 'auth';

-- Show all profile columns available
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'profiles' 
    AND table_schema = 'public'
ORDER BY ordinal_position;
