-- Create handle_new_user function
-- This function is called when a new user registers in auth.users
-- Creates corresponding profile and sets up initial user data

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    -- Create profile for new user
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
    
    -- Add entry to audit log
    INSERT INTO public.audit_log_entries (
        user_id,
        action,
        table_name,
        record_id,
        new_values,
        created_by
    ) VALUES (
        NEW.id,
        'USER_CREATED',
        'profiles',
        NEW.id,
        jsonb_build_object(
            'email', NEW.email,
            'phone', NEW.phone,
            'created_at', NEW.created_at
        ),
        NEW.id
    ) ON CONFLICT DO NOTHING;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger to call function when user is created
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- Grant permissions
GRANT EXECUTE ON FUNCTION public.handle_new_user() TO authenticated;
GRANT EXECUTE ON FUNCTION public.handle_new_user() TO service_role;

-- Verify creation
SELECT 
    'handle_new_user' as object_name,
    'FUNCTION' as object_type,
    'CREATED' as status,
    NOW() as created_at;
