-- Simple PayPal debug without JWT manipulation

-- 1. Check current user context
SELECT 
    'CURRENT_USER_INFO' as info,
    current_user as user,
    session_user as session_user,
    current_database() as database;

-- 2. Check if RLS is enabled
SELECT 
    'RLS_STATUS' as info,
    schemaname,
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename = 'deposit_methods';

-- 3. Check existing RLS policies
SELECT 
    'EXISTING_POLICIES' as info,
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd
FROM pg_policies 
WHERE tablename = 'deposit_methods'
ORDER BY policyname;

-- 4. Test query as current user
SELECT 
    'USER_ACCESS_TEST' as info,
    id,
    method_name,
    method_type,
    paypal_email,
    paypal_business_name,
    is_active,
    updated_at
FROM deposit_methods 
WHERE method_type = 'paypal';

-- 5. Count all methods vs what user sees
SELECT 
    'COUNT_COMPARISON' as info,
    (SELECT COUNT(*) FROM deposit_methods WHERE is_active = true) as total_active_methods,
    (SELECT COUNT(*) FROM deposit_methods WHERE method_type = 'paypal') as total_paypal_methods,
    (SELECT COUNT(*) FROM deposit_methods WHERE method_type = 'paypal' AND paypal_email IS NOT NULL) as paypal_with_email;

-- 6. Show all active methods for comparison
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
