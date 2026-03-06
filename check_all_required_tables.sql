-- Check all tables required by the settings page
-- Run this in Supabase SQL Editor

-- 1. List all tables in public schema
SELECT 
    table_name,
    table_type,
    CASE 
        WHEN table_name IN ('profiles', 'kyc_status', 'kyc_applications', 'notification_preferences', 'payout_methods') 
        THEN 'REQUIRED BY SETTINGS'
        ELSE 'OTHER'
    END as importance
FROM information_schema.tables 
WHERE table_schema = 'public'
ORDER BY 
    CASE 
        WHEN table_name IN ('profiles', 'kyc_status', 'kyc_applications', 'notification_preferences', 'payout_methods') 
        THEN 1
        ELSE 2
    END,
    table_name;

-- 2. Check structure of each required table (if they exist)
SELECT 
    'profiles' as table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_schema = 'public' AND table_name = 'profiles'

UNION ALL

SELECT 
    'kyc_applications' as table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_schema = 'public' AND table_name = 'kyc_applications'

UNION ALL

SELECT 
    'notification_preferences' as table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_schema = 'public' AND table_name = 'notification_preferences'

UNION ALL

SELECT 
    'payout_methods' as table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_schema = 'public' AND table_name = 'payout_methods'

ORDER BY table_name, column_name;
