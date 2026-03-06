-- Check the actual structure of the profiles table
-- This will show us all columns and their requirements

SELECT '=== PROFILES TABLE STRUCTURE ===' as section;
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

-- Check what columns are actually required (NOT NULL)
SELECT '=== REQUIRED COLUMNS ===' as section;
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_schema = 'public'
    AND table_name = 'profiles'
    AND is_nullable = 'NO'
ORDER BY ordinal_position;

-- Show a sample of existing profiles to understand the structure
SELECT '=== SAMPLE EXISTING PROFILES ===' as section;
SELECT 
    id,
    email,
    first_name,
    last_name,
    phone,
    created_at,
    updated_at
FROM public.profiles 
LIMIT 3;
