-- Debug why profile sync isn't working for ada@maka.com
-- Check if user has registration data stored

SELECT '=== CHECKING USER REGISTRATION DATA ===' as section;
-- Check if this user has any registration data stored
SELECT 
    'ada@maka.com' as user_email,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM pg_settings 
            WHERE name = 'registrationData_ada@maka.com'
        ) THEN '✓ Has registration data'
        ELSE '✗ No registration data found'
    END as registration_data_status;

-- Check localStorage simulation
SELECT '=== SIMULATING REGISTRATION DATA LOOKUP ===' as section;
DO $$
DECLARE
    registration_data JSONB;
BEGIN
    -- Simulate getting registration data for ada@maka.com
    registration_data := '{"firstName":"Ada","lastName":"User","email":"ada@maka.com","phone":null,"address":{},"compliance":{},"referralCode":""}';
    
    IF registration_data IS NOT NULL THEN
        RAISE NOTICE 'Registration data found: %', registration_data;
        RAISE NOTICE 'First name: %', registration_data->>'firstName';
        RAISE NOTICE 'Last name: %', registration_data->>'lastName';
    ELSE
        RAISE NOTICE 'No registration data available';
    END IF;
END $$;

-- Check if profile exists for this user
SELECT '=== CHECKING EXISTING PROFILE ===' as section;
SELECT 
    p.id,
    p.email,
    p.first_name,
    p.last_name,
    p.user_id,
    CASE 
        WHEN p.id IS NOT NULL THEN '✓ Profile exists'
        ELSE '✗ Profile missing'
    END as status
FROM public.profiles p
WHERE p.email = 'ada@maka.com';

-- Test manual profile creation with registration data
SELECT '=== TESTING MANUAL PROFILE CREATION ===' as section;
DO $$
BEGIN
    -- Insert profile for ada@maka.com using registration data
    INSERT INTO public.profiles (
        id,
        user_id,
        email,
        first_name,
        last_name,
        phone,
        created_at,
        updated_at,
        role,
        is_active,
        email_verified,
        kyc_status,
        tier_level,
        balance
    ) VALUES (
        'ae011258-9303-432a-b287-cda2a56f320d',
        'ae011258-9303-432a-b287-cda2a56f320d',
        'ada@maka.com',
        'Ada',
        'User',
        NULL,
        NOW(),
        NOW(),
        'user',
        true,
        false,
        'pending',
        1,
        0.00
    ) ON CONFLICT (id) DO UPDATE SET
        email = EXCLUDED.email,
        user_id = EXCLUDED.user_id,
        updated_at = NOW();
    
    RAISE NOTICE 'Profile created/updated for ada@maka.com';
END $$;

-- Verify the fix
SELECT '=== FINAL VERIFICATION ===' as section;
SELECT 
    p.id,
    p.email,
    p.first_name,
    p.last_name,
    p.kyc_status,
    CASE 
        WHEN p.id IS NOT NULL THEN '✓ Profile successfully created'
        ELSE '✗ Profile still missing'
    END as status
FROM public.profiles p
WHERE p.id = 'ae011258-9303-432a-b287-cda2a56f320d';
