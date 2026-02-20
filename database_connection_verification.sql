-- Verify all database connections are pointing to correct database
-- This script should be run in the CORRECT database: rfszagckgghcygkomybc.supabase.co

-- 1. Verify we're in the correct database
SELECT 
    'DATABASE_VERIFICATION' as info,
    current_database() as database_name,
    version() as postgres_version;

-- 2. Check if deposit_methods table exists and has PayPal data
SELECT 
    'PAYPAL_DATA_CHECK' as info,
    COUNT(*) as total_methods,
    COUNT(CASE WHEN method_type = 'paypal' THEN 1 END) as paypal_methods,
    COUNT(CASE WHEN paypal_email IS NOT NULL THEN 1 END) as methods_with_email,
    MAX(updated_at) as last_updated
FROM deposit_methods;

-- 3. Show current PayPal data
SELECT 
    'CURRENT_PAYPAL_DATA' as info,
    id,
    method_name,
    method_type,
    paypal_email,
    paypal_business_name,
    is_active,
    created_at,
    updated_at
FROM deposit_methods 
WHERE method_type = 'paypal' 
ORDER BY updated_at DESC;

-- 4. Check if we have the correct email
SELECT 
    'EMAIL_VERIFICATION' as info,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM deposit_methods 
            WHERE method_type = 'paypal' 
            AND paypal_email = 'palantirinvestment@gmail.com'
        ) THEN 'CORRECT_EMAIL_FOUND'
        ELSE 'INCORRECT_OR_MISSING_EMAIL'
    END as status;

-- 5. Show all active methods for completeness
SELECT 
    'ALL_ACTIVE_METHODS' as info,
    id,
    method_name,
    method_type,
    paypal_email,
    is_active,
    updated_at
FROM deposit_methods 
WHERE is_active = true
ORDER BY method_type, updated_at DESC;
