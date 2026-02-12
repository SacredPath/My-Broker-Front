-- Diagnose profiles table structure and data
-- Run this in Supabase SQL Editor to understand the actual table structure

-- 1. Check if profiles table exists and its structure
SELECT 
    column_name,
    ordinal_position,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public'
    AND table_name = 'profiles'
ORDER BY ordinal_position;

-- 2. Check what primary key exists for profiles table
SELECT 
    tc.constraint_name,
    tc.constraint_type,
    kcu.column_name
FROM information_schema.table_constraints AS tc 
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
WHERE tc.table_schema = 'public'
    AND tc.table_name = 'profiles'
    AND tc.constraint_type = 'PRIMARY KEY';

-- 3. Check if there are any records in profiles table
SELECT COUNT(*) as total_profiles FROM profiles;

-- 4. Show sample data from profiles table (if any)
SELECT * FROM profiles LIMIT 5;

-- 5. Check for the specific user ID from the error logs
SELECT * FROM profiles 
WHERE id = '29425569-a981-471d-8817-17293c88b9b9' 
   OR user_id = '29425569-a981-471d-8817-17293c88b9b9';
