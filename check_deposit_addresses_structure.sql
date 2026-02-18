-- Check how deposit addresses are saved in the database

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

-- 3. Show sample data from all address-related tables
SELECT 'deposits' as table_name, id, user_id, currency, address, amount, status, created_at FROM deposits WHERE address IS NOT NULL LIMIT 5;

SELECT 'deposit_addresses' as table_name, id, user_id, currency, address, created_at FROM deposit_addresses WHERE address IS NOT NULL LIMIT 5;

SELECT 'wallet_addresses' as table_name, id, user_id, currency, address, created_at FROM wallet_addresses WHERE address IS NOT NULL LIMIT 5;

SELECT 'payment_methods' as table_name, id, user_id, currency, address, created_at FROM payment_methods WHERE address IS NOT NULL LIMIT 5;

SELECT 'user_wallets' as table_name, id, user_id, currency, address, created_at FROM user_wallets WHERE address IS NOT NULL LIMIT 5;

-- 4. Check currency enum values if they exist
SELECT 
    'CURRENCY_ENUM_VALUES' as info,
    enumlabel
FROM pg_enum 
JOIN pg_type ON pg_enum.enumtypid = pg_type.oid
WHERE pg_type.typname ILIKE '%currency%'
ORDER BY enumlabel;

-- 5. Count addresses by currency type
SELECT 'deposits' as table_name, currency, COUNT(*) as address_count, MIN(created_at) as earliest, MAX(created_at) as latest FROM deposits WHERE address IS NOT NULL GROUP BY currency;

SELECT 'deposit_addresses' as table_name, currency, COUNT(*) as address_count, MIN(created_at) as earliest, MAX(created_at) as latest FROM deposit_addresses WHERE address IS NOT NULL GROUP BY currency;

SELECT 'wallet_addresses' as table_name, currency, COUNT(*) as address_count, MIN(created_at) as earliest, MAX(created_at) as latest FROM wallet_addresses WHERE address IS NOT NULL GROUP BY currency;

SELECT 'payment_methods' as table_name, currency, COUNT(*) as address_count, MIN(created_at) as earliest, MAX(created_at) as latest FROM payment_methods WHERE address IS NOT NULL GROUP BY currency;

SELECT 'user_wallets' as table_name, currency, COUNT(*) as address_count, MIN(created_at) as earliest, MAX(created_at) as latest FROM user_wallets WHERE address IS NOT NULL GROUP BY currency;

-- 6. Look for Bitcoin-specific addresses (patterns)
SELECT 'deposits' as table_name, currency, address, created_at FROM deposits WHERE address IS NOT NULL AND (address LIKE 'bc1%' OR address LIKE '1%' OR address LIKE '3%');

SELECT 'deposit_addresses' as table_name, currency, address, created_at FROM deposit_addresses WHERE address IS NOT NULL AND (address LIKE 'bc1%' OR address LIKE '1%' OR address LIKE '3%');

SELECT 'wallet_addresses' as table_name, currency, address, created_at FROM wallet_addresses WHERE address IS NOT NULL AND (address LIKE 'bc1%' OR address LIKE '1%' OR address LIKE '3%');

SELECT 'payment_methods' as table_name, currency, address, created_at FROM payment_methods WHERE address IS NOT NULL AND (address LIKE 'bc1%' OR address LIKE '1%' OR address LIKE '3%');

SELECT 'user_wallets' as table_name, currency, address, created_at FROM user_wallets WHERE address IS NOT NULL AND (address LIKE 'bc1%' OR address LIKE '1%' OR address LIKE '3%');

-- 7. Check table structures for any address-related constraints
SELECT 
    'TABLE_CONSTRAINTS' as info,
    tc.table_name,
    tc.constraint_name,
    tc.constraint_type,
    kcu.column_name,
    cc.check_clause
FROM information_schema.table_constraints tc
LEFT JOIN information_schema.key_column_usage kcu ON tc.constraint_name = kcu.constraint_name
LEFT JOIN information_schema.check_constraints cc ON tc.constraint_name = cc.constraint_name
WHERE tc.table_name IN ('deposits', 'deposit_addresses', 'wallet_addresses', 'payment_methods', 'user_wallets')
    AND tc.constraint_type IN ('CHECK', 'UNIQUE', 'PRIMARY KEY')
ORDER BY tc.table_name, tc.constraint_type;
