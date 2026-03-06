-- Verify profiles table schema - no assumptions
-- Run this in Supabase SQL Editor to get exact current state

-- Check if profiles table exists
SELECT '=== TABLE EXISTENCE ===' as section;
SELECT 
    table_name,
    table_type,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.tables 
            WHERE table_schema = 'public' AND table_name = 'profiles'
        ) THEN 'EXISTS'
        ELSE 'MISSING'
    END as status
FROM information_schema.tables 
WHERE table_schema = 'public' AND table_name = 'profiles';

-- Get complete column information
SELECT '=== COMPLETE COLUMN STRUCTURE ===' as section;
SELECT 
    column_name,
    data_type,
    character_maximum_length,
    is_nullable,
    column_default,
    ordinal_position
FROM information_schema.columns 
WHERE table_schema = 'public'
    AND table_name = 'profiles'
ORDER BY ordinal_position;

-- Check constraints
SELECT '=== CONSTRAINTS ===' as section;
SELECT 
    tc.constraint_name,
    tc.constraint_type,
    tc.is_deferrable,
    tc.initially_deferred,
    string_agg(ccu.column_name, ', ') as columns
FROM information_schema.table_constraints tc
LEFT JOIN information_schema.constraint_column_usage ccu 
    ON tc.constraint_name = ccu.constraint_name
WHERE tc.table_schema = 'public'
    AND tc.table_name = 'profiles'
GROUP BY tc.constraint_name, tc.constraint_type, tc.is_deferrable, tc.initially_deferred
ORDER BY tc.constraint_type, tc.constraint_name;

-- Check indexes
SELECT '=== INDEXES ===' as section;
SELECT 
    indexname as index_name,
    indexdef as index_definition
FROM pg_indexes 
WHERE schemaname = 'public'
    AND tablename = 'profiles'
ORDER BY indexname;

-- Check RLS policies
SELECT '=== RLS POLICIES ===' as section;
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE schemaname = 'public'
    AND tablename = 'profiles'
ORDER BY policyname;

-- Check row count
SELECT '=== DATA COUNT ===' as section;
SELECT 
    COUNT(*) as total_profiles,
    COUNT(CASE WHEN email IS NOT NULL THEN 1 END) as profiles_with_email,
    COUNT(CASE WHEN first_name IS NOT NULL THEN 1 END) as profiles_with_first_name,
    COUNT(CASE WHEN last_name IS NOT NULL THEN 1 END) as profiles_with_last_name
FROM public.profiles;

-- Sample of actual data
SELECT '=== SAMPLE DATA (first 3 rows) ===' as section;
SELECT 
    id,
    email,
    first_name,
    last_name,
    phone,
    kyc_status,
    tier_level,
    balance,
    is_active,
    email_verified,
    created_at,
    updated_at,
    last_login
FROM public.profiles 
ORDER BY created_at DESC
LIMIT 3;

-- Check for specific user from error logs
SELECT '=== SPECIFIC USER CHECK (77b97f87-16b7-41ea-83c7-076ec4b50217) ===' as section;
SELECT 
    id,
    email,
    first_name,
    last_name,
    phone,
    kyc_status,
    tier_level,
    balance,
    is_active,
    email_verified,
    created_at,
    updated_at,
    last_login,
    CASE 
        WHEN id IS NOT NULL THEN 'PROFILE EXISTS'
        ELSE 'PROFILE MISSING'
    END as status
FROM public.profiles 
WHERE id = '77b97f87-16b7-41ea-83c7-076ec4b50217';

-- Check auth.users for same user
SELECT '=== AUTH USERS CHECK (same user) ===' as section;
SELECT 
    id,
    email,
    created_at,
    last_sign_in_at,
    raw_user_meta_data
FROM auth.users 
WHERE id = '77b97f87-16b7-41ea-83c7-076ec4b50217';
