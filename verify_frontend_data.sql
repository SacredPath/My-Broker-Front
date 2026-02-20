-- Verify Frontend Data Source
-- Check if frontend is reading correct deposit methods data

-- 1. Show exactly what the frontend should display
SELECT 'FRONTEND_EXPECTED_DATA' as info,
    'Only active methods should be displayed' as note;

-- 2. Show current active methods (what frontend should show)
SELECT 'ACTIVE_DEPOSIT_METHODS' as info,
    id,
    method_type,
    method_name,
    currency,
    network,
    address,
    min_amount,
    max_amount,
    fee_percentage,
    fixed_fee,
    processing_time_hours,
    instructions,
    is_active,
    created_at,
    updated_at,
    'ACTIVE' as status
FROM deposit_methods 
WHERE is_active = true 
ORDER BY method_type, currency;

-- 3. Check if there are any other test addresses still present
SELECT 'REMAINING_TEST_ADDRESSES' as info,
    COUNT(*) as test_address_count
FROM deposit_methods 
WHERE address LIKE 'TEST_ADDRESS_%';

-- 4. Check for any inactive addresses that might confuse frontend
SELECT 'INACTIVE_ADDRESSES' as info,
    id,
    method_type,
    method_name,
    currency,
    address,
    is_active,
    created_at,
    updated_at,
    'INACTIVE' as status
FROM deposit_methods 
WHERE address LIKE 'TEST_ADDRESS_%' OR is_active = false
ORDER BY created_at DESC;

-- 5. Force refresh of materialized view or cache if it exists
DO $$
BEGIN
    -- Check if there's a view that might be cached
    IF EXISTS (SELECT 1 FROM information_schema.views WHERE table_name = 'active_deposit_methods_view') THEN
        RAISE NOTICE 'Refreshing active_deposit_methods_view...';
        EXECUTE 'REFRESH MATERIALIZED VIEW active_deposit_methods_view';
    END IF;
    
    -- Check if there's a function that returns active methods
    IF EXISTS (SELECT 1 FROM information_schema.routines WHERE routine_name = 'get_active_deposit_methods') THEN
        RAISE NOTICE 'get_active_deposit_methods function exists - frontend should use this';
    END IF;
END $$;

-- 6. Create a simple view for frontend to use
CREATE OR REPLACE VIEW active_deposit_methods_view AS
SELECT 
    id,
    method_type,
    method_name,
    currency,
    network,
    address,
    bank_name,
    account_number,
    routing_number,
    paypal_email,
    paypal_business_name,
    min_amount,
    max_amount,
    fee_percentage,
    fixed_fee,
    processing_time_hours,
    instructions,
    is_active,
    created_at,
    updated_at
FROM deposit_methods 
WHERE is_active = true;

-- 7. Test the get_active_deposit_methods function
SELECT 'TEST_GET_ACTIVE_METHODS' as info,
    *
FROM get_active_deposit_methods();

-- 8. Create a simplified query that frontend should use
SELECT 'SIMPLIFIED_FRONTEND_QUERY' as info,
    'Use this query in frontend:' as recommendation,
    'SELECT id, method_type, method_name, currency, network, address, min_amount, max_amount, fee_percentage, fixed_fee, processing_time_hours, instructions FROM deposit_methods WHERE is_active = true ORDER BY method_type, currency' as sql_query;

-- 9. Final verification of expected addresses
SELECT 'EXPECTED_ADDRESSES_FOR_FRONTEND' as info,
    'bc1q86kns3mf9wrqsv05lpwkvnyg3gq0e5pa90yrth' as correct_btc_address,
    'TTs6p5TT2a6kuyAzZX18pX4TZKfrJKstCy' as correct_usdt_address,
    'These should be the only addresses shown in frontend' as note;
