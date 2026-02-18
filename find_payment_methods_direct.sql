-- Find actual payment method tables directly (not notification settings)

-- 1. List all tables in public schema to see what's actually available
SELECT 
    'ALL_PUBLIC_TABLES' as info,
    table_name,
    table_type
FROM information_schema.tables 
WHERE table_schema = 'public'
    AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- 2. Look specifically for payment/deposit related tables
SELECT 
    'PAYMENT_RELATED_TABLES' as info,
    table_name,
    table_type
FROM information_schema.tables 
WHERE table_schema = 'public'
    AND table_type = 'BASE TABLE'
    AND (
        table_name ILIKE '%payment%' 
        OR table_name ILIKE '%deposit%'
        OR table_name ILIKE '%method%'
        OR table_name ILIKE '%wallet%'
        OR table_name ILIKE '%bank%'
        OR table_name ILIKE '%crypto%'
        OR table_name ILIKE '%paypal%'
        OR table_name ILIKE '%transfer%'
    )
ORDER BY table_name;

-- 3. Check if these specific tables exist
SELECT 
    'SPECIFIC_TABLE_CHECK' as info,
    'payment_methods' as table_name,
    EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_schema = 'public' AND table_name = 'payment_methods'
    ) as exists;

SELECT 
    'SPECIFIC_TABLE_CHECK' as info,
    'deposit_methods' as table_name,
    EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_schema = 'public' AND table_name = 'deposit_methods'
    ) as exists;

SELECT 
    'SPECIFIC_TABLE_CHECK' as info,
    'user_payment_methods' as table_name,
    EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_schema = 'public' AND table_name = 'user_payment_methods'
    ) as exists;

SELECT 
    'SPECIFIC_TABLE_CHECK' as info,
    'bank_accounts' as table_name,
    EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_schema = 'public' AND table_name = 'bank_accounts'
    ) as exists;

SELECT 
    'SPECIFIC_TABLE_CHECK' as info,
    'wallets' as table_name,
    EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_schema = 'public' AND table_name = 'wallets'
    ) as exists;

SELECT 
    'SPECIFIC_TABLE_CHECK' as info,
    'user_wallets' as table_name,
    EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_schema = 'public' AND table_name = 'user_wallets'
    ) as exists;

-- 4. Show sample data from tables that exist
DO $$
BEGIN
    -- payment_methods
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'payment_methods') THEN
        RAISE NOTICE '=== PAYMENT_METHODS TABLE ===';
        EXECUTE 'SELECT * FROM payment_methods LIMIT 5';
    ELSE
        RAISE NOTICE 'payment_methods table does not exist';
    END IF;
    
    -- deposit_methods
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'deposit_methods') THEN
        RAISE NOTICE '=== DEPOSIT_METHODS TABLE ===';
        EXECUTE 'SELECT * FROM deposit_methods LIMIT 5';
    ELSE
        RAISE NOTICE 'deposit_methods table does not exist';
    END IF;
    
    -- user_payment_methods
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'user_payment_methods') THEN
        RAISE NOTICE '=== USER_PAYMENT_METHODS TABLE ===';
        EXECUTE 'SELECT * FROM user_payment_methods LIMIT 5';
    ELSE
        RAISE NOTICE 'user_payment_methods table does not exist';
    END IF;
    
    -- bank_accounts
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'bank_accounts') THEN
        RAISE NOTICE '=== BANK_ACCOUNTS TABLE ===';
        EXECUTE 'SELECT * FROM bank_accounts LIMIT 5';
    ELSE
        RAISE NOTICE 'bank_accounts table does not exist';
    END IF;
    
    -- wallets
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'wallets') THEN
        RAISE NOTICE '=== WALLETS TABLE ===';
        EXECUTE 'SELECT * FROM wallets LIMIT 5';
    ELSE
        RAISE NOTICE 'wallets table does not exist';
    END IF;
    
    -- user_wallets
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'user_wallets') THEN
        RAISE NOTICE '=== USER_WALLETS TABLE ===';
        EXECUTE 'SELECT * FROM user_wallets LIMIT 5';
    ELSE
        RAISE NOTICE 'user_wallets table does not exist';
    END IF;
END $$;
