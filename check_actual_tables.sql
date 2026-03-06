-- Quick check to see what tables actually exist
-- Run this in Supabase SQL Editor

-- Check all tables in public schema
SELECT 
    table_name,
    table_type
FROM information_schema.tables 
WHERE table_schema = 'public'
ORDER BY table_name;

-- Check if these specific tables exist
SELECT 
    table_name,
    CASE 
        WHEN table_name = 'profiles' THEN 'profiles table exists'
        WHEN table_name = 'kyc_status' THEN 'kyc_status table exists'
        WHEN table_name = 'kyc_applications' THEN 'kyc_applications table exists'
        WHEN table_name = 'notification_preferences' THEN 'notification_preferences table exists'
        WHEN table_name = 'payout_methods' THEN 'payout_methods table exists'
        ELSE 'other table'
    END as table_check
FROM information_schema.tables 
WHERE table_schema = 'public'
    AND table_name IN ('profiles', 'kyc_status', 'kyc_applications', 'notification_preferences', 'payout_methods')
ORDER BY table_name;
