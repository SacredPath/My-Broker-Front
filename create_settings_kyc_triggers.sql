-- Create missing triggers for settings and KYC pages
-- These are needed for proper functionality of settings and KYC workflows

-- =====================================================
-- 1. KYC APPLICATIONS TABLE AND TRIGGERS
-- =====================================================

-- Create kyc_applications table if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'kyc_applications') THEN
        
        CREATE TABLE public.kyc_applications (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
            status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'submitted', 'under_review', 'verified', 'rejected')),
            first_name TEXT,
            last_name TEXT,
            date_of_birth DATE,
            address TEXT,
            city TEXT,
            country TEXT,
            postal_code TEXT,
            id_document_url TEXT,
            proof_of_address_url TEXT,
            selfie_url TEXT,
            submitted_at TIMESTAMP WITH TIME ZONE,
            reviewed_at TIMESTAMP WITH TIME ZONE,
            reviewed_by UUID REFERENCES auth.users(id),
            rejection_reason TEXT,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
        
        -- Create indexes
        CREATE INDEX idx_kyc_applications_user_id ON public.kyc_applications(user_id);
        CREATE INDEX idx_kyc_applications_status ON public.kyc_applications(status);
        CREATE INDEX idx_kyc_applications_submitted_at ON public.kyc_applications(submitted_at DESC);
        
        RAISE NOTICE 'kyc_applications table created successfully';
    END IF;
END $$;

-- Create updated_at trigger for kyc_applications
DROP TRIGGER IF EXISTS handle_kyc_applications_updated_at ON public.kyc_applications;
CREATE TRIGGER handle_kyc_applications_updated_at
    BEFORE UPDATE ON public.kyc_applications
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Create trigger for KYC status changes
CREATE OR REPLACE FUNCTION public.handle_kyc_status_change()
RETURNS TRIGGER AS $$
BEGIN
    -- Log KYC status changes to audit log
    IF OLD.status IS DISTINCT FROM NEW.status THEN
        INSERT INTO public.audit_log_entries (
            user_id,
            action,
            table_name,
            record_id,
            old_values,
            new_values,
            created_by
        ) VALUES (
            NEW.user_id,
            'KYC_STATUS_CHANGED',
            'kyc_applications',
            NEW.id,
            jsonb_build_object('status', OLD.status),
            jsonb_build_object('status', NEW.status),
            NEW.user_id
        );
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trigger_kyc_status_change ON public.kyc_applications;
CREATE TRIGGER trigger_kyc_status_change
    AFTER UPDATE ON public.kyc_applications
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_kyc_status_change();

-- =====================================================
-- 2. SETTINGS TABLE AND TRIGGERS
-- =====================================================

-- Create settings table if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'settings') THEN
        
        CREATE TABLE public.settings (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
            setting_key VARCHAR(100) NOT NULL,
            setting_value TEXT,
            setting_type VARCHAR(20) DEFAULT 'string' CHECK (setting_type IN ('string', 'boolean', 'number', 'json')),
            category VARCHAR(50) DEFAULT 'general',
            is_public BOOLEAN DEFAULT false,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            UNIQUE(user_id, setting_key)
        );
        
        -- Create indexes
        CREATE INDEX idx_settings_user_id ON public.settings(user_id);
        CREATE INDEX idx_settings_category ON public.settings(category);
        CREATE INDEX idx_settings_key ON public.settings(setting_key);
        
        RAISE NOTICE 'settings table created successfully';
    END IF;
END $$;

-- Create updated_at trigger for settings
DROP TRIGGER IF EXISTS handle_settings_updated_at ON public.settings;
CREATE TRIGGER handle_settings_updated_at
    BEFORE UPDATE ON public.settings
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Create trigger for settings changes
CREATE OR REPLACE FUNCTION public.handle_settings_change()
RETURNS TRIGGER AS $$
BEGIN
    -- Log setting changes to audit log
    IF OLD.setting_value IS DISTINCT FROM NEW.setting_value THEN
        INSERT INTO public.audit_log_entries (
            user_id,
            action,
            table_name,
            record_id,
            old_values,
            new_values,
            created_by
        ) VALUES (
            NEW.user_id,
            'SETTING_CHANGED',
            'settings',
            NEW.id,
            jsonb_build_object('key', OLD.setting_key, 'value', OLD.setting_value),
            jsonb_build_object('key', NEW.setting_key, 'value', NEW.setting_value),
            NEW.user_id
        );
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trigger_settings_change ON public.settings;
CREATE TRIGGER trigger_settings_change
    AFTER UPDATE ON public.settings
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_settings_change();

