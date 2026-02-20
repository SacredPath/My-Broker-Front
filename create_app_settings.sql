-- Create app_settings table
-- This table stores application-wide settings and configuration

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

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_app_settings_key ON public.app_settings(setting_key);
CREATE INDEX IF NOT EXISTS idx_app_settings_category ON public.app_settings(category);

-- Create updated_at trigger
DROP TRIGGER IF EXISTS handle_app_settings_updated_at ON public.app_settings;
CREATE TRIGGER handle_app_settings_updated_at
    BEFORE UPDATE ON public.app_settings
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Enable Row Level Security
ALTER TABLE public.app_settings ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Service role full access to app_settings" ON public.app_settings
    FOR ALL USING (auth.jwt() ->> 'role' = 'service_role');

CREATE POLICY "Authenticated users can read app_settings" ON public.app_settings
    FOR SELECT USING (auth.role() = 'authenticated');

-- Grant permissions
GRANT SELECT ON public.app_settings TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.app_settings TO service_role;

-- Insert default settings
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

-- Verify creation
SELECT 
    'app_settings' as table_name,
    'TABLE' as object_type,
    'CREATED' as status,
    NOW() as created_at;
