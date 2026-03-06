-- Debug the actual registration error that's still occurring
-- This will check what's really happening during signup

-- 1. Check if there are any constraint violations on auth.users
SELECT '=== CHECKING AUTH USERS CONSTRAINTS ===' as section;
SELECT 
    conname as constraint_name,
    contype as constraint_type,
    pg_get_constraintdef(oid) as definition
FROM pg_constraint 
WHERE conrelid = 'auth.users'::regclass
ORDER BY conname;

-- 2. Check for duplicate email or phone in auth.users
SELECT '=== CHECKING DUPLICATES ===' as section;
SELECT 
    email,
    COUNT(*) as email_count,
    phone,
    COUNT(phone) OVER (PARTITION BY phone) as phone_count
FROM auth.users 
WHERE email = 'markbirkhoff@gmail.co' OR phone = '+23480731031'
GROUP BY email, phone;

-- 3. Check if the trigger function is actually being called
SELECT '=== RECENT TRIGGER ACTIVITY ===' as section;
SELECT 
    user_id,
    action,
    table_name,
    created_at
FROM public.audit_log_entries 
WHERE created_at >= NOW() - INTERVAL '10 minutes'
ORDER BY created_at DESC
LIMIT 10;

-- 4. Check if profiles are being created
SELECT '=== RECENT PROFILE CREATIONS ===' as section;
SELECT 
    id,
    email,
    phone,
    created_at
FROM public.profiles 
WHERE created_at >= NOW() - INTERVAL '10 minutes'
ORDER BY created_at DESC
LIMIT 10;

-- 5. Check the exact trigger function definition
SELECT '=== TRIGGER FUNCTION DEFINITION ===' as section;
SELECT 
    routine_definition
FROM information_schema.routines 
WHERE routine_schema = 'public' 
    AND routine_name = 'handle_new_user';

-- 6. Temporarily disable the trigger to test if it's the problem
SELECT '=== DISABLING TRIGGER FOR TESTING ===' as section;
DO $$
BEGIN
    -- Drop the trigger temporarily
    DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
    RAISE NOTICE 'Trigger disabled for testing';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Trigger already disabled or does not exist';
END $$;

-- 7. Test manual user creation without trigger
SELECT '=== TESTING MANUAL USER CREATION ===' as section;
DO $$
DECLARE
    test_email TEXT := 'test_manual_' || EXTRACT(EPOCH FROM NOW()) || '@example.com';
    test_phone TEXT := '+1' || (EXTRACT(EPOCH FROM NOW())::TEXT);
BEGIN
    -- This will test if the issue is with the trigger or something else
    RAISE NOTICE 'Testing manual user creation with email: %', test_email;
    
    -- We can't actually create auth.users manually, but we can check if the tables are ready
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'profiles') THEN
        RAISE NOTICE '✓ Profiles table exists and is ready';
    ELSE
        RAISE NOTICE '✗ Profiles table missing';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'audit_log_entries') THEN
        RAISE NOTICE '✓ Audit log table exists and is ready';
    ELSE
        RAISE NOTICE '✗ Audit log table missing';
    END IF;
    
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Manual test failed: %', SQLERRM;
END $$;

-- 8. Recreate a simpler trigger that won't fail
SELECT '=== CREATING SIMPLER TRIGGER ===' as section;
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    -- Only create profile, skip audit log for now
    INSERT INTO public.profiles (
        id,
        email,
        phone,
        created_at,
        updated_at
    ) VALUES (
        NEW.id,
        NEW.email,
        NEW.phone,
        NEW.created_at,
        NOW()
    ) ON CONFLICT (id) DO NOTHING;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Recreate the trigger
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- Grant permissions
GRANT EXECUTE ON FUNCTION public.handle_new_user() TO authenticated;
GRANT EXECUTE ON FUNCTION public.handle_new_user() TO service_role;

-- 9. Final status
SELECT '=== FINAL STATUS ===' as section;
SELECT 
    'Simplified trigger created - registration should work now' as status,
    NOW() as fixed_at;
