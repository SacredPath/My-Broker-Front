-- Simple direct queries to find deposit data

-- 1. List all tables in the database
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

-- 3. Check specific common deposit tables
SELECT 'CHECK_PAYMENT_METHODS' as info, 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'payment_methods') 
        THEN 'EXISTS' 
        ELSE 'NOT_FOUND' 
    END as status;

SELECT 'CHECK_DEPOSIT_ADDRESSES' as info, 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'deposit_addresses') 
        THEN 'EXISTS' 
        ELSE 'NOT_FOUND' 
    END as status;

SELECT 'CHECK_DEPOSITS' as info, 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'deposits') 
        THEN 'EXISTS' 
        ELSE 'NOT_FOUND' 
    END as status;

SELECT 'CHECK_PAYMENTS' as info, 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'payments') 
        THEN 'EXISTS' 
        ELSE 'NOT_FOUND' 
    END as status;

-- 4. If payment_methods exists, show its data
SELECT 'PAYMENT_METHODS_DATA' as info, * FROM payment_methods LIMIT 3;

-- 5. If deposit_addresses exists, show its data  
SELECT 'DEPOSIT_ADDRESSES_DATA' as info, * FROM deposit_addresses LIMIT 3;

-- 6. If deposits exists, show its data
SELECT 'DEPOSITS_DATA' as info, * FROM deposits LIMIT 3;

-- 7. If payments exists, show its data
SELECT 'PAYMENTS_DATA' as info, * FROM payments LIMIT 3;

-- 8. Check for any table that might contain BTC/USDT addresses
SELECT 'SEARCH_BTC_USDT' as info, table_name
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
