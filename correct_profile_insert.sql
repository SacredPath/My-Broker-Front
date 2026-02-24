-- Correct profile insertion with all required columns
-- Based on the actual table structure we can see

-- First, let's see the full column list to identify user_id column
SELECT '=== FULL COLUMN LIST ===' as section;
SELECT 
    column_name,
    data_type,
    is_nullable,
    ordinal_position
FROM information_schema.columns 
WHERE table_schema = 'public'
    AND table_name = 'profiles'
ORDER BY ordinal_position;

-- Now insert the profile correctly with user_id column
SELECT '=== CORRECT PROFILE INSERTION ===' as section;
INSERT INTO public.profiles (
    id,           -- This is the user_id column that's required
    email,
    first_name,
    last_name,
    phone,
    created_at,
    updated_at
) VALUES (
    'd3e80b8f-bd56-4e28-9254-1aa0fbaabfe5',  -- User ID
    'davido@aye.com',
    'David',
    'User',
    NULL,
    NOW(),
    NOW()
) ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    updated_at = NOW();

-- Verify the profile was created
SELECT '=== VERIFICATION ===' as section;
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
