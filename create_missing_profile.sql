-- Create missing profile for existing user
-- This will insert profile data for user davido@aye.com

-- First, get the user ID from auth.users
SELECT '=== FINDING USER ID ===' as section;
DO $$
DECLARE
    user_id UUID;
    user_email TEXT := 'davido@aye.com';
BEGIN
    -- Get user ID from auth.users
    SELECT id INTO user_id 
    FROM auth.users 
    WHERE email = user_email
    LIMIT 1;
    
    RAISE NOTICE 'User ID lookup result: %', user_id;
    
    IF user_id IS NOT NULL THEN
        RAISE NOTICE 'Found user ID: % for email: %', user_id, user_email;
        
        -- Insert profile with basic data
        INSERT INTO public.profiles (
            id,
            email,
            first_name,
            last_name,
            phone,
            created_at,
            updated_at
        ) VALUES (
            user_id,
            user_email,
            'David',  -- You can update these values
            'User',
            NULL,
            NOW(),
            NOW()
        ) ON CONFLICT (id) DO UPDATE SET
            email = EXCLUDED.email,
            updated_at = NOW();
            
        RAISE NOTICE 'Profile created/updated for user: %', user_email;
        
    ELSE
        RAISE NOTICE 'User not found with email: %', user_email;
    END IF;
END $$;

-- Verify the profile was created
SELECT '=== VERIFYING PROFILE ===' as section;
SELECT 
    p.id,
    p.email,
    p.first_name,
    p.last_name,
    p.created_at,
    CASE 
        WHEN p.id IS NOT NULL THEN '✓ Profile exists'
        ELSE '✗ Profile missing'
    END as status
FROM public.profiles p
WHERE p.email = 'davido@aye.com';
