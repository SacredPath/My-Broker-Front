-- Check registration schema and current data structure
-- Run this in Supabase SQL Editor

-- 1. Check profiles table structure for name fields
SELECT 
    column_name,
    data_type,
    is_nullable,
    ordinal_position
FROM information_schema.columns 
WHERE table_schema = 'public'
    AND table_name = 'profiles'
    AND (column_name LIKE '%name%' OR column_name LIKE '%display%')
ORDER BY ordinal_position;

-- 2. Check current data in profiles table to see how names are stored
SELECT 
    id,
    email,
    display_name,
    first_name,
    last_name,
    created_at
FROM profiles 
ORDER BY created_at DESC
LIMIT 10;

-- 3. Check if there are any users with only display_name populated
SELECT 
    COUNT(*) as total_profiles,
    COUNT(CASE WHEN first_name IS NOT NULL AND first_name != '' THEN 1 END) as with_first_name,
    COUNT(CASE WHEN last_name IS NOT NULL AND last_name != '' THEN 1 END) as with_last_name,
    COUNT(CASE WHEN display_name IS NOT NULL AND display_name != '' THEN 1 END) as with_display_name
FROM profiles;

-- 4. Check registration controller logic - what fields are actually being saved
-- This will help us understand the current data flow
