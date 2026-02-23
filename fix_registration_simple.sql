-- Simple fix for registration issue
-- Remove the problematic trigger and handle profile creation in the application layer

-- 1. Remove the problematic trigger completely
DROP TRIGGER IF EXISTS handle_new_auth_user_trigger ON auth.users;
DROP FUNCTION IF EXISTS handle_new_auth_user();

-- 2. Ensure RLS is enabled with proper policies
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- 3. Drop and recreate RLS policies to ensure they work correctly
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Service role full access" ON public.profiles;

-- 4. Create proper RLS policies
CREATE POLICY "Users can view own profile" ON public.profiles
    FOR SELECT USING (auth.uid() = id OR auth.jwt() ->> 'role' = 'service_role');

CREATE POLICY "Users can insert own profile" ON public.profiles
    FOR INSERT WITH CHECK (auth.uid() = id OR auth.jwt() ->> 'role' = 'service_role');

CREATE POLICY "Users can update own profile" ON public.profiles
    FOR UPDATE USING (auth.uid() = id OR auth.jwt() ->> 'role' = 'service_role');

CREATE POLICY "Service role full access" ON public.profiles
    FOR ALL USING (auth.jwt() ->> 'role' = 'service_role');

-- 5. Grant proper permissions
GRANT ALL ON public.profiles TO authenticated;
GRANT ALL ON public.profiles TO service_role;

-- 6. Verify the trigger is removed
SELECT 'TRIGGER_REMOVED' as status,
       CASE 
           WHEN NOT EXISTS (
               SELECT 1 FROM information_schema.triggers 
               WHERE trigger_name = 'handle_new_auth_user_trigger'
           ) THEN 'SUCCESS'
           ELSE 'FAILED'
       END as removal_status;

-- 7. Verify RLS policies are correct
SELECT 'RLS_POLICIES_VERIFIED' as status,
       schemaname,
       tablename,
       policyname,
       permissive,
       roles,
       cmd
FROM pg_policies 
WHERE tablename = 'profiles' 
    AND schemaname = 'public'
ORDER BY policyname;
