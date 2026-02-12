-- Check schema for all tables used by the settings page
-- Run this in Supabase SQL Editor to verify table structures

-- 1. Check all tables that settings page uses
SELECT 
    'TABLE' as object_type,
    table_schema,
    table_name,
    '' as column_name,
    '' as data_type,
    '' as is_nullable,
    '' as ordinal_position
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
ORDER BY table_name

UNION ALL

-- 2. Check all columns for these tables
SELECT 
    'COLUMN' as object_type,
    table_schema,
    table_name,
    column_name,
    data_type,
    is_nullable,
    ordinal_position::text as ordinal_position
FROM information_schema.columns 
WHERE table_schema = 'public'
    AND table_name IN (
        'profiles',
        'kyc_status', 
        'payout_methods',
        'notification_preferences',
        'notifications',
        'notification_history'
    )
ORDER BY object_type, table_name, ordinal_position;

-- 3. Detailed view of each table structure
-- Profiles table
SELECT 
    'PROFILES_DETAIL' as info_type,
    column_name,
    ordinal_position,
    column_default,
    is_nullable,
    data_type,
    character_maximum_length,
    numeric_precision,
    numeric_scale
FROM information_schema.columns 
WHERE table_schema = 'public'
    AND table_name = 'profiles'
ORDER BY ordinal_position;

-- KYC Status table  
SELECT 
    'KYC_STATUS_DETAIL' as info_type,
    column_name,
    ordinal_position,
    column_default,
    is_nullable,
    data_type,
    character_maximum_length,
    numeric_precision,
    numeric_scale
FROM information_schema.columns 
WHERE table_schema = 'public'
    AND table_name = 'kyc_status'
ORDER BY ordinal_position;

-- Payout Methods table
SELECT 
    'PAYOUT_METHODS_DETAIL' as info_type,
    column_name,
    ordinal_position,
    column_default,
    is_nullable,
    data_type,
    character_maximum_length,
    numeric_precision,
    numeric_scale
FROM information_schema.columns 
WHERE table_schema = 'public'
    AND table_name = 'payout_methods'
ORDER BY ordinal_position;

-- Notification Preferences table
SELECT 
    'NOTIFICATION_PREFERENCES_DETAIL' as info_type,
    column_name,
    ordinal_position,
    column_default,
    is_nullable,
    data_type,
    character_maximum_length,
    numeric_precision,
    numeric_scale
FROM information_schema.columns 
WHERE table_schema = 'public'
    AND table_name = 'notification_preferences'
ORDER BY ordinal_position;

-- Notifications table
SELECT 
    'NOTIFICATIONS_DETAIL' as info_type,
    column_name,
    ordinal_position,
    column_default,
    is_nullable,
    data_type,
    character_maximum_length,
    numeric_precision,
    numeric_scale
FROM information_schema.columns 
WHERE table_schema = 'public'
    AND table_name = 'notifications'
ORDER BY ordinal_position;

-- Notification History table
SELECT 
    'NOTIFICATION_HISTORY_DETAIL' as info_type,
    column_name,
    ordinal_position,
    column_default,
    is_nullable,
    data_type,
    character_maximum_length,
    numeric_precision,
    numeric_scale
FROM information_schema.columns 
WHERE table_schema = 'public'
    AND table_name = 'notification_history'
ORDER BY ordinal_position;

-- 4. Check foreign key relationships for these tables
SELECT 
    'FOREIGN_KEYS' as info_type,
    tc.table_name,
    tc.constraint_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc 
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
    AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
    AND tc.table_schema = 'public'
    AND tc.table_name IN (
        'profiles',
        'kyc_status', 
        'payout_methods',
        'notification_preferences',
        'notifications',
        'notification_history'
    )
ORDER BY tc.table_name, tc.constraint_name;
