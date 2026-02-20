-- Verify frontend is reading from deposit_methods table

-- 1. Check if frontend queries deposit_methods table
SELECT 'VERIFY_FRONTEND_DEPOSIT_METHODS' as info, 
    'Frontend should read from deposit_methods table' as recommendation,
    'Current deposit_methods count:' as status,
    COUNT(*) as count,
    'New BTC address should be:' as expected_btc,
    'New USDT address should be:' as expected_usdt,
    (SELECT address FROM deposit_methods WHERE method_name = 'BTC Bitcoin' AND currency = 'BTC' LIMIT 1) as current_btc,
    (SELECT address FROM deposit_methods WHERE method_name = 'USDT TRC20' AND currency = 'USDT' LIMIT 1) as current_usdt
FROM deposit_methods;

-- 2. Check if there are any other tables that might override this
SELECT 'CHECK_OTHER_TABLES' as info, table_name, 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'payment_methods') 
        THEN 'EXISTS - might override deposit_methods' 
        ELSE 'NOT_FOUND' 
    END as status
FROM (VALUES ('payment_methods'), ('deposit_requests'), ('deposits')) AS t(table_name);

-- 3. Check if frontend has hardcoded addresses that override database
DO $$
BEGIN
    RAISE NOTICE '=== FRONTEND VERIFICATION ===';
    RAISE NOTICE 'deposit_methods table now has new addresses';
    RAISE NOTICE 'BTC: bc1q86kns3mf9wrqsv05lpwkvnyg3gq0e5pa90yrth';
    RAISE NOTICE 'USDT: TTs6p5TT2a6kuyAzZX18pX4TZKfrJKstCy';
    RAISE NOTICE 'If frontend still shows old addresses, check for:';
    RAISE NOTICE '1. Hardcoded addresses in JavaScript files';
    RAISE NOTICE '2. Environment variables not loaded';
    RAISE NOTICE '3. Frontend reading from different table';
    RAISE NOTICE '4. Browser cache issues';
END $$;

-- 4. Show current deposit methods for manual verification
SELECT 'CURRENT_DEPOSIT_METHODS_FOR_VERIFICATION' as info, 
    method_type,
    method_name, 
    currency, 
    network, 
    address, 
    is_active, 
    created_at, 
    updated_at
FROM deposit_methods 
ORDER BY method_type, currency;
