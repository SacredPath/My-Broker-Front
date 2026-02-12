-- Check registration data and user metadata structure
-- Run this in Supabase SQL Editor to see what data is available

-- 1. Check auth.users table structure (Supabase auth users)
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_schema = 'auth' 
    AND table_name = 'users'
ORDER BY ordinal_position;

-- 2. Check if there are any registration-related tables
SELECT 
    table_name,
    table_type
FROM information_schema.tables 
WHERE table_schema = 'public'
    AND (table_name LIKE '%registration%' 
         OR table_name LIKE '%signup%'
         OR table_name LIKE '%user_%'
         OR table_name LIKE '%auth_%')
ORDER BY table_name;

-- 3. Check raw_user_meta_data column in auth.users
SELECT 
    id,
    email,
    created_at,
    raw_user_meta_data,
    user_metadata
FROM auth.users 
WHERE email = 'angela@porn.com'
   OR email = 'datlax27@gmail.com'
   OR email = 'mangala@ahmed.com'
LIMIT 5;

-- 4. Check profiles table for registration data patterns
SELECT 
    id,
    user_id,
    email,
    display_name,
    first_name,
    last_name,
    phone,
    country,
    created_at
FROM profiles 
WHERE email IN ('angela@porn.com', 'datlax27@gmail.com', 'mangala@ahmed.com')
ORDER BY created_at DESC;
