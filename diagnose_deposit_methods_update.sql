-- Diagnose Deposit Methods Update Issues
-- Check if triggers and updates are working correctly

-- 1. Check current state of all deposit methods
SELECT 'CURRENT_ALL_METHODS' as info,
    id,
    method_type,
    method_name,
    currency,
    address,
    is_active,
    created_at,
    updated_at,
    CASE 
        WHEN address LIKE 'TEST_ADDRESS_%' THEN 'TEST_RECORD'
        WHEN address = 'TSM63D4VdE2nev1PoMmqTr8ti3me9JYsJ4' THEN 'OLD_USDT'
        WHEN address = 'TTs6p5TT2a6kuyAzZX18pX4TZKfrJKstCy' THEN 'NEW_USDT'
        WHEN address = 'bc1q86kns3mf9wrqsv05lpwkvnyg3gq0e5pa90yrth' THEN 'NEW_BTC'
        ELSE 'UNKNOWN'
    END as address_type,
    EXTRACT(EPOCH FROM NOW()) - EXTRACT(EPOCH FROM updated_at) as seconds_since_update
FROM deposit_methods 
ORDER BY created_at DESC;

-- 2. Check if trigger exists on deposit_methods table
SELECT 'TRIGGER_CHECK' as info,
    trigger_name,
    event_manipulation,
    action_timing,
    action_orientation,
    event_object_table
FROM information_schema.triggers 
WHERE event_object_table = 'deposit_methods' 
AND trigger_schema = 'public';

-- 3. Check if trigger function exists
SELECT 'TRIGGER_FUNCTION_CHECK' as info,
    routine_name,
    routine_type
FROM information_schema.routines 
WHERE routine_name = 'handle_deposit_methods_updated_at'
AND routine_schema = 'public'
AND routine_type = 'FUNCTION';

-- 4. Test manual update to see if trigger fires
DO $$
DECLARE
    _test_id UUID;
    _before_update TIMESTAMP WITH TIME ZONE;
    _after_update TIMESTAMP WITH TIME ZONE;
BEGIN
    -- Get a test record ID
    SELECT id INTO _test_id 
    FROM deposit_methods 
    WHERE address = 'TTs6p5TT2a6kuyAzZX18pX4TZKfrJKstCy' 
    LIMIT 1;
    
    IF _test_id IS NOT NULL THEN
        -- Get current updated_at
        SELECT updated_at INTO _before_update
        FROM deposit_methods 
        WHERE id = _test_id;
        
        -- Manually update the record
        UPDATE deposit_methods 
        SET is_active = true 
        WHERE id = _test_id;
        
        -- Check if updated_at changed
        SELECT updated_at INTO _after_update
        FROM deposit_methods 
        WHERE id = _test_id;
        
        RAISE NOTICE '=== TRIGGER TEST RESULTS ===';
        RAISE NOTICE 'Test ID: %', _test_id;
        RAISE NOTICE 'Before update: %', _before_update;
        RAISE NOTICE 'After update: %', _after_update;
        RAISE NOTICE 'Trigger fired: %', CASE WHEN _after_update > _before_update THEN 'YES' ELSE 'NO' END;
    ELSE
        RAISE NOTICE 'Test USDT address not found';
    END IF;
END $$;

-- 5. Check if there are multiple active records for same currency
SELECT 'DUPLICATE_ACTIVE_CHECK' as info,
    currency,
    COUNT(*) as active_count,
    STRING_AGG(id::text, ', ' ORDER BY created_at DESC) as active_ids,
    STRING_AGG(address, ', ' ORDER BY created_at DESC) as active_addresses
FROM deposit_methods 
WHERE is_active = true 
GROUP BY currency
HAVING COUNT(*) > 1
ORDER BY currency;

-- 6. Show expected final state
SELECT 'EXPECTED_FINAL_STATE' as info,
    'TTs6p5TT2a6kuyAzZX18pX4TZKfrJKstCy' as should_be_active_usdt,
    'bc1q86kns3mf9wrqsv05lpwkvnyg3gq0e5pa90yrth' as should_be_active_btc;

-- 7. Manual fix if needed - deactivate all old addresses
DO $$
DECLARE
    _fixed_count INTEGER;
BEGIN
    RAISE NOTICE '=== MANUAL FIX ATTEMPT ===';
    
    -- Deactivate any address that's not the expected one
    UPDATE deposit_methods 
    SET is_active = false,
        updated_at = NOW()
    WHERE (currency = 'USDT' AND address != 'TTs6p5TT2a6kuyAzZX18pX4TZKfrJKstCy')
       OR (currency = 'BTC' AND address != 'bc1q86kns3mf9wrqsv05lpwkvnyg3gq0e5pa90yrth')
       OR address LIKE 'TEST_ADDRESS_%';
    
    GET DIAGNOSTICS _fixed_count = ROW_COUNT;
    RAISE NOTICE 'Fixed % deposit method records', _fixed_count;
    
    -- Activate the correct addresses
    UPDATE deposit_methods 
    SET is_active = true,
        updated_at = NOW()
    WHERE (currency = 'USDT' AND address = 'TTs6p5TT2a6kuyAzZX18pX4TZKfrJKstCy')
       OR (currency = 'BTC' AND address = 'bc1q86kns3mf9wrqsv05lpwkvnyg3gq0e5pa90yrth');
    
    GET DIAGNOSTICS _fixed_count = ROW_COUNT;
    RAISE NOTICE 'Activated % correct addresses', _fixed_count;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error in manual fix: %', SQLERRM;
END $$;

-- 8. Final verification
SELECT 'FINAL_VERIFICATION' as info,
    id,
    method_type,
    method_name,
    currency,
    address,
    is_active,
    updated_at
FROM deposit_methods 
WHERE is_active = true 
ORDER BY method_type, currency;
