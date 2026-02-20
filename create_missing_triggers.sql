-- Create Missing Database Triggers
-- These triggers attach the trigger functions to the appropriate tables

-- 1. Trigger for deposit_addresses table (if it exists)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'deposit_addresses' AND table_schema = 'public') THEN
        DROP TRIGGER IF EXISTS handle_deposit_addresses_updated_at_trigger ON deposit_addresses;
        CREATE TRIGGER handle_deposit_addresses_updated_at_trigger
            BEFORE UPDATE ON deposit_addresses
            FOR EACH ROW
            EXECUTE FUNCTION handle_deposit_addresses_updated_at();
    END IF;
END $$;

-- 2. Trigger for auth.users table (new auth user handling)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'users' AND table_schema = 'auth') THEN
        DROP TRIGGER IF EXISTS handle_new_auth_user_trigger ON auth.users;
        CREATE TRIGGER handle_new_auth_user_trigger
            AFTER INSERT ON auth.users
            FOR EACH ROW
            EXECUTE FUNCTION handle_new_auth_user();
    END IF;
END $$;

-- 3. Trigger for notifications table
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'notifications' AND table_schema = 'public') THEN
        DROP TRIGGER IF EXISTS handle_notifications_updated_at_trigger ON notifications;
        CREATE TRIGGER handle_notifications_updated_at_trigger
            BEFORE UPDATE ON notifications
            FOR EACH ROW
            EXECUTE FUNCTION handle_notifications_updated_at();
    END IF;
END $$;

-- 4. Trigger for withdrawal_methods table (additional trigger if needed)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'withdrawal_methods' AND table_schema = 'public') THEN
        -- This trigger already exists as withdrawal_methods_updated_at, but adding backup
        DROP TRIGGER IF EXISTS handle_withdrawal_methods_backup_trigger ON withdrawal_methods;
        CREATE TRIGGER handle_withdrawal_methods_backup_trigger
            BEFORE UPDATE ON withdrawal_methods
            FOR EACH ROW
            EXECUTE FUNCTION handle_withdrawal_methods_updated_at();
    END IF;
END $$;

-- 5. Trigger for user_balances table
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'user_balances' AND table_schema = 'public') THEN
        DROP TRIGGER IF EXISTS handle_user_balances_updated_at_trigger ON user_balances;
        CREATE TRIGGER handle_user_balances_updated_at_trigger
            BEFORE UPDATE ON user_balances
            FOR EACH ROW
            EXECUTE FUNCTION handle_updated_at();
    END IF;
END $$;

-- 6. Trigger for conversions table
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'conversions' AND table_schema = 'public') THEN
        DROP TRIGGER IF EXISTS handle_conversions_updated_at_trigger ON conversions;
        CREATE TRIGGER handle_conversions_updated_at_trigger
            BEFORE UPDATE ON conversions
            FOR EACH ROW
            EXECUTE FUNCTION handle_updated_at();
    END IF;
END $$;

-- 7. Trigger for bonuses table
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'bonuses' AND table_schema = 'public') THEN
        DROP TRIGGER IF EXISTS handle_bonuses_updated_at_trigger ON bonuses;
        CREATE TRIGGER handle_bonuses_updated_at_trigger
            BEFORE UPDATE ON bonuses
            FOR EACH ROW
            EXECUTE FUNCTION handle_updated_at();
    END IF;
END $$;

-- 8. Trigger for referrals table
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'referrals' AND table_schema = 'public') THEN
        DROP TRIGGER IF EXISTS handle_referrals_updated_at_trigger ON referrals;
        CREATE TRIGGER handle_referrals_updated_at_trigger
            BEFORE UPDATE ON referrals
            FOR EACH ROW
            EXECUTE FUNCTION handle_updated_at();
    END IF;
END $$;

-- 9. Trigger for tiers table
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'tiers' AND table_schema = 'public') THEN
        DROP TRIGGER IF EXISTS handle_tiers_updated_at_trigger ON tiers;
        CREATE TRIGGER handle_tiers_updated_at_trigger
            BEFORE UPDATE ON tiers
            FOR EACH ROW
            EXECUTE FUNCTION handle_updated_at();
    END IF;
END $$;

-- 10. Trigger for unified_history table
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'unified_history' AND table_schema = 'public') THEN
        DROP TRIGGER IF EXISTS handle_unified_history_updated_at_trigger ON unified_history;
        CREATE TRIGGER handle_unified_history_updated_at_trigger
            BEFORE UPDATE ON unified_history
            FOR EACH ROW
            EXECUTE FUNCTION handle_updated_at();
    END IF;
END $$;

-- 11. Trigger for price_cache table
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'price_cache' AND table_schema = 'public') THEN
        DROP TRIGGER IF EXISTS handle_price_cache_updated_at_trigger ON price_cache;
        CREATE TRIGGER handle_price_cache_updated_at_trigger
            BEFORE UPDATE ON price_cache
            FOR EACH ROW
            EXECUTE FUNCTION handle_updated_at();
    END IF;
END $$;

-- 12. Trigger for fx_quotes table
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'fx_quotes' AND table_schema = 'public') THEN
        DROP TRIGGER IF EXISTS handle_fx_quotes_updated_at_trigger ON fx_quotes;
        CREATE TRIGGER handle_fx_quotes_updated_at_trigger
            BEFORE UPDATE ON fx_quotes
            FOR EACH ROW
            EXECUTE FUNCTION handle_updated_at();
    END IF;
