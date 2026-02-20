-- Check Database Functions - Verify all expected functions exist
-- This script will identify which functions are missing from your database

-- 1. Check if all expected functions exist
SELECT 'FUNCTION_EXISTENCE_CHECK' as audit_type,
    function_name,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.routines 
            WHERE routine_name = function_name 
            AND routine_schema = 'public'
            AND routine_type = 'FUNCTION'
        ) THEN 'EXISTS' 
        ELSE 'MISSING' 
    END as status
FROM (VALUES 
    ('admin_update_user_balance'),
    ('admin_update_wallet_balance'),
    ('apply_daily_roi'),
    ('approve_deposit_request'),
    ('archive_old_notifications'),
    ('autogrowth_system'),
    ('calculate_daily_autogrowth'),
    ('calculate_position_maturity'),
    ('calculate_position_roi'),
    ('cleanup_expired_notifications'),
    ('create_business_notification'),
    ('create_deposit_request'),
    ('delete_user_withdrawal_method'),
    ('ensure_single_default_method'),
    ('get_active_deposit_methods'),
    ('get_autogrowth_system_stats'),
    ('get_email_verification_status'),
    ('get_or_create_fx_quote'),
    ('get_user_email_verification_status'),
    ('get_user_kyc_status'),
    ('get_user_notifications'),
    ('get_user_payout_methods'),
    ('get_user_profile'),
    ('get_user_withdrawal_methods'),
    ('get_user_withdrawal_methods_only'),
    ('is_admin'),
    ('is_current_user_admin'),
    ('manual_archive_notifications'),
    ('mark_all_notifications_read'),
    ('mark_notification_read'),
    ('process_admin_balance_updates'),
    ('process_admin_deposit_method_updates'),
    ('reject_deposit_request'),
    ('request_email_verification'),
    ('rest_autogrowth_status'),
    ('rest_autogrowth_trigger'),
    ('rest_claim_roi'),
    ('save_user_withdrawal_method'),
    ('send_notification'),
    ('set_default_withdrawal_method'),
    ('tier_upgrade_rest'),
    ('tier_upgrade_rpc'),
    ('trigger_daily_autogrowth'),
    ('update_fx_rate'),
    ('update_notification_settings_updated_at'),
    ('update_support_tickets_updated_at'),
    ('update_updated_at_column')
) AS t(function_name)
ORDER BY function_name;

-- 2. Check trigger functions separately
SELECT 'TRIGGER_FUNCTION_EXISTENCE_CHECK' as audit_type,
    function_name,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.routines 
            WHERE routine_name = function_name 
            AND routine_schema = 'public'
            AND routine_type = 'FUNCTION'
        ) THEN 'EXISTS' 
        ELSE 'MISSING' 
    END as status
FROM (VALUES 
    ('handle_deposit_addresses_updated_at'),
    ('handle_deposit_methods_updated_at'),
    ('handle_deposit_requests_updated_at'),
    ('handle_email_verification_requests_updated_at'),
    ('handle_investment_tiers_updated_at'),
    ('handle_kyc_documents_updated_at'),
    ('handle_kyc_submissions_updated_at'),
    ('handle_new_auth_user'),
    ('handle_new_user'),
    ('handle_notification_preferences_updated_at'),
    ('handle_notifications_updated_at'),
    ('handle_payout_methods_updated_at'),
    ('handle_profiles_updated_at'),
    ('handle_signal_purchases_updated_at'),
    ('handle_transactions_updated_at'),
    ('handle_updated_at'),
    ('handle_user_positions_updated_at'),
    ('handle_wallet_balances_updated_at'),
    ('handle_withdrawal_methods_updated_at'),
    ('handle_withdrawal_requests_updated_at'),
    ('set_position_maturity'),
    ('set_resolved_at'),
    ('set_updated_at'),
    ('update_updated_at_column')
) AS t(function_name)
ORDER BY function_name;

-- 3. Summary counts
SELECT 'FUNCTION_SUMMARY' as audit_type,
    COUNT(*) as total_expected_functions,
    COUNT(CASE WHEN EXISTS (
        SELECT 1 FROM information_schema.routines 
        WHERE routine_name = t.function_name 
        AND routine_schema = 'public'
        AND routine_type = 'FUNCTION'
    ) THEN 1 END) as existing_functions
FROM (VALUES 
    ('admin_update_user_balance'), ('admin_update_wallet_balance'), ('apply_daily_roi'), ('approve_deposit_request'), ('archive_old_notifications'), ('autogrowth_system'), ('calculate_daily_autogrowth'), ('calculate_position_maturity'), ('calculate_position_roi'), ('cleanup_expired_notifications'), ('create_business_notification'), ('create_deposit_request'), ('delete_user_withdrawal_method'), ('ensure_single_default_method'), ('get_active_deposit_methods'), ('get_autogrowth_system_stats'), ('get_email_verification_status'), ('get_or_create_fx_quote'), ('get_user_email_verification_status'), ('get_user_kyc_status'), ('get_user_notifications'), ('get_user_payout_methods'), ('get_user_profile'), ('get_user_withdrawal_methods'), ('get_user_withdrawal_methods_only'), ('is_admin'), ('is_current_user_admin'), ('manual_archive_notifications'), ('mark_all_notifications_read'), ('mark_notification_read'), ('process_admin_balance_updates'), ('process_admin_deposit_method_updates'), ('reject_deposit_request'), ('request_email_verification'), ('rest_autogrowth_status'), ('rest_autogrowth_trigger'), ('rest_claim_roi'), ('save_user_withdrawal_method'), ('send_notification'), ('set_default_withdrawal_method'), ('tier_upgrade_rest'), ('tier_upgrade_rpc'), ('trigger_daily_autogrowth'), ('update_fx_rate'), ('update_notification_settings_updated_at'), ('update_support_tickets_updated_at'), ('update_updated_at_column')
) AS t(function_name);

SELECT 'TRIGGER_FUNCTION_SUMMARY' as audit_type,
    COUNT(*) as total_expected_trigger_functions,
    COUNT(CASE WHEN EXISTS (
        SELECT 1 FROM information_schema.routines 
        WHERE routine_name = t.function_name 
        AND routine_schema = 'public'
        AND routine_type = 'FUNCTION'
    ) THEN 1 END) as existing_trigger_functions
FROM (VALUES 
    ('handle_deposit_addresses_updated_at'), ('handle_deposit_methods_updated_at'), ('handle_deposit_requests_updated_at'), ('handle_email_verification_requests_updated_at'), ('handle_investment_tiers_updated_at'), ('handle_kyc_documents_updated_at'), ('handle_kyc_submissions_updated_at'), ('handle_new_auth_user'), ('handle_new_user'), ('handle_notification_preferences_updated_at'), ('handle_notifications_updated_at'), ('handle_payout_methods_updated_at'), ('handle_profiles_updated_at'), ('handle_signal_purchases_updated_at'), ('handle_transactions_updated_at'), ('handle_updated_at'), ('handle_user_positions_updated_at'), ('handle_wallet_balances_updated_at'), ('handle_withdrawal_methods_updated_at'), ('handle_withdrawal_requests_updated_at'), ('set_position_maturity'), ('set_resolved_at'), ('set_updated_at'), ('update_updated_at_column')
) AS t(function_name);
