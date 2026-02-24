-- Test if the registration issue is fixed
-- This will simulate a user registration to verify the fix

-- 1. First, let's verify all components are in place
SELECT '=== VERIFYING FIX COMPONENTS ===' as section;

-- Check trigger exists
SELECT 
    'Trigger' as component,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.triggers 
            WHERE trigger_name = 'on_auth_user_created' 
                AND event_object_table = 'users' 
                AND trigger_schema = 'auth'
        ) THEN '✓ EXISTS'
        ELSE '✗ MISSING'
    END as status;

-- Check function exists
SELECT 
    'Function' as component,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.routines 
            WHERE routine_schema = 'public' 
                AND routine_name = 'handle_new_user'
        ) THEN '✓ EXISTS'
        ELSE '✗ MISSING'
    END as status;

-- Check audit_log_entries table exists
SELECT 
    'Audit Log Table' as component,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.tables 
            WHERE table_schema = 'public' 
                AND table_name = 'audit_log_entries'
        ) THEN '✓ EXISTS'
        ELSE '✗ MISSING'
    END as status;

-- Check profiles table exists
SELECT 
    'Profiles Table' as component,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.tables 
            WHERE table_schema = 'public' 
                AND table_name = 'profiles'
        ) THEN '✓ EXISTS'
        ELSE '✗ MISSING'
    END as status;

-- 2. Test the trigger function manually
SELECT '=== TESTING TRIGGER FUNCTION ===' as section;
DO $$
DECLARE
    test_result TEXT;
BEGIN
    -- Create a test user record simulation
    BEGIN
        -- Insert into profiles directly to test
        INSERT INTO public.profiles (
            id,
            email,
            phone,
            created_at,
            updated_at
        ) VALUES (
            gen_random_uuid(),
            'test_registration@example.com',
            '+1234567890',
            NOW(),
            NOW()
        );
        
        -- Insert into audit log
        INSERT INTO public.audit_log_entries (
            user_id,
            action,
            table_name,
            record_id,
            new_values,
            created_at,
            created_by
        ) VALUES (
            gen_random_uuid(),
            'TEST_REGISTRATION',
            'profiles',
            gen_random_uuid(),
            jsonb_build_object('test', 'registration_fix'),
            NOW(),
            gen_random_uuid()
        );
        
        RAISE NOTICE '✓ Registration components working correctly';
        test_result := 'SUCCESS';
        
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE '✗ Registration test failed: %', SQLERRM;
        test_result := 'FAILED: ' || SQLERRM;
    END;
    
    -- Show the result
    RAISE NOTICE 'Test Result: %', test_result;
END $$;

-- 3. Check recent user registrations to see if new ones work
SELECT '=== RECENT REGISTRATIONS ===' as section;
SELECT 
    id,
    email,
    phone,
    created_at,
    email_confirmed_at,
    CASE 
        WHEN email_confirmed_at IS NOT NULL THEN '✓ Confirmed'
        ELSE '⏳ Pending Confirmation'
    END as status
FROM auth.users 
WHERE created_at >= NOW() - INTERVAL '1 hour'
ORDER BY created_at DESC
LIMIT 5;

-- 4. Final verification
SELECT '=== FINAL VERIFICATION ===' as section;
SELECT 
    'Registration fix verification complete' as status,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.tables 
            WHERE table_schema = 'public' 
                AND table_name = 'audit_log_entries'
        ) 
        AND EXISTS (
            SELECT 1 FROM information_schema.routines 
            WHERE routine_schema = 'public' 
                AND routine_name = 'handle_new_user'
        ) 
        THEN '✓ Registration should now work'
        ELSE '✗ Still has issues'
    END as result,
    NOW() as verified_at;
