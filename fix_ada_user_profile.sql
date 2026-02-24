-- Fix profile for user ada@maka.com
-- This will create the missing profile record

-- First, get the user ID from auth.users
SELECT '=== FINDING USER ID ===' as section;
SELECT 
    id,
    email,
    created_at
FROM auth.users 
WHERE email = 'ada@maka.com';

-- Create the missing profile
SELECT '=== CREATING PROFILE ===' as section;
INSERT INTO public.profiles (
    id,           -- Primary key
    user_id,       -- Required user_id column
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
    'ae011258-9303-432a-b287-cda2a56f320d',  -- User ID from logs
    'ae011258-9303-432a-b287-cda2a56f320d',  -- user_id (same as id)
    'ada@maka.com',
    'Ada',        -- Default first name from email
    'User',       -- Default last name
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

-- Verify the profile was created
SELECT '=== VERIFICATION ===' as section;
SELECT 
    p.id,
    p.user_id,
    p.email,
    p.first_name,
    p.last_name,
    p.created_at,
    p.kyc_status,
    CASE 
        WHEN p.id IS NOT NULL THEN '✓ Profile successfully created'
        ELSE '✗ Profile still missing'
    END as status
FROM public.profiles p
WHERE p.id = 'ae011258-9303-432a-b287-cda2a56f320d';
