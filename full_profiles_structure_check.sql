-- Get the complete profiles table structure to understand all columns
-- The error shows there's a user_id column that's NOT NULL

SELECT '=== COMPLETE PROFILES STRUCTURE ===' as section;
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default,
    ordinal_position
FROM information_schema.columns 
WHERE table_schema = 'public'
    AND table_name = 'profiles'
ORDER BY ordinal_position;

-- Now insert with both id and user_id columns
SELECT '=== INSERT WITH ALL COLUMNS ===' as section;
INSERT INTO public.profiles (
    id,           -- Primary key
    user_id,       -- The separate user_id column that's required
    email,
    first_name,
    last_name,
    phone,
    created_at,
    updated_at
) VALUES (
    'd3e80b8f-bd56-4e28-9254-1aa0fbaabfe5',  -- id
    'd3e80b8f-bd56-4e28-9254-1aa0fbaabfe5',  -- user_id (same as id)
    'davido@aye.com',
    'David',
    'User',
    NULL,
    NOW(),
    NOW()
) ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    user_id = EXCLUDED.user_id,
    updated_at = NOW();

-- Verify the profile was created
SELECT '=== FINAL VERIFICATION ===' as section;
SELECT 
    p.id,
    p.user_id,
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
