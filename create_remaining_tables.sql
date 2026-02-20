-- Create Remaining Missing Tables
-- These are the less critical tables that were missing from the database

-- 1. Create admin_deposit_method_updates table (13 columns)
CREATE TABLE IF NOT EXISTS admin_deposit_method_updates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    method_id UUID NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    min_amount NUMERIC,
    max_amount NUMERIC,
    fee_percentage NUMERIC,
    fee_fixed NUMERIC,
    processing_time_hours INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    processed BOOLEAN DEFAULT false
);

-- Add indexes for admin_deposit_method_updates
CREATE INDEX IF NOT EXISTS idx_admin_deposit_method_updates_method_id ON admin_deposit_method_updates(method_id);
CREATE INDEX IF NOT EXISTS idx_admin_deposit_method_updates_processed ON admin_deposit_method_updates(processed);

-- 2. Create backoffice_roles table (4 columns)
CREATE TABLE IF NOT EXISTS backoffice_roles (
    user_id UUID PRIMARY KEY,
    role TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for backoffice_roles
CREATE INDEX IF NOT EXISTS idx_backoffice_roles_user_id ON backoffice_roles(user_id);
CREATE INDEX IF NOT EXISTS idx_backoffice_roles_role ON backoffice_roles(role);

-- 3. Create bonuses table (6 columns)
CREATE TABLE IF NOT EXISTS bonuses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    bonus_type TEXT NOT NULL,
    amount_usd NUMERIC NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    meta JSONB
);

-- Add indexes for bonuses
CREATE INDEX IF NOT EXISTS idx_bonuses_user_id ON bonuses(user_id);
CREATE INDEX IF NOT EXISTS idx_bonuses_bonus_type ON bonuses(bonus_type);

-- 4. Create conversion_settings table (8 columns)
CREATE TABLE IF NOT EXISTS conversion_settings (
    id INTEGER PRIMARY KEY,
    auto_convert_enabled BOOLEAN DEFAULT false,
    fees JSONB,
    rounding JSONB,
    rate_provider TEXT,
    refresh_interval INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for conversion_settings
CREATE INDEX IF NOT EXISTS idx_conversion_settings_id ON conversion_settings(id);

-- 5. Create conversions table (11 columns)
CREATE TABLE IF NOT EXISTS conversions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    from_currency TEXT NOT NULL,
    to_currency TEXT NOT NULL,
    from_amount NUMERIC NOT NULL,
    to_amount NUMERIC NOT NULL,
    rate NUMERIC NOT NULL,
    fees NUMERIC,
    status TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE
);

-- Add indexes for conversions
CREATE INDEX IF NOT EXISTS idx_conversions_user_id ON conversions(user_id);
CREATE INDEX IF NOT EXISTS idx_conversions_status ON conversions(status);
CREATE INDEX IF NOT EXISTS idx_conversions_created_at ON conversions(created_at);

-- 6. Create email_verification_requests table (10 columns)
CREATE TABLE IF NOT EXISTS email_verification_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    email_address TEXT NOT NULL,
    status TEXT NOT NULL,
    requested_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    processed_at TIMESTAMP WITH TIME ZONE,
    processed_by UUID,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for email_verification_requests
CREATE INDEX IF NOT EXISTS idx_email_verification_requests_user_id ON email_verification_requests(user_id);
CREATE INDEX IF NOT EXISTS idx_email_verification_requests_status ON email_verification_requests(status);

-- 7. Create fx_quotes table (12 columns)
CREATE TABLE IF NOT EXISTS fx_quotes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    from_currency TEXT NOT NULL,
    to_currency TEXT NOT NULL,
    amount NUMERIC NOT NULL,
    rate NUMERIC NOT NULL,
    fees NUMERIC,
    to_amount NUMERIC NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE,
    result NUMERIC,
    source TEXT,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for fx_quotes
CREATE INDEX IF NOT EXISTS idx_fx_quotes_from_to_currency ON fx_quotes(from_currency, to_currency);
CREATE INDEX IF NOT EXISTS idx_fx_quotes_created_at ON fx_quotes(created_at);
CREATE INDEX IF NOT EXISTS idx_fx_quotes_expires_at ON fx_quotes(expires_at);

-- 8. Create kyc_submissions table (23 columns)
CREATE TABLE IF NOT EXISTS kyc_submissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    submission_type TEXT NOT NULL,
    status TEXT NOT NULL,
    first_name TEXT,
    last_name TEXT,
    date_of_birth DATE,
    nationality TEXT,
    residential_address TEXT,
    phone_number TEXT,
    occupation TEXT,
    source_of_funds TEXT,
    purpose_of_account TEXT,
    business_name TEXT,
    business_registration_number TEXT,
    business_address TEXT,
    tax_identification_number TEXT,
    admin_notes TEXT,
    reviewed_by UUID,
    reviewed_at TIMESTAMP WITH TIME ZONE,
    rejection_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for kyc_submissions
CREATE INDEX IF NOT EXISTS idx_kyc_submissions_user_id ON kyc_submissions(user_id);
CREATE INDEX IF NOT EXISTS idx_kyc_submissions_status ON kyc_submissions(status);
CREATE INDEX IF NOT EXISTS idx_kyc_submissions_reviewed_by ON kyc_submissions(reviewed_by);

-- 9. Create notification_history table (12 columns)
CREATE TABLE IF NOT EXISTS notification_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    original_notification_id UUID,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT NOT NULL,
    category TEXT NOT NULL,
    unread BOOLEAN DEFAULT true,
    read_at TIMESTAMP WITH TIME ZONE,
    original_created_at TIMESTAMP WITH TIME ZONE,
    archived_at TIMESTAMP WITH TIME ZONE,
    metadata JSONB
);

