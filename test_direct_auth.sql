-- Test Supabase auth directly to isolate the issue
-- This will help determine if it's a Supabase service issue

-- 1. Check if we can create a user directly using SQL (this tests if the database itself works)
SELECT 'TESTING_DIRECT_USER_CREATION' as info,
       'Testing direct user creation in auth.users table...' as message;

-- Note: This might fail due to Supabase auth restrictions, but let's try
-- INSERT INTO auth.users (id, email, email_confirmed, created_at, updated_at)
-- VALUES (gen_random_uuid(), 'test@example.com', false, NOW(), NOW());

-- 2. Check the auth.users table structure to see if there are any issues
SELECT 'AUTH_USERS_STRUCTURE' as info,
       column_name,
       data_type,
       is_nullable,
       column_default
FROM information_schema.columns 
WHERE table_name = 'users' 
    AND table_schema = 'auth'
ORDER BY ordinal_position;

-- 3. Check if there are any database-level settings that might affect auth
SELECT 'DATABASE_SETTINGS' as info,
       name,
       setting
FROM pg_settings 
WHERE name LIKE '%auth%' 
    OR name LIKE '%password%' 
    OR name LIKE '%security%'
ORDER BY name;

-- 4. Check if there are any recent error logs
SELECT 'RECENT_ERRORS' as info,
       'Checking for any database error logs...' as message;

-- 5. Check if the issue might be related to email confirmation settings
SELECT 'EMAIL_CONFIG' as info,
       'The issue might be related to Supabase auth email confirmation settings' as message,
       'Check Supabase dashboard: Authentication > Settings > Email confirmation' as suggestion;
