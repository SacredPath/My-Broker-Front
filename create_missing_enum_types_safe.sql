-- Create Missing Enum Types Safely
-- Only create enum types that don't already exist

-- 1. app_role enum
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'app_role') THEN
        CREATE TYPE app_role AS ENUM ('user', 'support', 'superadmin');
        RAISE NOTICE 'Created app_role enum';
    ELSE
        RAISE NOTICE 'app_role enum already exists';
    END IF;
END $$;

-- 2. kyc_status enum
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'kyc_status') THEN
        CREATE TYPE kyc_status AS ENUM ('not_submitted', 'pending', 'approved', 'rejected');
        RAISE NOTICE 'Created kyc_status enum';
    ELSE
        RAISE NOTICE 'kyc_status enum already exists';
    END IF;
END $$;

-- 3. currency_code enum
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'currency_code') THEN
        CREATE TYPE currency_code AS ENUM ('USD', 'USDT');
        RAISE NOTICE 'Created currency_code enum';
    ELSE
        RAISE NOTICE 'currency_code enum already exists';
    END IF;
END $$;

-- 4. ledger_reason enum
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'ledger_reason') THEN
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
        RAISE NOTICE 'Created ledger_reason enum';
    ELSE
        RAISE NOTICE 'ledger_reason enum already exists';
    END IF;
END $$;

-- 5. position_status enum
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'position_status') THEN
        CREATE TYPE position_status AS ENUM ('active', 'matured', 'closed');
        RAISE NOTICE 'Created position_status enum';
    ELSE
        RAISE NOTICE 'position_status enum already exists';
    END IF;
END $$;

-- 6. deposit_method enum
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'deposit_method') THEN
        CREATE TYPE deposit_method AS ENUM ('bank', 'stripe', 'paypal', 'usdt_trc20');
        RAISE NOTICE 'Created deposit_method enum';
    ELSE
        RAISE NOTICE 'deposit_method enum already exists';
    END IF;
END $$;

-- 7. deposit_status enum
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'deposit_status') THEN
        CREATE TYPE deposit_status AS ENUM ('pending', 'confirmed', 'rejected', 'expired');
        RAISE NOTICE 'Created deposit_status enum';
    ELSE
        RAISE NOTICE 'deposit_status enum already exists';
    END IF;
END $$;

-- 8. conversion_status enum
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'conversion_status') THEN
        CREATE TYPE conversion_status AS ENUM ('quoted', 'completed', 'failed');
        RAISE NOTICE 'Created conversion_status enum';
    ELSE
        RAISE NOTICE 'conversion_status enum already exists';
    END IF;
END $$;

-- 9. withdrawal_method enum
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'withdrawal_method') THEN
        CREATE TYPE withdrawal_method AS ENUM ('bank', 'paypal', 'crypto_trc20');
        RAISE NOTICE 'Created withdrawal_method enum';
    ELSE
        RAISE NOTICE 'withdrawal_method enum already exists';
    END IF;
END $$;

-- 10. withdrawal_status enum
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'withdrawal_status') THEN
        CREATE TYPE withdrawal_status AS ENUM ('pending', 'approved', 'rejected', 'paid');
        RAISE NOTICE 'Created withdrawal_status enum';
    ELSE
        RAISE NOTICE 'withdrawal_status enum already exists';
    END IF;
END $$;

-- 11. signal_type enum
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'signal_type') THEN
        CREATE TYPE signal_type AS ENUM ('one_time', 'subscription');
        RAISE NOTICE 'Created signal_type enum';
    ELSE
        RAISE NOTICE 'signal_type enum already exists';
    END IF;
END $$;

-- Final verification
SELECT 'ENUM_CREATION_COMPLETE' as status,
       COUNT(*) as total_enums
FROM pg_type 
WHERE typname IN (
    'app_role', 'kyc_status', 'currency_code', 'ledger_reason', 'position_status',
    'deposit_method', 'deposit_status', 'conversion_status', 'withdrawal_method',
    'withdrawal_status', 'signal_type'
)
AND typtype = 'e';
