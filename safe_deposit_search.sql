-- Safe query that only accesses existing tables

-- 1. List all tables in database
SELECT 'ALL_TABLES' as info, table_name, table_type 
FROM information_schema.tables 
WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- 2. Look for tables with address-related columns
SELECT 'ADDRESS_COLUMNS' as info, table_name, column_name, data_type
FROM information_schema.columns 
WHERE table_schema = 'public' 
    AND (
        column_name LIKE '%address%' OR
        column_name LIKE '%btc%' OR
        column_name LIKE '%usdt%' OR
        column_name LIKE '%crypto%' OR
        column_name LIKE '%deposit%'
    )
ORDER BY table_name, column_name;

-- 3. Check which tables exist before querying them
SELECT 'TABLE_EXISTENCE_CHECK' as info, 
    table_name,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'payment_methods') 
        THEN 'EXISTS' 
        ELSE 'NOT_FOUND' 
    END as status
FROM (VALUES ('payment_methods'), ('deposit_addresses'), ('deposits'), ('payments')) AS t(table_name);

-- 4. Only query tables that exist
DO $$
DECLARE
    table_record RECORD;
BEGIN
    RAISE NOTICE '=== QUERYING EXISTING TABLES ===';
    
    -- Check payment_methods
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'payment_methods') THEN
        RAISE NOTICE 'Querying payment_methods table';
        EXECUTE 'SELECT ''PAYMENT_METHODS_DATA'' as info, * FROM payment_methods LIMIT 3';
    END IF;
    
    -- Check deposit_addresses
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'deposit_addresses') THEN
        RAISE NOTICE 'Querying deposit_addresses table';
        EXECUTE 'SELECT ''DEPOSIT_ADDRESSES_DATA'' as info, * FROM deposit_addresses LIMIT 3';
    END IF;
    
    -- Check deposits
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'deposits') THEN
        RAISE NOTICE 'Querying deposits table';
        EXECUTE 'SELECT ''DEPOSITS_DATA'' as info, * FROM deposits LIMIT 3';
    END IF;
    
    -- Check payments
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'payments') THEN
        RAISE NOTICE 'Querying payments table';
        EXECUTE 'SELECT ''PAYMENTS_DATA'' as info, * FROM payments LIMIT 3';
    END IF;
    
    -- Check deposit_methods
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'deposit_methods') THEN
        RAISE NOTICE 'Querying deposit_methods table';
        EXECUTE 'SELECT ''DEPOSIT_METHODS_DATA'' as info, * FROM deposit_methods LIMIT 3';
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error querying existing tables: %', SQLERRM;
END $$;

-- 5. Search for any table containing BTC/USDT addresses
SELECT 'BTC_USDT_TABLES' as info, table_name
FROM information_schema.tables 
WHERE table_schema = 'public' 
    AND table_type = 'BASE TABLE'
    AND EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = information_schema.tables.table_name 
            AND table_schema = 'public'
            AND column_name LIKE '%address%'
    )
ORDER BY table_name;
