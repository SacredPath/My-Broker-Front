-- Check how deposit addresses are saved in the database (SAFE VERSION)

-- 1. Find all tables that might contain deposit addresses
SELECT 
    'TABLES_WITH_ADDRESS_COLUMNS' as info,
    table_name,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public'
    AND (column_name ILIKE '%address%' OR column_name ILIKE '%deposit%' OR column_name ILIKE '%wallet%')
    AND table_name NOT IN (SELECT tablename FROM pg_tables WHERE schemaname = 'pg_catalog')
ORDER BY table_name, column_name;

-- 2. Check for currency-related columns in address tables
SELECT 
    'CURRENCY_COLUMNS_IN_ADDRESS_TABLES' as info,
    table_name,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public'
    AND table_name IN (
        SELECT DISTINCT table_name 
        FROM information_schema.columns 
        WHERE column_name ILIKE '%address%'
    )
    AND (column_name ILIKE '%currency%' OR column_name ILIKE '%coin%' OR column_name ILIKE '%asset%')
ORDER BY table_name, column_name;

-- 3. Check what columns actually exist in each potential table
SELECT 
    'DEPOSITS_TABLE_COLUMNS' as info,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_schema = 'public' AND table_name = 'deposits'
ORDER BY ordinal_position;

SELECT 
    'DEPOSIT_ADDRESSES_TABLE_COLUMNS' as info,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_schema = 'public' AND table_name = 'deposit_addresses'
ORDER BY ordinal_position;

SELECT 
    'WALLET_ADDRESSES_TABLE_COLUMNS' as info,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_schema = 'public' AND table_name = 'wallet_addresses'
ORDER BY ordinal_position;

SELECT 
    'PAYMENT_METHODS_TABLE_COLUMNS' as info,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_schema = 'public' AND table_name = 'payment_methods'
ORDER BY ordinal_position;

SELECT 
    'USER_WALLETS_TABLE_COLUMNS' as info,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_schema = 'public' AND table_name = 'user_wallets'
ORDER BY ordinal_position;

-- 4. Check currency enum values if they exist
SELECT 
    'CURRENCY_ENUM_VALUES' as info,
    enumlabel
FROM pg_enum 
JOIN pg_type ON pg_enum.enumtypid = pg_type.oid
WHERE pg_type.typname ILIKE '%currency%'
ORDER BY enumlabel;

-- 5. Safe sample data queries - only query tables that exist and have address columns
DO $$
BEGIN
    -- Check if deposits table exists and has address column
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'deposits' AND column_name = 'address') THEN
        RAISE NOTICE '=== DEPOSITS TABLE SAMPLE DATA ===';
        EXECUTE 'SELECT ''deposits'' as table_name, id, user_id, currency, address, amount, status, created_at FROM deposits WHERE address IS NOT NULL LIMIT 5';
    END IF;
    
    -- Check if deposit_addresses table exists and has address column
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'deposit_addresses' AND column_name = 'address') THEN
        RAISE NOTICE '=== DEPOSIT_ADDRESSES TABLE SAMPLE DATA ===';
        EXECUTE 'SELECT ''deposit_addresses'' as table_name, id, user_id, currency, address, created_at FROM deposit_addresses WHERE address IS NOT NULL LIMIT 5';
    END IF;
    
    -- Check if wallet_addresses table exists and has address column
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'wallet_addresses' AND column_name = 'address') THEN
        RAISE NOTICE '=== WALLET_ADDRESSES TABLE SAMPLE DATA ===';
        EXECUTE 'SELECT ''wallet_addresses'' as table_name, id, user_id, currency, address, created_at FROM wallet_addresses WHERE address IS NOT NULL LIMIT 5';
    END IF;
    
    -- Check if payment_methods table exists and has address column
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'payment_methods' AND column_name = 'address') THEN
        RAISE NOTICE '=== PAYMENT_METHODS TABLE SAMPLE DATA ===';
        EXECUTE 'SELECT ''payment_methods'' as table_name, id, user_id, currency, address, created_at FROM payment_methods WHERE address IS NOT NULL LIMIT 5';
    END IF;
    
    -- Check if user_wallets table exists and has address column
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_wallets' AND column_name = 'address') THEN
        RAISE NOTICE '=== USER_WALLETS TABLE SAMPLE DATA ===';
        EXECUTE 'SELECT ''user_wallets'' as table_name, id, user_id, currency, address, created_at FROM user_wallets WHERE address IS NOT NULL LIMIT 5';
    END IF;
END $$;

-- 6. Alternative: Use SELECT * to see all columns for tables that exist
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'deposits') THEN
        RAISE NOTICE '=== DEPOSITS TABLE (ALL COLUMNS) ===';
        EXECUTE 'SELECT * FROM deposits LIMIT 3';
    END IF;
END $$;

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'deposit_addresses') THEN
        RAISE NOTICE '=== DEPOSIT_ADDRESSES TABLE (ALL COLUMNS) ===';
        EXECUTE 'SELECT * FROM deposit_addresses LIMIT 3';
    END IF;
END $$;

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'wallet_addresses') THEN
        RAISE NOTICE '=== WALLET_ADDRESSES TABLE (ALL COLUMNS) ===';
        EXECUTE 'SELECT * FROM wallet_addresses LIMIT 3';
    END IF;
END $$;
