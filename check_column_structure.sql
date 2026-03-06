-- Check exact column structure first, then query data

-- 1. Get exact column structure for signal_usdt_purchases
SELECT 'SIGNAL_USDT_PURCHASES_COLUMNS' as info, column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_schema = 'public' AND table_name = 'signal_usdt_purchases'
ORDER BY ordinal_position;

-- 2. Get exact column structure for deposit_requests
SELECT 'DEPOSIT_REQUESTS_COLUMNS' as info, column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_schema = 'public' AND table_name = 'deposit_requests'
ORDER BY ordinal_position;

-- 3. Get exact column structure for deposits
SELECT 'DEPOSITS_COLUMNS' as info, column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_schema = 'public' AND table_name = 'deposits'
ORDER BY ordinal_position;

-- 4. Get exact column structure for deposit_methods
SELECT 'DEPOSIT_METHODS_COLUMNS' as info, column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_schema = 'public' AND table_name = 'deposit_methods'
ORDER BY ordinal_position;

-- 5. Now query signal_usdt_purchases with correct columns
SELECT 'SIGNAL_USDT_PURCHASES_DATA' as info, 
    id, usdt_address, created_at, updated_at
FROM signal_usdt_purchases 
LIMIT 5;

-- 6. Query deposit_requests with correct columns
SELECT 'DEPOSIT_REQUESTS_DATA' as info, 
    id, usdt_address, btc_address, created_at, updated_at
FROM deposit_requests 
WHERE usdt_address IS NOT NULL OR btc_address IS NOT NULL
LIMIT 5;

-- 7. Query deposits with correct columns
SELECT 'DEPOSITS_DATA' as info, 
    id, usdt_address, btc_address, created_at, updated_at
FROM deposits 
WHERE usdt_address IS NOT NULL OR btc_address IS NOT NULL
LIMIT 5;

-- 8. Query deposit_methods with correct columns
SELECT 'DEPOSIT_METHODS_DATA' as info, 
    id, method_name, currency, address, created_at, updated_at
FROM deposit_methods 
LIMIT 5;

-- 9. Check for any hardcoded addresses in signal_usdt_purchases
SELECT 'SIGNAL_USDT_PURCHASES_ADDRESSES' as info, 
    COUNT(*) as total_records,
    COUNT(DISTINCT usdt_address) as unique_usdt_addresses
FROM signal_usdt_purchases 
WHERE usdt_address IS NOT NULL;

-- 10. Check for any hardcoded addresses in deposit_requests
SELECT 'DEPOSIT_REQUESTS_ADDRESSES' as info, 
    COUNT(*) as total_records,
    COUNT(DISTINCT usdt_address) as unique_usdt_addresses,
    COUNT(DISTINCT btc_address) as unique_btc_addresses
FROM deposit_requests 
WHERE usdt_address IS NOT NULL OR btc_address IS NOT NULL;
