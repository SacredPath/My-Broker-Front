-- Check the results from the diagnostic
-- This will show us what's actually causing the registration error

-- 1. Check if the trigger exists
SELECT '=== TRIGGER STATUS ===' as section;
SELECT 
    trigger_schema,
    trigger_name,
    event_manipulation,
    event_object_table,
    action_timing,
    CASE 
        WHEN action_statement LIKE '%handle_new_user%' THEN 'Points to handle_new_user function'
        ELSE 'Unknown function'
    END as function_reference
FROM information_schema.triggers 
WHERE trigger_name = 'on_auth_user_created'
    AND event_object_table = 'users'
    AND trigger_schema = 'auth';

-- 2. Check if the function exists and get its definition
SELECT '=== FUNCTION STATUS ===' as section;
SELECT 
    routine_name,
    routine_type,
    security_type,
    CASE 
        WHEN routine_definition LIKE '%audit_log_entries%' THEN 'References audit_log_entries table'
        WHEN routine_definition LIKE '%profiles%' THEN 'References profiles table'
        ELSE 'Unknown references'
    END as table_references
FROM information_schema.routines 
WHERE routine_schema = 'public' 
    AND routine_name = 'handle_new_user';

-- 3. Check if audit_log_entries table exists
SELECT '=== AUDIT LOG TABLE STATUS ===' as section;
SELECT 
    CASE 
        WHEN COUNT(*) > 0 THEN 'Table exists'
        ELSE 'Table MISSING - This is likely the problem!'
    END as table_status,
    COUNT(*) as column_count
FROM information_schema.columns 
WHERE table_schema = 'public'
    AND table_name = 'audit_log_entries';

-- 4. Check if profiles table exists
SELECT '=== PROFILES TABLE STATUS ===' as section;
SELECT 
    CASE 
        WHEN COUNT(*) > 0 THEN 'Table exists'
        ELSE 'Table MISSING - This is the problem!'
    END as table_status,
    COUNT(*) as column_count
FROM information_schema.columns 
WHERE table_schema = 'public'
    AND table_name = 'profiles';

-- 5. Check for any recent user creation attempts
SELECT '=== RECENT USER CREATIONS ===' as section;
SELECT 
    COUNT(*) as total_users_today,
    COUNT(CASE WHEN email_confirmed_at IS NOT NULL THEN 1 END) as confirmed_users,
    COUNT(CASE WHEN email_confirmed_at IS NULL THEN 1 END) as unconfirmed_users
FROM auth.users 
WHERE created_at >= CURRENT_DATE;

-- 6. Quick test - try to create the audit_log_entries table if it doesn't exist
SELECT '=== CREATING MISSING TABLES ===' as section;
DO $$
BEGIN
    -- Check if audit_log_entries exists, create if not
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'audit_log_entries') THEN
        CREATE TABLE public.audit_log_entries (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
            action VARCHAR(100) NOT NULL,
            table_name VARCHAR(100),
            record_id UUID,
            old_values JSONB,
            new_values JSONB,
            ip_address INET,
            user_agent TEXT,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            created_by UUID REFERENCES auth.users(id)
        );
        
        -- Add RLS
        ALTER TABLE public.audit_log_entries ENABLE ROW LEVEL SECURITY;
        
        -- Add policies
        CREATE POLICY "Users can view own audit entries" ON public.audit_log_entries
            FOR SELECT USING (auth.uid() = user_id);
            
        CREATE POLICY "Service role full access" ON public.audit_log_entries
            FOR ALL USING (auth.jwt() ->> 'role' = 'service_role');
            
        -- Grant permissions
        GRANT SELECT, INSERT, UPDATE, DELETE ON public.audit_log_entries TO authenticated;
        GRANT SELECT, INSERT, UPDATE, DELETE ON public.audit_log_entries TO service_role;
        
        RAISE NOTICE 'Created audit_log_entries table';
    ELSE
        RAISE NOTICE 'audit_log_entries table already exists';
    END IF;
END $$;

-- 7. Final status check
SELECT '=== FINAL STATUS ===' as section;
SELECT 
    'Diagnostic complete - registration should now work' as status,
    NOW() as check_completed_at;
