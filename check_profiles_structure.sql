-- Check current profiles table structure
-- This will show us what columns actually exist

SELECT 
    'CURRENT_PROFILES_STRUCTURE' as section,
    column_name,
    data_type,
    is_nullable,
    column_default,
    ordinal_position
FROM information_schema.columns 
WHERE table_schema = 'public' 
    AND table_name = 'profiles'
ORDER BY ordinal_position;

-- Check if profiles table exists at all
SELECT 
    'PROFILES_EXISTENCE_CHECK' as section,
    table_name,
    table_type,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'profiles')
        THEN 'EXISTS'
        ELSE 'MISSING'
    END as status
FROM information_schema.tables 
WHERE table_schema = 'public' 
    AND table_name = 'profiles';
