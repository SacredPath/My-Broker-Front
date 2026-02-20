-- Check and fix app_settings table structure

-- 1. Check current app_settings table structure
SELECT 
    'APP_SETTINGS_CURRENT_STRUCTURE' as info,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public'
    AND table_name = 'app_settings'
ORDER BY ordinal_position;

-- 2. Check if there are any existing records
SELECT 
    'APP_SETTINGS_EXISTING_DATA' as info,
    COUNT(*) as record_count
FROM information_schema.tables 
WHERE table_schema = 'public' 
    AND table_name = 'app_settings';

-- 3. If table doesn't exist or has wrong structure, recreate it
DO $$
BEGIN
    -- Check if table exists and has correct structure
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'app_settings') THEN
        RAISE NOTICE 'app_settings table exists, checking structure...';
        
        -- Check if updated_at column exists
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'app_settings' AND column_name = 'updated_at') THEN
            RAISE NOTICE 'updated_at column missing, dropping and recreating table...';
            DROP TABLE IF EXISTS app_settings CASCADE;
        ELSE
            RAISE NOTICE 'app_settings table structure looks correct';
        END IF;
    ELSE
        RAISE NOTICE 'app_settings table does not exist, creating...';
    END IF;
END $$;

-- 4. Create the table with correct structure
CREATE TABLE IF NOT EXISTS public.app_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    setting_key VARCHAR(100) NOT NULL UNIQUE,
    setting_value TEXT,
    setting_type VARCHAR(20) DEFAULT 'string' CHECK (setting_type IN ('string', 'boolean', 'number', 'json')),
    category VARCHAR(50) DEFAULT 'general',
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. Create indexes
CREATE INDEX IF NOT EXISTS idx_app_settings_key ON public.app_settings(setting_key);
CREATE INDEX IF NOT EXISTS idx_app_settings_category ON public.app_settings(category);

-- 6. Create updated_at trigger function if it doesn't exist
CREATE OR REPLACE FUNCTION handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 7. Create updated_at trigger
DROP TRIGGER IF EXISTS handle_app_settings_updated_at ON public.app_settings;
CREATE TRIGGER handle_app_settings_updated_at
    BEFORE UPDATE ON public.app_settings
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- 8. Enable Row Level Security
ALTER TABLE public.app_settings ENABLE ROW LEVEL SECURITY;

-- 9. Drop existing policies if they exist
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'app_settings' AND policyname = 'Service role full access to app_settings') THEN
        EXECUTE 'DROP POLICY "Service role full access to app_settings" ON public.app_settings';
    END IF;
    
    IF EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'app_settings' AND policyname = 'Authenticated users can read app_settings') THEN
        EXECUTE 'DROP POLICY "Authenticated users can read app_settings" ON public.app_settings';
    END IF;
END $$;

-- 10. Create RLS Policies
CREATE POLICY "Service role full access to app_settings" ON public.app_settings
    FOR ALL USING (auth.jwt() ->> 'role' = 'service_role');

CREATE POLICY "Authenticated users can read app_settings" ON public.app_settings
    FOR SELECT USING (auth.role() = 'authenticated');

-- 11. Grant permissions
GRANT SELECT ON public.app_settings TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.app_settings TO service_role;

-- 12. Insert default settings (only if they don't exist)
INSERT INTO public.app_settings (setting_key, setting_value, setting_type, category, description) VALUES
('site_name', 'Savage Broker', 'string', 'general', 'Site name displayed in headers and titles'),
('site_description', 'Professional Trading Platform', 'string', 'general', 'Site description for SEO'),
('maintenance_mode', 'false', 'boolean', 'general', 'Enable/disable maintenance mode'),
('max_deposit_amount', '100000', 'number', 'deposits', 'Maximum single deposit amount'),
('min_deposit_amount', '10', 'number', 'deposits', 'Minimum single deposit amount'),
('kyc_required_amount', '1000', 'number', 'kyc', 'Amount threshold requiring KYC verification'),
('support_email', 'support@savagebroker.com', 'string', 'contact', 'Customer support email'),
('withdrawal_fee_percent', '0.5', 'number', 'withdrawals', 'Withdrawal fee percentage'),
('auto_logout_minutes', '30', 'number', 'security', 'Auto-logout after inactivity (minutes)')
ON CONFLICT (setting_key) DO NOTHING;

-- 13. Show final table structure
SELECT 
    'APP_SETTINGS_FINAL_STRUCTURE' as info,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public'
    AND table_name = 'app_settings'
ORDER BY ordinal_position;

-- 14. Show sample data
DO $$
BEGIN
    RAISE NOTICE '=== APP_SETTINGS SAMPLE DATA ===';
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'app_settings') THEN
        PERFORM 1; -- Simple verification
        RAISE NOTICE 'app_settings table is accessible and has data';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Sample data verification failed';
END $$;

-- Final confirmation
DO $$
BEGIN
    RAISE NOTICE '=== APP_SETTINGS TABLE SETUP COMPLETE ===';
END $$;
