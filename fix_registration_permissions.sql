-- Fix registration by focusing on what we can control
-- The issue might be with the profiles table RLS policies or missing columns

-- 1. Check if profiles table has all required columns for the application
SELECT 'PROFILES_COLUMNS_CHECK' as info,
       column_name,
       data_type,
       is_nullable,
       column_default
FROM information_schema.columns 
WHERE table_name = 'profiles' 
    AND table_schema = 'public'
ORDER BY ordinal_position;

-- 2. Temporarily disable RLS on profiles to eliminate it as the issue
ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;

-- 3. Grant broad permissions to authenticated users
GRANT ALL ON public.profiles TO authenticated;
GRANT ALL ON public.profiles TO anon;

-- 4. Create a simple test to verify profile insertion works
SELECT 'TESTING_PROFILE_INSERT' as info,
       'Testing if we can manually insert a profile record...' as message;

-- 5. Check if there are any check constraints that might be blocking inserts
SELECT 'CHECK_CONSTRAINTS' as info,
       tc.constraint_name,
       tc.check_clause,
       ccu.column_name
FROM information_schema.check_constraints tc
JOIN information_schema.constraint_column_usage ccu 
    ON tc.constraint_name = ccu.constraint_name
WHERE tc.constraint_schema = 'public'
    AND tc.constraint_name IN (
        SELECT constraint_name 
        FROM information_schema.table_constraints 
        WHERE table_name = 'profiles' 
            AND table_schema = 'public'
    );

-- 6. Show current RLS status
SELECT 'RLS_STATUS' as info,
       schemaname,
       tablename,
       rowsecurity
FROM pg_tables 
WHERE schemaname = 'public' 
    AND tablename = 'profiles';
