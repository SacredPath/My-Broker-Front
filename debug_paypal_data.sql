-- Debug script to check all possible sources of PayPal data

-- 1. Check deposit_methods table for PayPal
SELECT 
    'DEPOSIT_METHODS_PAYPAL' as info,
    id,
    method_name,
    method_type,
    currency,
    paypal_email,
    paypal_business_name,
    address,
    is_active,
    created_at,
    updated_at
FROM deposit_methods 
WHERE method_type = 'paypal' OR method_name LIKE '%PayPal%'
ORDER BY updated_at DESC;

-- 2. Check if there are any other tables with PayPal data
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND (table_name LIKE '%deposit%' OR table_name LIKE '%payment%' OR table_name LIKE '%paypal%');

-- 3. Check for any RLS policies that might affect data
SELECT 
    'RLS_POLICIES' as info,
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'deposit_methods';

-- 4. Check current user and their permissions
SELECT 
    'CURRENT_USER' as info,
    current_user as user,
    session_user as session_user,
    current_database() as database;

-- 5. Try a direct query without filters to see all data
SELECT 
    'ALL_DEPOSIT_METHODS_RAW' as info,
    id,
    method_name,
    method_type,
    currency,
    paypal_email,
    paypal_business_name,
    is_active,
    updated_at
FROM deposit_methods 
ORDER BY method_type, updated_at DESC;
