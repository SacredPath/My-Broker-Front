-- Final comprehensive check for anything that could interfere with auth

-- 1. Check ALL functions in public schema that might be related to auth
SELECT 'ALL_PUBLIC_FUNCTIONS' as info,
       proname,
       prosrc,
       prosecdef
FROM pg_proc 
WHERE pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')
ORDER BY proname;

-- 2. Check if there are any event triggers we missed
SELECT 'EVENT_TRIGGERS' as info,
       evtname,
       evtevent,
       evtowner,
       evtfoid::regprocedure as function_name
FROM pg_event_trigger 
ORDER BY evtname;

-- 3. Check if there are any foreign key relationships that might cause issues
SELECT 'FOREIGN_KEY_CHECK' as info,
       tc.table_name,
       tc.constraint_name,
       kcu.column_name,
       ccu.table_name AS foreign_table_name,
       ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc 
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
LEFT JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
    AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
    AND tc.table_schema = 'public'
ORDER BY tc.table_name, tc.constraint_name;

-- 4. Check if the auth.users table has any specific constraints we can't see
SELECT 'AUTH_USERS_DEEP_CHECK' as info,
       'Attempting to check auth.users table more thoroughly...' as message;

-- 5. Check database logs for recent errors (if accessible)
SELECT 'DATABASE_LOGS' as info,
       'Checking for any accessible error logs...' as message;
