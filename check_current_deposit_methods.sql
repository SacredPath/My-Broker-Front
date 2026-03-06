-- Check current deposit methods (PayPal, bank details, BTC, USDT, etc.)

-- 1. Find all tables that might contain deposit methods
SELECT 
    'DEPOSIT_METHOD_TABLES' as info,
    table_name,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public'
    AND (column_name ILIKE '%method%' OR column_name ILIKE '%deposit%' OR column_name ILIKE '%payment%' OR column_name ILIKE '%paypal%' OR column_name ILIKE '%bank%' OR column_name ILIKE '%crypto%' OR column_name ILIKE '%address%')
    AND table_name NOT IN (SELECT tablename FROM pg_tables WHERE schemaname = 'pg_catalog')
ORDER BY table_name, column_name;

-- 2. Check what payment/deposit method tables actually exist
SELECT 
    'EXISTING_TABLES' as info,
    table_name,
    table_type
FROM information_schema.tables 
WHERE table_schema = 'public'
    AND (table_name ILIKE '%payment%' OR table_name ILIKE '%deposit%' OR table_name ILIKE '%method%' OR table_name ILIKE '%wallet%')
ORDER BY table_name;

-- 3. Check currency enum values to see available payment types
SELECT 
    'CURRENCY_ENUM_VALUES' as info,
    enumlabel
FROM pg_enum 
JOIN pg_type ON pg_enum.enumtypid = pg_type.oid
WHERE pg_type.typname ILIKE '%currency%' OR pg_type.typname ILIKE '%payment%' OR pg_type.typname ILIKE '%method%'
ORDER BY enumlabel;

-- 4. Show columns for key payment-related tables
SELECT 
    'PAYMENT_METHODS_COLUMNS' as info,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public' AND table_name = 'payment_methods'
ORDER BY ordinal_position;

SELECT 
    'DEPOSIT_METHODS_COLUMNS' as info,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public' AND table_name = 'deposit_methods'
ORDER BY ordinal_position;

SELECT 
    'USER_PAYMENT_METHODS_COLUMNS' as info,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public' AND table_name = 'user_payment_methods'
ORDER BY ordinal_position;

SELECT 
    'BANK_ACCOUNTS_COLUMNS' as info,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public' AND table_name = 'bank_accounts'
ORDER BY ordinal_position;

-- 5. Show current deposit methods data (safe queries)
DO $$
BEGIN
    -- Check payment_methods table
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'payment_methods') THEN
        RAISE NOTICE '=== PAYMENT_METHODS TABLE ===';
        EXECUTE 'SELECT * FROM payment_methods LIMIT 10';
    END IF;
    
    -- Check deposit_methods table
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'deposit_methods') THEN
        RAISE NOTICE '=== DEPOSIT_METHODS TABLE ===';
        EXECUTE 'SELECT * FROM deposit_methods LIMIT 10';
    END IF;
    
    -- Check user_payment_methods table
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'user_payment_methods') THEN
        RAISE NOTICE '=== USER_PAYMENT_METHODS TABLE ===';
        EXECUTE 'SELECT * FROM user_payment_methods LIMIT 10';
    END IF;
    
    -- Check bank_accounts table
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'bank_accounts') THEN
        RAISE NOTICE '=== BANK_ACCOUNTS TABLE ===';
        EXECUTE 'SELECT * FROM bank_accounts LIMIT 10';
    END IF;
    
    -- Check wallets table
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'wallets') THEN
        RAISE NOTICE '=== WALLETS TABLE ===';
        EXECUTE 'SELECT * FROM wallets LIMIT 10';
    END IF;
END $$;

-- 6. Look for specific payment method patterns
DO $$
BEGIN
    -- Look for PayPal methods
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'payment_methods' AND column_name ILIKE '%paypal%') THEN
        RAISE NOTICE '=== PAYPAL METHODS ===';
        EXECUTE 'SELECT * FROM payment_methods WHERE method ILIKE ''%paypal%'' OR type ILIKE ''%paypal%'' OR name ILIKE ''%paypal%'' LIMIT 5';
    END IF;
    
    -- Look for bank methods
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'payment_methods' AND column_name ILIKE '%bank%') THEN
        RAISE NOTICE '=== BANK METHODS ===';
        EXECUTE 'SELECT * FROM payment_methods WHERE method ILIKE ''%bank%'' OR type ILIKE ''%bank%'' OR name ILIKE ''%bank%'' LIMIT 5';
    END IF;
    
    -- Look for crypto methods
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'payment_methods' AND column_name ILIKE '%crypto%') THEN
        RAISE NOTICE '=== CRYPTO METHODS ===';
        EXECUTE 'SELECT * FROM payment_methods WHERE method ILIKE ''%crypto%'' OR type ILIKE ''%crypto%'' OR name ILIKE ''%crypto%'' LIMIT 5';
    END IF;
END $$;

-- 7. Count methods by type
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'payment_methods') THEN
        RAISE NOTICE '=== PAYMENT_METHODS COUNT BY TYPE ===';
        EXECUTE 'SELECT method, type, currency, COUNT(*) as count FROM payment_methods GROUP BY method, type, currency ORDER BY count DESC';
    END IF;
END $$;

-- 8. Check for user-specific payment preferences
SELECT 
    'USER_PAYMENT_PREFERENCES' as info,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public' 
    AND (table_name ILIKE '%user%' AND (column_name ILIKE '%payment%' OR column_name ILIKE '%deposit%' OR column_name ILIKE '%method%'))
ORDER BY table_name, column_name;

-- 9. Show any configuration or settings tables for payment methods
SELECT 
    'PAYMENT_CONFIG_TABLES' as info,
    table_name,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public'
    AND (table_name ILIKE '%config%' OR table_name ILIKE '%setting%')
    AND (column_name ILIKE '%payment%' OR column_name ILIKE '%deposit%' OR column_name ILIKE '%method%')
ORDER BY table_name, column_name;
