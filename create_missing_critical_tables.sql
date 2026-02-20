-- Create Missing Critical Tables
-- Starting with transactions (column structure already known)

-- 1. Create transactions table (15 columns - structure provided earlier)
CREATE TABLE IF NOT EXISTS transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    type TEXT NOT NULL,
    amount NUMERIC NOT NULL,
    currency TEXT NOT NULL,
    status TEXT NOT NULL,
    description TEXT,
    transaction_hash TEXT,
    from_address TEXT,
    to_address TEXT,
    network TEXT,
    fee NUMERIC,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE
);

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_transactions_user_id ON transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_transactions_status ON transactions(status);
CREATE INDEX IF NOT EXISTS idx_transactions_type ON transactions(type);
CREATE INDEX IF NOT EXISTS idx_transactions_created_at ON transactions(created_at);

-- 2. Create withdrawal_methods table (22 columns)
CREATE TABLE IF NOT EXISTS withdrawal_methods (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    method_name TEXT NOT NULL,
    method_type TEXT NOT NULL,
    currency TEXT NOT NULL,
    network TEXT,
    address TEXT,
    bank_name TEXT,
    account_number TEXT,
    routing_number TEXT,
    swift_code TEXT,
    account_holder_name TEXT,
    paypal_email TEXT,
    paypal_business_name TEXT,
    is_default BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    min_amount NUMERIC,
    max_amount NUMERIC,
    processing_fee_percent NUMERIC,
    processing_time_hours INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for withdrawal_methods
CREATE INDEX IF NOT EXISTS idx_withdrawal_methods_user_id ON withdrawal_methods(user_id);
CREATE INDEX IF NOT EXISTS idx_withdrawal_methods_is_active ON withdrawal_methods(is_active);
CREATE INDEX IF NOT EXISTS idx_withdrawal_methods_currency ON withdrawal_methods(currency);

-- 3. Create notification_settings table (14 columns)
CREATE TABLE IF NOT EXISTS notification_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    email_deposits BOOLEAN DEFAULT true,
    email_withdrawals BOOLEAN DEFAULT true,
    email_trades BOOLEAN DEFAULT true,
    email_kyc BOOLEAN DEFAULT true,
    email_system BOOLEAN DEFAULT true,
    push_deposits BOOLEAN DEFAULT true,
    push_withdrawals BOOLEAN DEFAULT true,
    push_trades BOOLEAN DEFAULT true,
    push_kyc BOOLEAN DEFAULT true,
    push_system BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for notification_settings
CREATE INDEX IF NOT EXISTS idx_notification_settings_user_id ON notification_settings(user_id);

-- 4. Create user_withdrawal_methods table (15 columns)
CREATE TABLE IF NOT EXISTS user_withdrawal_methods (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    currency TEXT NOT NULL,
    method_id UUID,
    method_type TEXT NOT NULL,
    method_name TEXT NOT NULL,
    network TEXT,
    address TEXT,
    account_number TEXT,
    routing_number TEXT,
    paypal_email TEXT,
    bank_name TEXT,
    is_default BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for user_withdrawal_methods
CREATE INDEX IF NOT EXISTS idx_user_withdrawal_methods_user_id ON user_withdrawal_methods(user_id);
CREATE INDEX IF NOT EXISTS idx_user_withdrawal_methods_currency ON user_withdrawal_methods(currency);

-- 5. Create wallet_ledger table (9 columns)
-- Note: Using TEXT instead of custom types that don't exist yet
CREATE TABLE IF NOT EXISTS wallet_ledger (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    user_id UUID NOT NULL,
    currency TEXT NOT NULL,
    amount NUMERIC NOT NULL,
    reason TEXT NOT NULL,
    ref_table TEXT,
    ref_id TEXT,
    meta JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for wallet_ledger
CREATE INDEX IF NOT EXISTS idx_wallet_ledger_user_id ON wallet_ledger(user_id);
CREATE INDEX IF NOT EXISTS idx_wallet_ledger_currency ON wallet_ledger(currency);
CREATE INDEX IF NOT EXISTS idx_wallet_ledger_created_at ON wallet_ledger(created_at);

-- 6. Create signal_access table (6 columns)
CREATE TABLE IF NOT EXISTS signal_access (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    signal_id UUID NOT NULL,
    starts_at TIMESTAMP WITH TIME ZONE NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for signal_access
CREATE INDEX IF NOT EXISTS idx_signal_access_user_id ON signal_access(user_id);
CREATE INDEX IF NOT EXISTS idx_signal_access_signal_id ON signal_access(signal_id);
CREATE INDEX IF NOT EXISTS idx_signal_access_expires_at ON signal_access(expires_at);

-- 7. Create signal_purchases table (13 columns)
CREATE TABLE IF NOT EXISTS signal_purchases (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    signal_id UUID NOT NULL,
    signal_string_id TEXT NOT NULL,
    purchase_price NUMERIC NOT NULL,
    purchase_type TEXT NOT NULL,
    access_duration TEXT NOT NULL,
    access_starts_at TIMESTAMP WITH TIME ZONE NOT NULL,
    access_expires_at TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT true,
    auto_renew BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for signal_purchases
CREATE INDEX IF NOT EXISTS idx_signal_purchases_user_id ON signal_purchases(user_id);
CREATE INDEX IF NOT EXISTS idx_signal_purchases_signal_id ON signal_purchases(signal_id);
CREATE INDEX IF NOT EXISTS idx_signal_purchases_is_active ON signal_purchases(is_active);
CREATE INDEX IF NOT EXISTS idx_signal_purchases_expires_at ON signal_purchases(access_expires_at);

-- 8. Create unified_history table (10 columns)
CREATE TABLE IF NOT EXISTS unified_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    event_type TEXT NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    status TEXT NOT NULL,
    amount NUMERIC,
    currency TEXT,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for unified_history
CREATE INDEX IF NOT EXISTS idx_unified_history_user_id ON unified_history(user_id);
CREATE INDEX IF NOT EXISTS idx_unified_history_event_type ON unified_history(event_type);
CREATE INDEX IF NOT EXISTS idx_unified_history_status ON unified_history(status);
CREATE INDEX IF NOT EXISTS idx_unified_history_created_at ON unified_history(created_at);

-- Critical tables creation complete!
-- The following critical tables have been created:
-- 1. transactions (15 columns) ✓
-- 2. withdrawal_methods (22 columns) ✓
-- 3. notification_settings (14 columns) ✓
-- 4. user_withdrawal_methods (15 columns) ✓
-- 5. wallet_ledger (9 columns) ✓
-- 6. signal_access (6 columns) ✓
-- 7. signal_purchases (13 columns) ✓
-- 8. unified_history (10 columns) ✓

-- 9. Create remaining missing tables (less critical - can be created later)
-- - admin_deposit_method_updates (13 columns)
-- - backoffice_roles (4 columns)
-- - bonuses (6 columns)
-- - conversion_settings (8 columns)
-- - conversions (11 columns)
-- - email_verification_requests (10 columns)
-- - fx_quotes (12 columns)
-- - kyc_submissions (23 columns)
-- - notification_history (12 columns)
-- - notification_preferences (23 columns)
-- - payout_methods (17 columns)
-- - price_cache (5 columns)
-- - referrals (6 columns)
-- - tiers (9 columns)

-- Verify transactions table was created
SELECT 'TRANSACTIONS_TABLE_CREATED' as status,
       COUNT(*) as column_count
FROM information_schema.columns 
WHERE table_name = 'transactions' 
AND table_schema = 'public';