END $$;

-- 13. Trigger for kyc_applications table
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'kyc_applications' AND table_schema = 'public') THEN
        DROP TRIGGER IF EXISTS handle_kyc_applications_updated_at_trigger ON kyc_applications;
        CREATE TRIGGER handle_kyc_applications_updated_at_trigger
            BEFORE UPDATE ON kyc_applications
            FOR EACH ROW
            EXECUTE FUNCTION handle_updated_at();
    END IF;
END $$;

-- 14. Trigger for admin_deposit_method_updates table
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'admin_deposit_method_updates' AND table_schema = 'public') THEN
        DROP TRIGGER IF EXISTS handle_admin_deposit_method_updates_updated_at_trigger ON admin_deposit_method_updates;
        CREATE TRIGGER handle_admin_deposit_method_updates_updated_at_trigger
            BEFORE UPDATE ON admin_deposit_method_updates
            FOR EACH ROW
            EXECUTE FUNCTION handle_updated_at();
    END IF;
END $$;

-- 15. Trigger for conversion_settings table
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'conversion_settings' AND table_schema = 'public') THEN
        DROP TRIGGER IF EXISTS handle_conversion_settings_updated_at_trigger ON conversion_settings;
        CREATE TRIGGER handle_conversion_settings_updated_at_trigger
            BEFORE UPDATE ON conversion_settings
            FOR EACH ROW
            EXECUTE FUNCTION handle_updated_at();
    END IF;
END $$;

-- 16. Trigger for email_verification_requests table (additional trigger)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'email_verification_requests' AND table_schema = 'public') THEN
        -- This trigger already exists but adding INSERT trigger
        DROP TRIGGER IF EXISTS handle_email_verification_requests_insert_trigger ON email_verification_requests;
        CREATE TRIGGER handle_email_verification_requests_insert_trigger
            BEFORE INSERT ON email_verification_requests
            FOR EACH ROW
            EXECUTE FUNCTION handle_email_verification_requests_updated_at();
    END IF;
END $$;

-- 17. Trigger for notification_history table
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'notification_history' AND table_schema = 'public') THEN
        DROP TRIGGER IF EXISTS handle_notification_history_updated_at_trigger ON notification_history;
        CREATE TRIGGER handle_notification_history_updated_at_trigger
            BEFORE UPDATE ON notification_history
            FOR EACH ROW
            EXECUTE FUNCTION handle_updated_at();
    END IF;
END $$;

-- 18. Trigger for payout_methods table (INSERT trigger)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'payout_methods' AND table_schema = 'public') THEN
        -- Add INSERT trigger for payout_methods
        DROP TRIGGER IF EXISTS handle_payout_methods_insert_trigger ON payout_methods;
        CREATE TRIGGER handle_payout_methods_insert_trigger
            BEFORE INSERT ON payout_methods
            FOR EACH ROW
            EXECUTE FUNCTION handle_payout_methods_updated_at();
    END IF;
END $$;

-- 19. Trigger for signal_access table
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'signal_access' AND table_schema = 'public') THEN
        DROP TRIGGER IF EXISTS handle_signal_access_updated_at_trigger ON signal_access;
        CREATE TRIGGER handle_signal_access_updated_at_trigger
            BEFORE UPDATE ON signal_access
            FOR EACH ROW
            EXECUTE FUNCTION handle_updated_at();
    END IF;
END $$;

-- 20. Trigger for user_withdrawal_methods table
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'user_withdrawal_methods' AND table_schema = 'public') THEN
        DROP TRIGGER IF EXISTS handle_user_withdrawal_methods_updated_at_trigger ON user_withdrawal_methods;
        CREATE TRIGGER handle_user_withdrawal_methods_updated_at_trigger
            BEFORE UPDATE ON user_withdrawal_methods
            FOR EACH ROW
            EXECUTE FUNCTION handle_updated_at();
    END IF;
END $$;

-- 21. Trigger for wallet_ledger table
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'wallet_ledger' AND table_schema = 'public') THEN
        DROP TRIGGER IF EXISTS handle_wallet_ledger_updated_at_trigger ON wallet_ledger;
        CREATE TRIGGER handle_wallet_ledger_updated_at_trigger
            BEFORE UPDATE ON wallet_ledger
            FOR EACH ROW
            EXECUTE FUNCTION handle_updated_at();
    END IF;
END $$;

-- 22. Trigger for daily_autogrowth_log table
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'daily_autogrowth_log' AND table_schema = 'public') THEN
        DROP TRIGGER IF EXISTS handle_daily_autogrowth_log_updated_at_trigger ON daily_autogrowth_log;
        CREATE TRIGGER handle_daily_autogrowth_log_updated_at_trigger
            BEFORE UPDATE ON daily_autogrowth_log
            FOR EACH ROW
            EXECUTE FUNCTION handle_updated_at();
    END IF;
END $$;

-- Verify triggers were created
SELECT 'TRIGGERS_CREATED' as status,
       COUNT(*) as trigger_count
FROM information_schema.triggers 
WHERE trigger_schema = 'public';
