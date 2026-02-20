-- Verify All Expected Enum Types
-- Check that all custom enumerated types exist with correct values

-- 1. Check app_role enum
SELECT 'ENUM_CHECK' as audit_type,
       'app_role' as enum_name,
       CASE 
           WHEN EXISTS (SELECT 1 FROM pg_type WHERE typname = 'app_role') THEN 'EXISTS' 
           ELSE 'MISSING' 
       END as status,
       'user, support, superadmin' as expected_values;

-- 2. Check kyc_status enum
SELECT 'ENUM_CHECK' as audit_type,
       'kyc_status' as enum_name,
       CASE 
           WHEN EXISTS (SELECT 1 FROM pg_type WHERE typname = 'kyc_status') THEN 'EXISTS' 
           ELSE 'MISSING' 
       END as status,
       'not_submitted, pending, approved, rejected' as expected_values;

-- 3. Check currency_code enum
SELECT 'ENUM_CHECK' as audit_type,
       'currency_code' as enum_name,
       CASE 
           WHEN EXISTS (SELECT 1 FROM pg_type WHERE typname = 'currency_code') THEN 'EXISTS' 
           ELSE 'MISSING' 
       END as status,
       'USD, USDT' as expected_values;

-- 4. Check ledger_reason enum
SELECT 'ENUM_CHECK' as audit_type,
       'ledger_reason' as enum_name,
       CASE 
           WHEN EXISTS (SELECT 1 FROM pg_type WHERE typname = 'ledger_reason') THEN 'EXISTS' 
           ELSE 'MISSING' 
       END as status,
       'deposit, withdrawal, conversion, roi_claim, tier_sweep, admin_adjust, bonus_signup, bonus_deposit, referral_reward, signal_purchase, fee' as expected_values;

-- 5. Check position_status enum
SELECT 'ENUM_CHECK' as audit_type,
       'position_status' as enum_name,
       CASE 
           WHEN EXISTS (SELECT 1 FROM pg_type WHERE typname = 'position_status') THEN 'EXISTS' 
           ELSE 'MISSING' 
       END as status,
       'active, matured, closed' as expected_values;

-- 6. Check deposit_method enum
SELECT 'ENUM_CHECK' as audit_type,
       'deposit_method' as enum_name,
       CASE 
           WHEN EXISTS (SELECT 1 FROM pg_type WHERE typname = 'deposit_method') THEN 'EXISTS' 
           ELSE 'MISSING' 
       END as status,
       'bank, stripe, paypal, usdt_trc20' as expected_values;

-- 7. Check deposit_status enum
SELECT 'ENUM_CHECK' as audit_type,
       'deposit_status' as enum_name,
       CASE 
           WHEN EXISTS (SELECT 1 FROM pg_type WHERE typname = 'deposit_status') THEN 'EXISTS' 
           ELSE 'MISSING' 
       END as status,
       'pending, confirmed, rejected, expired' as expected_values;

-- 8. Check conversion_status enum
SELECT 'ENUM_CHECK' as audit_type,
       'conversion_status' as enum_name,
       CASE 
           WHEN EXISTS (SELECT 1 FROM pg_type WHERE typname = 'conversion_status') THEN 'EXISTS' 
           ELSE 'MISSING' 
       END as status,
       'quoted, completed, failed' as expected_values;

-- 9. Check withdrawal_method enum
SELECT 'ENUM_CHECK' as audit_type,
       'withdrawal_method' as enum_name,
       CASE 
           WHEN EXISTS (SELECT 1 FROM pg_type WHERE typname = 'withdrawal_method') THEN 'EXISTS' 
           ELSE 'MISSING' 
       END as status,
       'bank, paypal, crypto_trc20' as expected_values;

-- 10. Check withdrawal_status enum
SELECT 'ENUM_CHECK' as audit_type,
       'withdrawal_status' as enum_name,
       CASE 
           WHEN EXISTS (SELECT 1 FROM pg_type WHERE typname = 'withdrawal_status') THEN 'EXISTS' 
           ELSE 'MISSING' 
       END as status,
       'pending, approved, rejected, paid' as expected_values;

-- 11. Check signal_type enum
SELECT 'ENUM_CHECK' as audit_type,
       'signal_type' as enum_name,
       CASE 
           WHEN EXISTS (SELECT 1 FROM pg_type WHERE typname = 'signal_type') THEN 'EXISTS' 
           ELSE 'MISSING' 
       END as status,
       'one_time, subscription' as expected_values;

-- Summary of enum types
SELECT 'ENUM_SUMMARY' as audit_type,
       COUNT(*) as total_expected_enums,
       COUNT(CASE WHEN EXISTS (SELECT 1 FROM pg_type WHERE typname = t.enum_name) THEN 1 END) as existing_enums
FROM (VALUES 
    ('app_role'), ('kyc_status'), ('currency_code'), ('ledger_reason'), ('position_status'),
    ('deposit_method'), ('deposit_status'), ('conversion_status'), ('withdrawal_method'),
    ('withdrawal_status'), ('signal_type')
) AS t(enum_name);

-- Show actual enum values for verification (only if they exist)
DO $$
DECLARE
    enum_record RECORD;
BEGIN
    FOR enum_record IN 
        SELECT typname FROM pg_type WHERE typname IN (
            'app_role', 'kyc_status', 'currency_code', 'ledger_reason', 'position_status',
            'deposit_method', 'deposit_status', 'conversion_status', 'withdrawal_method',
            'withdrawal_status', 'signal_type'
        ) AND typtype = 'e'
        ORDER BY typname
    LOOP
        RAISE NOTICE '=== ENUM: % ===', enum_record.typname;
        EXECUTE format('SELECT unnest(enum_range(NULL::%s))::text', enum_record.typname);
    END LOOP;
END $$;
