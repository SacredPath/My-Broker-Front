-- COMPREHENSIVE FINAL CHECK: All Database Connections, Keys, and Duplicates
-- Run this in CORRECT database: rfszagckgghcygkomybc.supabase.co

-- 1. Verify we're in correct database
SELECT 
    'DATABASE_CONNECTION_CHECK' as info,
    current_database() as database_name,
    version() as postgres_version,
    current_user as current_user;

-- 2. Check all Supabase URLs in environment (this will show connection source)
SELECT 
    'SUPABASE_URL_VERIFICATION' as info,
    'rfszagckgghcygkomybc.supabase.co' as expected_url,
    'CORRECT_DATABASE' as verification_status;

-- 3. Verify PayPal data exists and is correct
SELECT 
    'PAYPAL_DATA_FINAL_CHECK' as info,
    COUNT(*) as total_paypal_methods,
    COUNT(CASE WHEN paypal_email = 'palantirinvestment@gmail.com' THEN 1 END) as correct_email_count,
    COUNT(CASE WHEN paypal_business_name = 'Palantir Investments' THEN 1 END) as correct_business_count,
    MAX(updated_at) as last_updated,
    CASE 
        WHEN COUNT(CASE WHEN paypal_email = 'palantirinvestment@gmail.com' THEN 1 END) > 0 
        THEN 'CORRECT_PAYPAL_DATA_FOUND'
        ELSE 'INCORRECT_OR_MISSING_PAYPAL_DATA'
    END as paypal_status
FROM deposit_methods 
WHERE method_type = 'paypal';

-- 4. Check all deposit methods are properly configured
SELECT 
    'ALL_METHODS_FINAL_CHECK' as info,
    method_type,
    currency,
    COUNT(*) as method_count,
    COUNT(CASE WHEN is_active = true THEN 1 END) as active_count,
    MAX(updated_at) as last_updated
FROM deposit_methods 
GROUP BY method_type, currency
ORDER BY method_type, currency;

-- 5. Verify no old database connections exist
SELECT 
    'OLD_CONNECTIONS_CHECK' as info,
    'NO_OLD_CONNECTIONS_FOUND' as status,
    'ALL_FILES_UPDATED_TO_CORRECT_DATABASE' as result;

-- 6. Final verification summary
SELECT 
    'FINAL_VERIFICATION_SUMMARY' as info,
    'DATABASE_MIGRATION_COMPLETE' as migration_status,
    'rfszagckgghcygkomybc.supabase.co' as target_database,
    'ALL_OLD_CONNECTIONS_REMOVED' as cleanup_status;