-- =====================================================
-- 3. KYC STATUS TABLE (Optional - for status tracking)
-- =====================================================

-- Create kyc_status table if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'kyc_status') THEN
        
        CREATE TABLE public.kyc_status (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
            current_status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (current_status IN ('pending', 'submitted', 'under_review', 'verified', 'rejected')),
            last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_by UUID REFERENCES auth.users(id),
            notes TEXT,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
        
        -- Create index
        CREATE INDEX idx_kyc_status_user_id ON public.kyc_status(user_id);
        
        RAISE NOTICE 'kyc_status table created successfully';
    END IF;
END $$;

-- Create updated_at trigger for kyc_status
DROP TRIGGER IF EXISTS handle_kyc_status_updated_at ON public.kyc_status;
CREATE TRIGGER handle_kyc_status_updated_at
    BEFORE UPDATE ON public.kyc_status
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- =====================================================
-- 4. RLS POLICIES FOR SECURITY
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE public.kyc_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.kyc_status ENABLE ROW LEVEL SECURITY;

-- KYC Applications RLS Policies
CREATE POLICY "Users can view own KYC applications" ON public.kyc_applications
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own KYC applications" ON public.kyc_applications
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own KYC applications" ON public.kyc_applications
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Service role full access to KYC applications" ON public.kyc_applications
    FOR ALL USING (auth.jwt() ->> 'role' = 'service_role');

-- Settings RLS Policies
CREATE POLICY "Users can view own settings" ON public.settings
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own settings" ON public.settings
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own settings" ON public.settings
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Service role full access to settings" ON public.settings
    FOR ALL USING (auth.jwt() ->> 'role' = 'service_role');

-- KYC Status RLS Policies
CREATE POLICY "Users can view own KYC status" ON public.kyc_status
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Service role full access to KYC status" ON public.kyc_status
    FOR ALL USING (auth.jwt() ->> 'role' = 'service_role');

-- =====================================================
-- 5. GRANT PERMISSIONS
-- =====================================================

-- KYC Applications permissions
GRANT SELECT, INSERT, UPDATE ON public.kyc_applications TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.kyc_applications TO service_role;

-- Settings permissions
GRANT SELECT, INSERT, UPDATE ON public.settings TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.settings TO service_role;

-- KYC Status permissions
GRANT SELECT ON public.kyc_status TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.kyc_status TO service_role;

-- =====================================================
-- 6. VERIFY CREATION
-- =====================================================

SELECT 
    'KYC Applications Table' as object_name,
    'TABLE' as object_type,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'kyc_applications') THEN '✅ CREATED'
        ELSE '❌ MISSING'
    END as status

UNION ALL

SELECT 
    'Settings Table' as object_name,
    'TABLE' as object_type,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'settings') THEN '✅ CREATED'
        ELSE '❌ MISSING'
    END as status

UNION ALL

SELECT 
    'KYC Status Table' as object_name,
    'TABLE' as object_type,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'kyc_status') THEN '✅ CREATED'
        ELSE '❌ MISSING'
    END as status

UNION ALL

SELECT 
    'handle_kyc_status_change' as object_name,
    'FUNCTION' as object_type,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.routines WHERE routine_schema = 'public' AND routine_name = 'handle_kyc_status_change' AND routine_type = 'FUNCTION') THEN '✅ CREATED'
        ELSE '❌ MISSING'
    END as status

UNION ALL

SELECT 
    'handle_settings_change' as object_name,
    'FUNCTION' as object_type,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.routines WHERE routine_schema = 'public' AND routine_name = 'handle_settings_change' AND routine_type = 'FUNCTION') THEN '✅ CREATED'
        ELSE '❌ MISSING'
    END as status

UNION ALL

SELECT 
    'trigger_kyc_status_change' as object_name,
    'TRIGGER' as object_type,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.triggers WHERE trigger_schema = 'public' AND trigger_name = 'trigger_kyc_status_change') THEN '✅ CREATED'
        ELSE '❌ MISSING'
    END as status

UNION ALL

SELECT 
    'trigger_settings_change' as object_name,
    'TRIGGER' as object_type,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.triggers WHERE trigger_schema = 'public' AND trigger_name = 'trigger_settings_change') THEN '✅ CREATED'
        ELSE '❌ MISSING'
    END as status;
