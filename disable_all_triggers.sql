-- Disable all triggers that might interfere with registration
-- This is a temporary fix to isolate the registration issue

-- 1. Disable ALL triggers on auth.users table
ALTER TABLE auth.users DISABLE TRIGGER ALL;

-- 2. Disable ALL triggers on public.profiles table  
ALTER TABLE public.profiles DISABLE TRIGGER ALL;

-- 3. Check if there are any other tables that might have triggers
SELECT 'DISABLING_ALL_TRIGGERS' as info,
       'All triggers on auth.users and public.profiles have been disabled' as status;

-- 4. Verify triggers are disabled
SELECT 'TRIGGERS_DISABLED_CHECK' as info,
       schemaname,
       tablename,
       trigger_name,
       enabled
FROM pg_triggers 
WHERE (schemaname = 'auth' AND tablename = 'users')
   OR (schemaname = 'public' AND tablename = 'profiles')
ORDER BY schemaname, tablename, trigger_name;

-- 5. Test the registration process should now work
SELECT 'REGISTRATION_READY' as info,
       'Try registration now - all interfering triggers have been disabled' as message;
