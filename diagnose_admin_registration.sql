-- Diagnose Admin Registration Issues
-- This query helps identify why admin registration is failing

-- Check if the user can access the database
SELECT 
    'Database Connection' as test_type,
    CASE 
        WHEN COUNT(*) > 0 THEN 'SUCCESS'
        ELSE 'FAILED'
    END as connection_status,
    NOW() as test_timestamp
FROM information_schema.tables 
WHERE table_schema = 'public'
LIMIT 1;

-- Check backoffice_roles table exists and has correct structure
SELECT 
    'backoffice_roles_table' as test_type,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.tables 
            WHERE table_schema = 'public' AND table_name = 'backoffice_roles'
        ) THEN 'EXISTS'
        ELSE 'MISSING'
    END as table_status,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_schema = 'public' 
            AND table_name = 'backoffice_roles' 
            AND column_name = 'user_id'
        ) AND EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_schema = 'public' 
            AND table_name = 'backoffice_roles' 
            AND column_name = 'role'
        ) THEN 'CORRECT_STRUCTURE'
        ELSE 'MISSING_COLUMNS'
    END as structure_status;

-- Check profiles table has admin-related columns
SELECT 
    'profiles_admin_columns' as test_type,
    STRING_AGG(column_name, ', ' ORDER BY ordinal_position) as existing_columns,
    CASE 
        WHEN COUNT(CASE WHEN column_name IN ('role', 'registration_type', 'position', 'first_name', 'last_name', 'phone') THEN 1 END) = 5 
        THEN 'ALL_ADMIN_COLUMNS_PRESENT'
        ELSE 'MISSING_ADMIN_COLUMNS'
    END as admin_column_status
FROM information_schema.columns 
WHERE table_schema = 'public' 
    AND table_name = 'profiles'
    AND column_name IN ('role', 'registration_type', 'position', 'first_name', 'last_name', 'phone');

-- Check for any triggers that might interfere with registration
SELECT 
    'triggers_check' as test_type,
    STRING_AGG(trigger_name, ', ') as existing_triggers,
    STRING_AGG(event_manipulation, ', ') as trigger_events,
    STRING_AGG(action_timing, ', ') as trigger_timing
FROM information_schema.triggers 
WHERE trigger_schema = 'public'
    AND (trigger_name LIKE '%user%' OR trigger_name LIKE '%profile%' OR trigger_name LIKE '%registration%')
GROUP BY 'triggers_check';

-- Check RLS policies that might block registration
SELECT 
    'rls_policies' as test_type,
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual
FROM pg_policies 
WHERE schemaname = 'public'
    AND tablename IN ('profiles', 'backoffice_roles')
ORDER BY tablename, policyname;

-- Test insert into backoffice_roles (simulate registration)
SELECT 
    'insert_test' as test_type,
    CASE 
        WHEN COUNT(*) = 0 THEN 'READY_FOR_INSERT'
        ELSE 'HAS_DATA'
    END as insert_readiness
FROM backoffice_roles;

-- Test insert into profiles with admin role (simulate registration)
SELECT 
    'profile_insert_test' as test_type,
    CASE 
        WHEN COUNT(*) = 0 THEN 'READY_FOR_INSERT'
        ELSE 'HAS_DATA'
    END as insert_readiness
FROM profiles 
WHERE role IN ('superadmin', 'admin', 'support');

-- Check for any foreign key constraints that might block registration
SELECT 
    'foreign_keys' as test_type,
    tc.constraint_name,
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name,
    rc.update_rule,
    rc.delete_rule
FROM information_schema.table_constraints AS tc 
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
    AND ccu.table_schema = tc.table_schema
LEFT JOIN information_schema.referential_constraints AS rc
    ON tc.constraint_name = rc.constraint_name
    AND tc.constraint_schema = rc.constraint_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
    AND tc.table_name IN ('profiles', 'backoffice_roles')
ORDER BY tc.table_name, tc.constraint_name;

-- Check for any unique constraints that might cause issues
SELECT 
    'unique_constraints' as test_type,
    tc.constraint_name,
    tc.table_name,
    STRING_AGG(kcu.column_name, ', ') as columns
FROM information_schema.table_constraints AS tc 
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
WHERE tc.constraint_type = 'UNIQUE'
    AND tc.table_name IN ('profiles', 'backoffice_roles')
ORDER BY tc.table_name, tc.constraint_name;

-- Check current admin users
SELECT 
    'current_admins' as test_type,
    p.id,
    p.email,
    p.role,
    p.registration_type,
    p.created_at,
    p.updated_at,
    br.role as backoffice_role,
    br.created_at as role_assigned_at
FROM profiles p
LEFT JOIN backoffice_roles br ON p.id = br.user_id
WHERE p.role IN ('superadmin', 'admin', 'support')
ORDER BY p.created_at DESC
LIMIT 10;

-- Check for any recent registration failures
SELECT 
    'recent_registrations' as test_type,
    COUNT(*) as total_attempts,
    COUNT(CASE WHEN email LIKE '%@%' THEN 1 END) as valid_emails,
    COUNT(CASE WHEN role IS NOT NULL THEN 1 END) as with_role,
    MIN(created_at) as earliest_registration,
    MAX(created_at) as latest_registration
FROM profiles
WHERE created_at > NOW() - INTERVAL '7 days'
    AND role IN ('superadmin', 'admin', 'support');

-- Summary report
SELECT 
    'summary' as test_type,
    'Database Diagnostics Complete' as status,
    NOW() as diagnostic_timestamp;
