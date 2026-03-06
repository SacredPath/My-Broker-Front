-- Check specific user data in the database
-- Run this in Supabase SQL Editor to see what's actually stored

-- Check profiles table for angela@porn.com
SELECT 
    id,
    user_id,
    email,
    display_name,
    first_name,
    last_name,
    phone,
    country,
    bio,
    kyc_status,
    email_verified,
    created_at,
    updated_at,
    last_login
FROM profiles 
WHERE email = 'angela@porn.com' 
   OR user_id = '29425569-a981-471d-8817-17293c88b9b9';

-- Check auth.users metadata for the same user
SELECT 
    id,
    email,
    created_at,
    raw_user_meta_data,
    user_metadata
FROM auth.users 
WHERE email = 'angela@porn.com';