-- Add indexes for notification_history
CREATE INDEX IF NOT EXISTS idx_notification_history_user_id ON notification_history(user_id);
CREATE INDEX IF NOT EXISTS idx_notification_history_unread ON notification_history(unread);
CREATE INDEX IF NOT EXISTS idx_notification_history_type ON notification_history(type);

-- 10. Create notification_preferences table (23 columns)
CREATE TABLE IF NOT EXISTS notification_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    email_deposits BOOLEAN DEFAULT true,
    email_withdrawals BOOLEAN DEFAULT true,
    email_trades BOOLEAN DEFAULT true,
    email_marketing BOOLEAN DEFAULT false,
    email_security BOOLEAN DEFAULT true,
    push_deposits BOOLEAN DEFAULT true,
    push_withdrawals BOOLEAN DEFAULT true,
    push_trades BOOLEAN DEFAULT true,
    push_marketing BOOLEAN DEFAULT false,
    push_security BOOLEAN DEFAULT true,
    inapp_deposits BOOLEAN DEFAULT true,
    inapp_withdrawals BOOLEAN DEFAULT true,
    inapp_trades BOOLEAN DEFAULT true,
    inapp_marketing BOOLEAN DEFAULT false,
    inapp_security BOOLEAN DEFAULT true,
    quiet_hours_enabled BOOLEAN DEFAULT false,
    quiet_hours_start TIME WITHOUT TIME ZONE,
    quiet_hours_end TIME WITHOUT TIME ZONE,
    frequency_summary BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for notification_preferences
CREATE INDEX IF NOT EXISTS idx_notification_preferences_user_id ON notification_preferences(user_id);

-- 11. Create payout_methods table (17 columns)
CREATE TABLE IF NOT EXISTS payout_methods (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    method_type TEXT NOT NULL,
    method_name TEXT NOT NULL,
    currency TEXT NOT NULL,
    network TEXT,
    address TEXT,
    details JSONB,
    is_default BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    min_amount NUMERIC,
    max_amount NUMERIC,
    fee_percentage NUMERIC,
    fixed_fee NUMERIC,
    processing_time_hours INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for payout_methods
CREATE INDEX IF NOT EXISTS idx_payout_methods_user_id ON payout_methods(user_id);
CREATE INDEX IF NOT EXISTS idx_payout_methods_is_active ON payout_methods(is_active);
CREATE INDEX IF NOT EXISTS idx_payout_methods_currency ON payout_methods(currency);

-- 12. Create price_cache table (5 columns)
CREATE TABLE IF NOT EXISTS price_cache (
    symbol TEXT PRIMARY KEY,
    asset_type TEXT NOT NULL,
    price_usd NUMERIC NOT NULL,
    source TEXT NOT NULL,
    as_of TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for price_cache
CREATE INDEX IF NOT EXISTS idx_price_cache_asset_type ON price_cache(asset_type);
CREATE INDEX IF NOT EXISTS idx_price_cache_as_of ON price_cache(as_of);

-- 13. Create referrals table (6 columns)
CREATE TABLE IF NOT EXISTS referrals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    referrer_user_id UUID NOT NULL,
    referred_user_id UUID NOT NULL,
    reward_usd NUMERIC,
    reward_cap_usd NUMERIC,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for referrals
CREATE INDEX IF NOT EXISTS idx_referrals_referrer_user_id ON referrals(referrer_user_id);
CREATE INDEX IF NOT EXISTS idx_referrals_referred_user_id ON referrals(referred_user_id);

-- 14. Create tiers table (9 columns)
CREATE TABLE IF NOT EXISTS tiers (
    id INTEGER PRIMARY KEY,
    tier_name TEXT NOT NULL,
    min_amount_usd NUMERIC NOT NULL,
    max_amount_usd NUMERIC,
    maturity_days INTEGER NOT NULL,
    daily_roi_pct NUMERIC NOT NULL,
    allocation JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for tiers
CREATE INDEX IF NOT EXISTS idx_tiers_min_amount ON tiers(min_amount_usd);
CREATE INDEX IF NOT EXISTS idx_tiers_max_amount ON tiers(max_amount_usd);

-- All remaining tables creation complete!
-- The following tables have been created:
-- 1. admin_deposit_method_updates (13 columns) ✓
-- 2. backoffice_roles (4 columns) ✓
-- 3. bonuses (6 columns) ✓
-- 4. conversion_settings (8 columns) ✓
-- 5. conversions (11 columns) ✓
-- 6. email_verification_requests (10 columns) ✓
-- 7. fx_quotes (12 columns) ✓
-- 8. kyc_submissions (23 columns) ✓
-- 9. notification_history (12 columns) ✓
-- 10. notification_preferences (23 columns) ✓
-- 11. payout_methods (17 columns) ✓
-- 12. price_cache (5 columns) ✓
-- 13. referrals (6 columns) ✓
-- 14. tiers (9 columns) ✓

-- Total: 14 additional tables created
-- Combined with previous 8 critical tables = 22 total missing tables now created!

-- Verify admin_deposit_method_updates table was created
SELECT 'ADMIN_DEPOSIT_METHOD_UPDATES_CREATED' as status,
       COUNT(*) as column_count
FROM information_schema.columns 
WHERE table_name = 'admin_deposit_method_updates' 
AND table_schema = 'public';
