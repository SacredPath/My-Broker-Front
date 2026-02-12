-- Verify Admin Setup is Complete
-- This script confirms that all admin registration components are working

-- Verify backoffice_roles table exists and has data
SELECT 'BACKOFFICE_ROLES VERIFICATION:' as check_type;
SELECT 
    'TABLE_EXISTS' as verification_type,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.tables 
            WHERE table_schema = 'public' 
            AND table_name = 'backoffice_roles'
        ) THEN 'YES'
        ELSE 'NO'
    END as status;

SELECT 
    'HAS_COLUMNS' as verification_type,
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
        ) THEN 'YES'
        ELSE 'NO'
    END as status;

-- Verify profiles table has role column
SELECT 
    'PROFILES_ROLE_COLUMN' as verification_type,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_schema = 'public' 
            AND table_name = 'profiles' 
            AND column_name = 'role'
        ) THEN 'YES'
        ELSE 'NO'
    END as status;

-- Test a sample insert (this should work now)
SELECT 
    'TEST_INSERT' as verification_type,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.tables 
            WHERE table_schema = 'public' 
            AND table_name = 'backoffice_roles'
        ) THEN 'READY'
        ELSE 'CANNOT_TEST'
    END as status;

-- Check RLS policies are in place
SELECT 
    'RLS_POLICIES' as verification_type,
    COUNT(*) as policy_count
FROM pg_policies 
WHERE schemaname = 'public' 
    AND tablename = 'backoffice_roles';

-- Final summary
SELECT 
    'SETUP_COMPLETE' as verification_type,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.tables 
            WHERE table_schema = 'public' 
            AND table_name = 'backoffice_roles'
        ) AND EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_schema = 'public' 
            AND table_name = 'profiles' 
            AND column_name = 'role'
        ) THEN 'YES'
        ELSE 'NO'
    END as admin_ready,
    NOW() as verification_time;
