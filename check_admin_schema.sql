-- Check Admin Table Schema for Registration Issues
-- This query checks the structure of admin-related tables to identify schema mismatches

-- Check backoffice_roles table structure
SELECT 
    'backoffice_roles' as table_name,
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
    AND table_name = 'backoffice_roles'
ORDER BY ordinal_position;

-- Check profiles table structure for admin-related columns
SELECT 
    'profiles' as table_name,
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
    AND column_name IN ('role', 'registration_type', 'position', 'first_name', 'last_name', 'phone')
ORDER BY ordinal_position;

-- Check if backoffice_roles table exists
SELECT 
    EXISTS (
        SELECT 1 
        FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'backoffice_roles'
    ) as backoffice_roles_exists;

-- Check if profiles table exists
SELECT 
    EXISTS (
        SELECT 1 
        FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'profiles'
    ) as profiles_exists;

-- Check for any foreign key constraints on backoffice_roles
SELECT 
    tc.constraint_name,
    tc.table_name,
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
    AND tc.table_name = 'backoffice_roles';

-- Check for any indexes on backoffice_roles
SELECT 
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
    AND tablename = 'backoffice_roles';

-- Sample data check for backoffice_roles
SELECT 
    COUNT(*) as total_records,
    COUNT(DISTINCT role) as unique_roles,
    COUNT(DISTINCT user_id) as unique_users
FROM backoffice_roles;

-- Sample data check for profiles with admin roles
SELECT 
    COUNT(*) as total_admin_profiles,
    COUNT(DISTINCT role) as admin_role_types,
    COUNT(CASE WHEN role IN ('superadmin', 'admin', 'support') THEN 1 END) as valid_admin_roles
FROM profiles
WHERE role IN ('superadmin', 'admin', 'support');

-- Check for any NULL values in critical columns
SELECT 
    'backoffice_roles' as table_name,
    COUNT(CASE WHEN user_id IS NULL THEN 1 END) as null_user_ids,
    COUNT(CASE WHEN role IS NULL THEN 1 END) as null_roles
FROM backoffice_roles;

SELECT 
    'profiles' as table_name,
    COUNT(CASE WHEN email IS NULL THEN 1 END) as null_emails,
    COUNT(CASE WHEN role IS NULL THEN 1 END) as null_roles,
    COUNT(CASE WHEN registration_type IS NULL THEN 1 END) as null_registration_types
FROM profiles
WHERE role IN ('superadmin', 'admin', 'support');

-- Check for any duplicate user_id in backoffice_roles
SELECT 
    user_id,
    COUNT(*) as duplicate_count
FROM backoffice_roles
GROUP BY user_id
HAVING COUNT(*) > 1;

-- Check for any invalid role values
SELECT 
    role,
    COUNT(*) as count
FROM backoffice_roles
WHERE role NOT IN ('superadmin', 'admin', 'support', 'user')
GROUP BY role;

-- Check for any invalid role values in profiles
SELECT 
    role,
    COUNT(*) as count
FROM profiles
WHERE role NOT IN ('superadmin', 'admin', 'support', 'user')
GROUP BY role;
