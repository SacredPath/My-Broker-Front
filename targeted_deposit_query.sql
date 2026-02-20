-- Targeted query for the actual deposit tables we found

-- 1. Check deposit_requests table (most likely candidate)
SELECT 'DEPOSIT_REQUESTS_STRUCTURE' as info, column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_schema = 'public' AND table_name = 'deposit_requests'
ORDER BY ordinal_position;

-- 2. Show all data from deposit_requests
SELECT 'DEPOSIT_REQUESTS_DATA' as info, * FROM deposit_requests LIMIT 10;

-- 3. Check deposits table structure
SELECT 'DEPOSITS_STRUCTURE' as info, column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_schema = 'public' AND table_name = 'deposits'
ORDER BY ordinal_position;

-- 4. Show all data from deposits
SELECT 'DEPOSITS_DATA' as info, * FROM deposits LIMIT 10;

-- 5. Check deposit_methods table (our created table)
SELECT 'DEPOSIT_METHODS_STRUCTURE' as info, column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_schema = 'public' AND table_name = 'deposit_methods'
ORDER BY ordinal_position;

-- 6. Show all data from deposit_methods
SELECT 'DEPOSIT_METHODS_DATA' as info, * FROM deposit_methods LIMIT 10;

-- 7. Check signal_usdt_purchases table (might have addresses)
SELECT 'SIGNAL_USDT_PURCHASES_STRUCTURE' as info, column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_schema = 'public' AND table_name = 'signal_usdt_purchases'
ORDER BY ordinal_position;

-- 8. Show sample data from signal_usdt_purchases
SELECT 'SIGNAL_USDT_PURCHASES_DATA' as info, 
    id, usdt_address, address, created_at, updated_at
FROM signal_usdt_purchases 
LIMIT 5;

-- 9. Look for any BTC/USDT addresses in deposit_requests
SELECT 'DEPOSIT_REQUESTS_ADDRESSES' as info, *
FROM deposit_requests 
WHERE usdt_address IS NOT NULL OR btc_address IS NOT NULL
LIMIT 5;

-- 10. Look for any BTC/USDT addresses in deposits
SELECT 'DEPOSITS_ADDRESSES' as info, *
FROM deposits 
WHERE usdt_address IS NOT NULL OR btc_address IS NOT NULL
LIMIT 5;
