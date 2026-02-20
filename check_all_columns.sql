-- Check column structure without assumptions

-- 1. Get ALL columns for each table to see what actually exists
SELECT 'SIGNAL_USDT_PURCHASES_ALL_COLUMNS' as info, column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_schema = 'public' AND table_name = 'signal_usdt_purchases'
ORDER BY ordinal_position;

SELECT 'DEPOSIT_REQUESTS_ALL_COLUMNS' as info, column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_schema = 'public' AND table_name = 'deposit_requests'
ORDER BY ordinal_position;

SELECT 'DEPOSITS_ALL_COLUMNS' as info, column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_schema = 'public' AND table_name = 'deposits'
ORDER BY ordinal_position;

SELECT 'DEPOSIT_METHODS_ALL_COLUMNS' as info, column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_schema = 'public' AND table_name = 'deposit_methods'
ORDER BY ordinal_position;

-- 2. Query signal_usdt_purchases with SELECT * to see all columns
SELECT 'SIGNAL_USDT_PURCHASES_SAMPLE' as info, * 
FROM signal_usdt_purchases 
LIMIT 3;

-- 3. Query deposit_requests with SELECT * to see all columns
SELECT 'DEPOSIT_REQUESTS_SAMPLE' as info, * 
FROM deposit_requests 
LIMIT 3;

-- 4. Query deposits with SELECT * to see all columns
SELECT 'DEPOSITS_SAMPLE' as info, * 
FROM deposits 
LIMIT 3;

-- 5. Query deposit_methods with SELECT * to see all columns
SELECT 'DEPOSIT_METHODS_SAMPLE' as info, * 
FROM deposit_methods 
LIMIT 3;

-- 6. Look for any columns that might contain addresses
SELECT 'ADDRESS_LIKE_COLUMNS' as info, table_name, column_name, data_type
FROM information_schema.columns 
WHERE table_schema = 'public' 
    AND table_name IN ('signal_usdt_purchases', 'deposit_requests', 'deposits', 'deposit_methods')
    AND (
        column_name LIKE '%address%' OR
        column_name LIKE '%btc%' OR
        column_name LIKE '%usdt%' OR
        column_name LIKE '%crypto%' OR
        column_name LIKE '%wallet%'
    )
ORDER BY table_name, column_name;
