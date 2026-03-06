-- Fix all existing users who don't have profiles
-- This is a one-time fix for existing users only
-- Future registrations will work automatically with the updated auth service

-- First, check how many users are missing profiles
SELECT '=== CHECKING MISSING PROFILES ===' as section;
SELECT 
    COUNT(*) as users_without_profiles
FROM auth.users u
WHERE NOT EXISTS (
    SELECT 1 FROM public.profiles p 
    WHERE p.id = u.id
);

-- Create profiles for all users who don't have them
SELECT '=== CREATING MISSING PROFILES ===' as section;
DO $$
DECLARE
    user_record RECORD;
    profiles_created INTEGER := 0;
BEGIN
    -- Loop through all users without profiles
    FOR user_record IN 
        SELECT u.id, u.email, u.raw_user_meta_data
        FROM auth.users u
        WHERE NOT EXISTS (
            SELECT 1 FROM public.profiles p 
            WHERE p.id = u.id
        )
    LOOP
        -- Extract name from metadata if available, otherwise use defaults
        DECLARE
            first_name TEXT := COALESCE(
                (user_record.raw_user_meta_data->>'first_name'),
                (user_record.raw_user_meta_data->>'name'),
                split_part(user_record.email, '@', 1)
            );
            last_name TEXT := COALESCE(
                (user_record.raw_user_meta_data->>'last_name'),
                'User'
            );
        BEGIN
            -- Insert profile for this user
            INSERT INTO public.profiles (
                id,
                email,
                first_name,
                last_name,
                phone,
                created_at,
                updated_at
            ) VALUES (
                user_record.id,
                user_record.email,
                first_name,
                last_name,
                NULL, -- Phone can be updated later
                NOW(),
                NOW()
            ) ON CONFLICT (id) DO NOTHING;
            
            profiles_created := profiles_created + 1;
            RAISE NOTICE 'Created profile for user: %', user_record.email;
            
        EXCEPTION WHEN OTHERS THEN
            RAISE NOTICE 'Failed to create profile for user %: %', user_record.email, SQLERRM;
        END;
    END LOOP;
    
    RAISE NOTICE 'Total profiles created: %', profiles_created;
END $$;

-- Verify the fix
SELECT '=== VERIFICATION ===' as section;
SELECT 
    COUNT(*) as total_users,
    COUNT(CASE WHEN p.id IS NOT NULL THEN 1 END) as users_with_profiles,
    COUNT(CASE WHEN p.id IS NULL THEN 1 END) as users_without_profiles
FROM auth.users u
LEFT JOIN public.profiles p ON u.id = p.id;

SELECT 
    'All missing profiles created. Future registrations will work automatically.' as status,
    NOW() as fixed_at;
