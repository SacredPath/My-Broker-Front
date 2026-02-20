-- Clean Up Test Addresses from deposit_methods
-- Remove test addresses and ensure only real addresses are active

-- 1. Show current state before cleanup
SELECT 'BEFORE_CLEANUP' as info,
    id,
    method_type,
    method_name,
    currency,
    address,
    is_active,
    created_at,
    CASE 
        WHEN address LIKE 'TEST_ADDRESS_%' THEN 'TEST_RECORD'
        WHEN address = 'TSM63D4VdE2nev1PoMmqTr8ti3me9JYsJ4' THEN 'OLD_USDT'
        WHEN address = 'TTs6p5TT2a6kuyAzZX18pX4TZKfrJKstCy' THEN 'NEW_USDT'
        WHEN address = 'bc1q86kns3mf9wrqsv05lpwkvnyg3gq0e5pa90yrth' THEN 'NEW_BTC'
        ELSE 'UNKNOWN'
    END as address_type
FROM deposit_methods 
ORDER BY created_at DESC;

-- 2. Remove test address records
DO $$
DECLARE
    _deleted_count INTEGER;
BEGIN
    RAISE NOTICE '=== CLEANING UP TEST ADDRESSES ===';
    
    DELETE FROM deposit_methods 
    WHERE address LIKE 'TEST_ADDRESS_%';
    
    GET DIAGNOSTICS _deleted_count = ROW_COUNT;
    RAISE NOTICE 'Deleted % test address records', _deleted_count;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error cleaning test addresses: %', SQLERRM;
END $$;

-- 3. Ensure only one active USDT method (the new one)
DO $$
DECLARE
    _deactivated_count INTEGER;
BEGIN
    UPDATE deposit_methods 
    SET is_active = false 
    WHERE method_type = 'crypto' 
        AND currency = 'USDT' 
        AND method_name = 'USDT TRC20' 
        AND address = 'TSM63D4VdE2nev1PoMmqTr8ti3me9JYsJ4';
    
    GET DIAGNOSTICS _deactivated_count = ROW_COUNT;
    RAISE NOTICE 'Deactivated % old USDT methods', _deactivated_count;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error deactivating old USDT: %', SQLERRM;
END $$;

-- 4. Ensure only one active BTC method (the new one)
DO $$
DECLARE
    _deactivated_count INTEGER;
BEGIN
    UPDATE deposit_methods 
    SET is_active = false 
    WHERE method_type = 'crypto' 
        AND currency = 'BTC' 
        AND method_name = 'BTC Bitcoin' 
        AND address != 'bc1q86kns3mf9wrqsv05lpwkvnyg3gq0e5pa90yrth';
    
    GET DIAGNOSTICS _deactivated_count = ROW_COUNT;
    RAISE NOTICE 'Deactivated % old BTC methods', _deactivated_count;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error deactivating old BTC: %', SQLERRM;
END $$;

-- 5. Verify cleanup results
SELECT 'AFTER_CLEANUP' as info,
    id,
    method_type,
    method_name,
    currency,
    address,
    is_active,
    created_at,
    CASE 
        WHEN address LIKE 'TEST_ADDRESS_%' THEN 'TEST_RECORD'
        WHEN address = 'TSM63D4VdE2nev1PoMmqTr8ti3me9JYsJ4' THEN 'OLD_USDT'
        WHEN address = 'TTs6p5TT2a6kuyAzZX18pX4TZKfrJKstCy' THEN 'NEW_USDT'
        WHEN address = 'bc1q86kns3mf9wrqsv05lpwkvnyg3gq0e5pa90yrth' THEN 'NEW_BTC'
        ELSE 'UNKNOWN'
    END as address_type
FROM deposit_methods 
WHERE is_active = true 
ORDER BY method_type, currency;

-- 6. Show final active methods count
SELECT 'FINAL_ACTIVE_COUNT' as info,
    COUNT(*) as total_active_methods,
    COUNT(CASE WHEN method_type = 'crypto' THEN 1 END) as crypto_methods,
    COUNT(CASE WHEN method_type = 'bank' THEN 1 END) as bank_methods,
    COUNT(CASE WHEN method_type = 'paypal' THEN 1 END) as paypal_methods
FROM deposit_methods 
WHERE is_active = true;

-- 7. Show which addresses should be active
SELECT 'EXPECTED_ACTIVE_ADDRESSES' as info,
    'TTs6p5TT2a6kuyAzZX18pX4TZKfrJKstCy' as expected_usdt_address,
    'bc1q86kns3mf9wrqsv05lpwkvnyg3gq0e5pa90yrth' as expected_btc_address;
