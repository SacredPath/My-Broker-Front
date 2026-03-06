-- Create All Missing Enum Types
-- Custom enumerated types for data consistency

-- 1. app_role enum
CREATE TYPE app_role AS ENUM ('user', 'support', 'superadmin');

-- 2. kyc_status enum
CREATE TYPE kyc_status AS ENUM ('not_submitted', 'pending', 'approved', 'rejected');

-- 3. currency_code enum
CREATE TYPE currency_code AS ENUM ('USD', 'USDT');

-- 4. ledger_reason enum
CREATE TYPE ledger_reason AS ENUM (
    'deposit', 
    'withdrawal', 
    'conversion', 
    'roi_claim', 
    'tier_sweep', 
    'admin_adjust', 
    'bonus_signup', 
    'bonus_deposit', 
    'referral_reward', 
    'signal_purchase', 
    'fee'
);

-- 5. position_status enum
CREATE TYPE position_status AS ENUM ('active', 'matured', 'closed');

-- 6. deposit_method enum
CREATE TYPE deposit_method AS ENUM ('bank', 'stripe', 'paypal', 'usdt_trc20');

-- 7. deposit_status enum
CREATE TYPE deposit_status AS ENUM ('pending', 'confirmed', 'rejected', 'expired');

-- 8. conversion_status enum
CREATE TYPE conversion_status AS ENUM ('quoted', 'completed', 'failed');

-- 9. withdrawal_method enum
CREATE TYPE withdrawal_method AS ENUM ('bank', 'paypal', 'crypto_trc20');

-- 10. withdrawal_status enum
CREATE TYPE withdrawal_status AS ENUM ('pending', 'approved', 'rejected', 'paid');

-- 11. signal_type enum
CREATE TYPE signal_type AS ENUM ('one_time', 'subscription');

-- Verify all enum types were created
SELECT 'ENUM_TYPES_CREATED' as status,
       COUNT(*) as created_count
FROM pg_type 
WHERE typname IN (
    'app_role', 'kyc_status', 'currency_code', 'ledger_reason', 'position_status',
    'deposit_method', 'deposit_status', 'conversion_status', 'withdrawal_method',
    'withdrawal_status', 'signal_type'
)
AND typtype = 'e';

-- Show created enum values for verification
DO $$
DECLARE
    enum_record RECORD;
    value_record RECORD;
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
        FOR value_record IN 
            EXECUTE format('SELECT unnest(enum_range(NULL::%s)) as value', enum_record.typname)
        LOOP
            RAISE NOTICE '  %', value_record.value;
        END LOOP;
    END LOOP;
END $$;
