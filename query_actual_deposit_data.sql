-- Query actual data using correct column names

-- 1. Check deposit_requests table (uses wallet_address)
SELECT 'DEPOSIT_REQUESTS_DATA' as info, 
    id, 
    wallet_address, 
    created_at, 
    updated_at
FROM deposit_requests 
WHERE wallet_address IS NOT NULL
LIMIT 5;

-- 2. Check deposits table (uses wallet_address)
SELECT 'DEPOSITS_DATA' as info, 
    id, 
    wallet_address, 
    created_at, 
    updated_at
FROM deposits 
WHERE wallet_address IS NOT NULL
LIMIT 5;

-- 3. Check signal_usdt_purchases table (uses usdt_address)
SELECT 'SIGNAL_USDT_PURCHASES_DATA' as info, 
    id, 
    usdt_address, 
    created_at, 
    updated_at
FROM signal_usdt_purchases 
WHERE usdt_address IS NOT NULL
LIMIT 5;

-- 4. Count records in each table
SELECT 'DEPOSIT_REQUESTS_COUNT' as info, COUNT(*) as total_records
FROM deposit_requests 
WHERE wallet_address IS NOT NULL;

SELECT 'DEPOSITS_COUNT' as info, COUNT(*) as total_records
FROM deposits 
WHERE wallet_address IS NOT NULL;

SELECT 'SIGNAL_USDT_PURCHASES_COUNT' as info, COUNT(*) as total_records
FROM signal_usdt_purchases 
WHERE usdt_address IS NOT NULL;

-- 5. Look for old BTC address in deposit_requests
SELECT 'DEPOSIT_REQUESTS_OLD_BTC' as info, 
    COUNT(*) as old_btc_count
FROM deposit_requests 
WHERE wallet_address LIKE 'bc1q%' OR wallet_address LIKE '1%' OR wallet_address LIKE '3%';

-- 6. Look for old USDT address in deposit_requests
SELECT 'DEPOSIT_REQUESTS_OLD_USDT' as info, 
    COUNT(*) as old_usdt_count
FROM deposit_requests 
WHERE wallet_address LIKE 'T%' AND LENGTH(wallet_address) = 34;

-- 7. Look for old BTC address in deposits
SELECT 'DEPOSITS_OLD_BTC' as info, 
    COUNT(*) as old_btc_count
FROM deposits 
WHERE wallet_address LIKE 'bc1q%' OR wallet_address LIKE '1%' OR wallet_address LIKE '3%';

-- 8. Look for old USDT address in deposits
SELECT 'DEPOSITS_OLD_USDT' as info, 
    COUNT(*) as old_usdt_count
FROM deposits 
WHERE wallet_address LIKE 'T%' AND LENGTH(wallet_address) = 34;

-- 9. Show sample addresses from deposit_requests
SELECT 'DEPOSIT_REQUESTS_SAMPLE_ADDRESSES' as info, 
    wallet_address,
    created_at
FROM deposit_requests 
WHERE wallet_address IS NOT NULL
ORDER BY created_at DESC
LIMIT 3;

-- 10. Show sample addresses from deposits
SELECT 'DEPOSITS_SAMPLE_ADDRESSES' as info, 
    wallet_address,
    created_at
FROM deposits 
WHERE wallet_address IS NOT NULL
ORDER BY created_at DESC
LIMIT 3;
