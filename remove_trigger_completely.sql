-- Completely remove the trigger to test if it's causing the issue
-- This will disable all automatic profile creation during signup

-- 1. Drop the trigger completely
SELECT '=== REMOVING TRIGGER ===' as section;
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- 2. Drop the function as well
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;

-- 3. Verify trigger is removed
SELECT '=== VERIFYING TRIGGER REMOVAL ===' as section;
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.triggers 
            WHERE trigger_name = 'on_auth_user_created' 
                AND event_object_table = 'users' 
                AND trigger_schema = 'auth'
        ) THEN '✗ TRIGGER STILL EXISTS'
        ELSE '✓ TRIGGER SUCCESSFULLY REMOVED'
    END as trigger_status;

-- 4. Check if function is removed
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.routines 
            WHERE routine_schema = 'public' 
                AND routine_name = 'handle_new_user'
        ) THEN '✗ FUNCTION STILL EXISTS'
        ELSE '✓ FUNCTION SUCCESSFULLY REMOVED'
    END as function_status;

-- 5. Test if registration works without trigger
SELECT '=== REGISTRATION SHOULD WORK NOW ===' as section;
SELECT 
    'All triggers removed - registration should work without automatic profile creation' as status,
    'Profile will need to be created manually after signup' as note,
    NOW() as trigger_removed_at;
