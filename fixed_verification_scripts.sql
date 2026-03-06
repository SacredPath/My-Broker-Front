-- Update verification scripts to use investment_strategies instead of investment_tiers
-- This ensures all database checks reference the correct table

-- Update ULTIMATE_DB_VERIFICATION.sql
SELECT 
    'Critical Tables' as category,
    COUNT(CASE WHEN table_name IN ('profiles', 'user_positions', 'investment_strategies', 'audit_log_entries') THEN 1 END) as deployed,
    '4' as expected,
    CASE 
        WHEN COUNT(CASE WHEN table_name IN ('profiles', 'user_positions', 'investment_strategies', 'audit_log_entries') THEN 1 END) = 4 THEN '✅ COMPLETE'
        WHEN COUNT(CASE WHEN table_name IN ('profiles', 'user_positions', 'investment_strategies', 'audit_log_entries') THEN 1 END) >= 3 THEN '⚠️ MOSTLY COMPLETE'
        ELSE '❌ INCOMPLETE'
    END as status
FROM information_schema.tables 
WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
    AND table_name IN ('profiles', 'user_positions', 'investment_strategies', 'audit_log_entries');

-- Update trigger checks
SELECT 
    'Critical Triggers' as category,
    COUNT(CASE WHEN trigger_name IN ('on_auth_user_created', 'handle_user_positions_updated_at', 'trigger_set_position_maturity', 'handle_investment_strategies_updated_at') THEN 1 END) as deployed,
    '4' as expected,
    CASE 
        WHEN COUNT(CASE WHEN trigger_name IN ('on_auth_user_created', 'handle_user_positions_updated_at', 'trigger_set_position_maturity', 'handle_investment_strategies_updated_at')) THEN 1 END = 4 THEN '✅ COMPLETE'
        WHEN COUNT(CASE WHEN trigger_name IN ('on_auth_user_created', 'handle_user_positions_updated_at', 'trigger_set_position_maturity', 'handle_investment_strategies_updated_at')) THEN 1 END >= 3 THEN '⚠️ MOSTLY COMPLETE'
        ELSE '❌ INCOMPLETE'
    END as status
FROM information_schema.triggers 
WHERE trigger_schema IN ('public', 'auth') 
    AND trigger_name IN ('on_auth_user_created', 'handle_user_positions_updated_at', 'trigger_set_position_maturity', 'handle_investment_strategies_updated_at');

-- Update final status check
SELECT 
    CASE 
        WHEN (
            -- Check if all critical tables exist
            (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE' AND table_name IN ('profiles', 'user_positions', 'investment_strategies', 'audit_log_entries')) = 4
            -- Check if all critical functions exist
            AND (SELECT COUNT(*) FROM information_schema.routines WHERE routine_schema = 'public' AND routine_type = 'FUNCTION' AND routine_name IN ('handle_new_user', 'handle_updated_at', 'calculate_position_maturity', 'set_position_maturity')) = 4
            -- Check if all critical triggers exist
            AND (SELECT COUNT(*) FROM information_schema.triggers WHERE trigger_schema IN ('public', 'auth') AND trigger_name IN ('on_auth_user_created', 'handle_user_positions_updated_at', 'trigger_set_position_maturity', 'handle_investment_strategies_updated_at')) = 4
        ) THEN '🎉 ALL CRITICAL DATABASE OBJECTS SUCCESSFULLY DEPLOYED AND VERIFIED!'
        ELSE '⚠️ Some critical objects may still be missing - review the sections above for details'
    END as final_status;
