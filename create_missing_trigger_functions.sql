-- Create All Missing Trigger Functions
-- These functions handle automatic updates when table records are modified

-- 1. handle_deposit_addresses_updated_at - Updates updated_at timestamp for deposit_addresses
CREATE OR REPLACE FUNCTION handle_deposit_addresses_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. handle_deposit_methods_updated_at - Updates updated_at timestamp for deposit_methods
CREATE OR REPLACE FUNCTION handle_deposit_methods_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 3. handle_deposit_requests_updated_at - Updates updated_at timestamp for deposit_requests
CREATE OR REPLACE FUNCTION handle_deposit_requests_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 4. handle_email_verification_requests_updated_at - Updates updated_at timestamp for email_verification_requests
CREATE OR REPLACE FUNCTION handle_email_verification_requests_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 5. handle_investment_tiers_updated_at - Updates updated_at timestamp for investment_tiers
CREATE OR REPLACE FUNCTION handle_investment_tiers_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 6. handle_kyc_documents_updated_at - Updates updated_at timestamp for kyc_documents
CREATE OR REPLACE FUNCTION handle_kyc_documents_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 7. handle_kyc_submissions_updated_at - Updates updated_at timestamp for kyc_submissions
CREATE OR REPLACE FUNCTION handle_kyc_submissions_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 8. handle_new_auth_user - Creates profile when new auth user is created
CREATE OR REPLACE FUNCTION handle_new_auth_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO profiles (user_id, email, display_name, email_verified, created_at, updated_at)
    VALUES (NEW.id, NEW.email, NEW.email, NEW.email_confirmed, NOW(), NOW());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 9. handle_new_user - Handles new user creation logic
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    -- Additional new user logic can be added here
    NEW.created_at = NOW();
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 10. handle_notification_preferences_updated_at - Updates updated_at timestamp for notification_preferences
CREATE OR REPLACE FUNCTION handle_notification_preferences_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 11. handle_notifications_updated_at - Updates updated_at timestamp for notifications
CREATE OR REPLACE FUNCTION handle_notifications_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 12. handle_payout_methods_updated_at - Updates updated_at timestamp for payout_methods
CREATE OR REPLACE FUNCTION handle_payout_methods_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 13. handle_profiles_updated_at - Updates updated_at timestamp for profiles
CREATE OR REPLACE FUNCTION handle_profiles_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 14. handle_signal_purchases_updated_at - Updates updated_at timestamp for signal_purchases
CREATE OR REPLACE FUNCTION handle_signal_purchases_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 15. handle_transactions_updated_at - Updates updated_at timestamp for transactions
CREATE OR REPLACE FUNCTION handle_transactions_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 16. handle_updated_at - Generic updated_at trigger function
CREATE OR REPLACE FUNCTION handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 17. handle_user_positions_updated_at - Updates updated_at timestamp for user_positions
CREATE OR REPLACE FUNCTION handle_user_positions_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 18. handle_wallet_balances_updated_at - Updates updated_at timestamp for wallet_balances
CREATE OR REPLACE FUNCTION handle_wallet_balances_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 19. handle_withdrawal_methods_updated_at - Updates updated_at timestamp for withdrawal_methods
CREATE OR REPLACE FUNCTION handle_withdrawal_methods_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 20. handle_withdrawal_requests_updated_at - Updates updated_at timestamp for withdrawal_requests
CREATE OR REPLACE FUNCTION handle_withdrawal_requests_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 21. set_position_maturity - Sets position maturity date
CREATE OR REPLACE FUNCTION set_position_maturity()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.maturity_date IS NULL AND NEW.tier_id IS NOT NULL THEN
        -- Calculate maturity date based on tier
        NEW.maturity_date = NOW() + (SELECT maturity_days || ' days' FROM investment_tiers WHERE id = NEW.tier_id)::INTERVAL;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 22. set_resolved_at - Sets resolved_at timestamp when status changes to resolved
CREATE OR REPLACE FUNCTION set_resolved_at()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status != 'resolved' AND NEW.status = 'resolved' THEN
        NEW.resolved_at = NOW();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 23. set_updated_at - Generic updated_at setter
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 24. update_updated_at_column - Another generic updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Verify all trigger functions were created
SELECT 'TRIGGER_FUNCTIONS_CREATED' as status,
       COUNT(*) as created_count
FROM information_schema.routines 
WHERE routine_name IN (
    'handle_deposit_addresses_updated_at', 'handle_deposit_methods_updated_at', 'handle_deposit_requests_updated_at',
    'handle_email_verification_requests_updated_at', 'handle_investment_tiers_updated_at', 'handle_kyc_documents_updated_at',
    'handle_kyc_submissions_updated_at', 'handle_new_auth_user', 'handle_new_user', 'handle_notification_preferences_updated_at',
    'handle_notifications_updated_at', 'handle_payout_methods_updated_at', 'handle_profiles_updated_at', 'handle_signal_purchases_updated_at',
    'handle_transactions_updated_at', 'handle_updated_at', 'handle_user_positions_updated_at', 'handle_wallet_balances_updated_at',
    'handle_withdrawal_methods_updated_at', 'handle_withdrawal_requests_updated_at', 'set_position_maturity', 'set_resolved_at',
    'set_updated_at', 'update_updated_at_column'
)
AND routine_schema = 'public'
AND routine_type = 'FUNCTION';
