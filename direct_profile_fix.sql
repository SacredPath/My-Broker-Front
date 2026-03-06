-- Direct fix for the specific user profile issue
-- This will manually insert the profile record

-- First, check if the user actually exists in auth.users
SELECT '=== CHECKING USER EXISTS ===' as section;
SELECT 
    id,
    email,
    created_at
FROM auth.users 
WHERE email = 'davido@aye.com';

-- Check if profile exists
SELECT '=== CHECKING PROFILE EXISTS ===' as section;
SELECT 
    id,
    email,
    CASE 
        WHEN id IS NOT NULL THEN '✓ Profile exists'
        ELSE '✗ Profile missing'
    END as status
FROM public.profiles 
WHERE email = 'davido@aye.com';

-- Get the exact user ID and insert profile directly
SELECT '=== DIRECT PROFILE INSERTION ===' as section;
INSERT INTO public.profiles (
    id,
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
    'd3e80b8f-bd56-4e28-9254-1aa0fbaabfe5',  -- The exact user ID from logs
    'davido@aye.com',
    'David',
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
    updated_at = NOW();

-- Verify the profile was created
SELECT '=== FINAL VERIFICATION ===' as section;
SELECT 
    p.id,
    p.email,
    p.first_name,
    p.last_name,
    p.created_at,
    CASE 
        WHEN p.id IS NOT NULL THEN '✓ Profile successfully created'
        ELSE '✗ Profile still missing'
    END as status
FROM public.profiles p
WHERE p.id = 'd3e80b8f-bd56-4e28-9254-1aa0fbaabfe5';
