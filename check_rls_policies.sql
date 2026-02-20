-- Check RLS policies that might be filtering PayPal data

-- 1. Check all RLS policies on deposit_methods table
SELECT 
    'RLS_POLICIES_DEPOSIT_METHODS' as info,
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check,
    check_expr
FROM pg_policies 
WHERE tablename = 'deposit_methods'
ORDER BY policyname;

-- 2. Check if RLS is enabled on deposit_methods
SELECT 
    'RLS_STATUS_DEPOSIT_METHODS' as info,
    schemaname,
    tablename,
    rowsecurity
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename = 'deposit_methods';

-- 3. Check current user and their roles
SELECT 
    'CURRENT_USER_ROLES' as info,
    current_user as current_user,
    session_user as session_user,
    current_database() as database,
    current_setting('request.jwt.claim.role') as jwt_role,
    current_setting('request.jwt.claim.email') as jwt_email;

-- 4. Test direct query as current user
SELECT 
    'DIRECT_QUERY_TEST' as info,
    COUNT(*) as total_methods,
    COUNT(CASE WHEN method_type = 'paypal' THEN 1 END) as paypal_methods,
    COUNT(CASE WHEN paypal_email IS NOT NULL THEN 1 END) as methods_with_paypal_email
FROM deposit_methods;

-- 5. Test query with explicit auth context
SET request.jwt.claim.email = 'markbirkhoff@gmail.com';
SET request.jwt.claim.role = 'authenticated';

SELECT 
    'AUTH_CONTEXT_TEST' as info,
    id,
    method_name,
    method_type,
    paypal_email,
    is_active
FROM deposit_methods 
WHERE method_type = 'paypal';

-- 6. Reset auth context
RESET request.jwt.claim.email;
RESET request.jwt.claim.role;
