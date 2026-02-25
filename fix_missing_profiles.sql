-- Fix missing profiles for existing users
-- This creates profile records for users who exist in auth.users but not in profiles

-- First, identify users missing profiles
SELECT '=== USERS MISSING PROFILES ===' as section;
SELECT 
    au.id,
    au.email,
    au.created_at as auth_created_at,
    au.last_sign_in_at,
    CASE 
        WHEN p.id IS NULL THEN 'MISSING PROFILE'
        ELSE 'HAS PROFILE'
    END as profile_status
FROM auth.users au
LEFT JOIN public.profiles p ON au.id = p.id
WHERE p.id IS NULL
ORDER BY au.created_at DESC;

-- Create missing profiles
SELECT '=== CREATING MISSING PROFILES ===' as section;
INSERT INTO public.profiles (
    id,
    user_id,
    email,
    display_name,
    first_name,
    last_name,
    phone,
    country,
    email_verified,
    role,
    created_at,
    updated_at,
    kyc_status,
    tier_level,
    balance,
    is_active
)
SELECT 
    au.id,
    au.id,
    au.email,
    COALESCE(au.raw_user_meta_data->>'name', 
             SPLIT_PART(au.email, '@', 1), 
             'User') as display_name,
    NULL as first_name,
    NULL as last_name,
    NULL as phone,
    NULL as country,
    au.raw_user_meta_data->>'email_verified' = 'true' as email_verified,
    'user' as role,
    au.created_at,
    NOW() as updated_at,
    'pending' as kyc_status,
    1 as tier_level,
    0 as balance,
    true as is_active
FROM auth.users au
LEFT JOIN public.profiles p ON au.id = p.id
WHERE p.id IS NULL
ON CONFLICT (id) DO NOTHING;

-- Verify the fix
SELECT '=== VERIFICATION ===' as section;
SELECT 
    COUNT(*) as total_profiles_created,
    COUNT(CASE WHEN first_name IS NULL THEN 1 END) as profiles_need_completion
FROM public.profiles 
WHERE id IN (
    SELECT au.id 
    FROM auth.users au 
    LEFT JOIN public.profiles p ON au.id = p.id 
    WHERE p.id IS NULL
);

-- Show newly created profiles
SELECT '=== NEWLY CREATED PROFILES ===' as section;
SELECT 
    p.id,
    p.email,
    p.display_name,
    p.created_at,
    p.kyc_status,
    p.email_verified
FROM public.profiles p
WHERE p.created_at >= NOW() - INTERVAL '1 minute'
ORDER BY p.created_at DESC;
