-- Clean up deposit_methods table - remove duplicates and ensure only one active BTC method

-- 1. Show current state before cleanup
SELECT 'BEFORE_CLEANUP' as info, 
    method_type,
    method_name, 
    currency, 
    address, 
    is_active, 
    created_at, 
    updated_at
FROM deposit_methods 
ORDER BY created_at DESC;

-- 2. Remove the test address record
DO $$
BEGIN
    RAISE NOTICE '=== CLEANING UP DEPOSIT_METHODS ===';
    
    -- Remove test address record
    DELETE FROM deposit_methods 
    WHERE address LIKE 'TEST_ADDRESS_%';
    
    GET DIAGNOSTICS _deleted = ROW_COUNT;
    RAISE NOTICE 'Deleted % test address records', _deleted;
    
    -- Ensure only one active BTC method
    UPDATE deposit_methods 
    SET is_active = false 
    WHERE method_type = 'crypto' 
        AND currency = 'BTC' 
        AND method_name = 'BTC Bitcoin' 
        AND address != 'bc1q86kns3mf9wrqsv05lpwkvnyg3gq0e5pa90yrth';
    
    GET DIAGNOSTICS _deactivated = ROW_COUNT;
    RAISE NOTICE 'Deactivated % old BTC methods', _deactivated;
    
    -- Ensure only one active USDT method
    UPDATE deposit_methods 
    SET is_active = false 
    WHERE method_type = 'crypto' 
        AND currency = 'USDT' 
        AND method_name = 'USDT TRC20' 
        AND address != 'TTs6p5TT2a6kuyAzZX18pX4TZKfrJKstCy';
    
    GET DIAGNOSTICS _deactivated_usdt = ROW_COUNT;
    RAISE NOTICE 'Deactivated % old USDT methods', _deactivated_usdt;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error cleaning up deposit_methods: %', SQLERRM;
END $$;

-- 3. Verify the cleanup
SELECT 'AFTER_CLEANUP' as info, 
    method_type,
    method_name, 
    currency, 
    address, 
    is_active, 
    created_at, 
    updated_at
FROM deposit_methods 
ORDER BY method_type, currency;

-- 4. Show final active methods count
SELECT 'FINAL_ACTIVE_COUNT' as info, 
    COUNT(*) as total_active_methods
FROM deposit_methods 
WHERE is_active = true;

-- 5. Show only the active methods
SELECT 'ACTIVE_DEPOSIT_METHODS_ONLY' as info, 
    method_type,
    method_name, 
    currency, 
    network, 
    address, 
    is_active, 
    created_at, 
    updated_at
FROM deposit_methods 
WHERE is_active = true 
ORDER BY method_type, currency;
