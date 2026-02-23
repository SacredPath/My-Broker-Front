-- Check Supabase auth configuration and constraints
-- The error is happening at the auth level, not profiles level

-- 1. Check if there are any remaining constraints on auth.users that we can see
SELECT 'AUTH_USERS_CONSTRAINTS' as info,
       tc.constraint_name,
       tc.constraint_type,
       cc.check_clause
FROM information_schema.table_constraints tc
LEFT JOIN information_schema.check_constraints cc ON tc.constraint_name = cc.constraint_name
WHERE tc.table_schema = 'auth' 
    AND tc.table_name = 'users'
ORDER BY tc.constraint_name;

-- 2. Check if there are any functions that might be called during auth
SELECT 'AUTH_RELATED_FUNCTIONS' as info,
       proname,
       prosrc
FROM pg_proc 
WHERE proname LIKE '%auth%' 
    OR proname LIKE '%user%' 
    OR proname LIKE '%signup%'
    AND pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')
ORDER BY proname;

-- 3. Check for any remaining triggers we might have missed
SELECT 'ALL_TRIGGERS' as info,
       trigger_schema,
       event_object_table,
       trigger_name,
       action_timing,
       action_condition,
       action_statement
FROM information_schema.triggers 
WHERE trigger_schema IN ('auth', 'public')
ORDER BY trigger_schema, event_object_table, trigger_name;

-- 4. Check if there are any extension conflicts
SELECT 'INSTALLED_EXTENSIONS' as info,
       extname,
       extversion,
       extrelocatable
FROM pg_extension 
ORDER BY extname;

-- 5. Check database version and configuration
SELECT 'DATABASE_CONFIG' as info,
       current_database(),
       version(),
       current_setting('max_connections'),
       current_setting('shared_buffers'),
       current_setting('work_mem');

-- 6. Check if there are any schema-level permissions issues
SELECT 'SCHEMA_PERMISSIONS' as info,
       schema_name,
       default_character_set_catalog,
       default_character_set_schema
FROM information_schema.schemata 
WHERE schema_name IN ('auth', 'public')
ORDER BY schema_name;
