-- Simple schema check for settings page tables
-- Run each section separately in Supabase SQL Editor

-- =====================================================
-- 1. Check which tables exist
-- =====================================================
SELECT 
    table_schema,
    table_name,
    table_type
FROM information_schema.tables 
WHERE table_schema = 'public'
    AND table_name IN (
        'profiles',
        'kyc_status', 
        'payout_methods',
        'notification_preferences',
        'notifications',
        'notification_history'
    )
ORDER BY table_name;

-- =====================================================
-- 2. Check profiles table structure
-- =====================================================
SELECT 
    'profiles' as table_name,
    column_name,
    ordinal_position,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public'
    AND table_name = 'profiles'
ORDER BY ordinal_position;

-- =====================================================
-- 3. Check kyc_status table structure
-- =====================================================
SELECT 
    'kyc_status' as table_name,
    column_name,
    ordinal_position,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public'
    AND table_name = 'kyc_status'
ORDER BY ordinal_position;

-- =====================================================
-- 4. Check payout_methods table structure
-- =====================================================
SELECT 
    'payout_methods' as table_name,
    column_name,
    ordinal_position,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public'
    AND table_name = 'payout_methods'
ORDER BY ordinal_position;

-- =====================================================
-- 5. Check notification_preferences table structure
-- =====================================================
SELECT 
    'notification_preferences' as table_name,
    column_name,
    ordinal_position,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public'
    AND table_name = 'notification_preferences'
ORDER BY ordinal_position;

-- =====================================================
-- 6. Check notifications table structure
-- =====================================================
SELECT 
    'notifications' as table_name,
    column_name,
    ordinal_position,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public'
    AND table_name = 'notifications'
ORDER BY ordinal_position;

-- =====================================================
-- 7. Check notification_history table structure
-- =====================================================
SELECT 
    'notification_history' as table_name,
    column_name,
    ordinal_position,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public'
    AND table_name = 'notification_history'
ORDER BY ordinal_position;
