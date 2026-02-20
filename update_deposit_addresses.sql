-- Update BTC and USDT deposit addresses using correct column names

-- 1. Update BTC address to: bc1q86kns3mf9wrqsv05lpwkvnyg3gq0e5pa90yrth
UPDATE deposit_methods 
SET address = 'bc1q86kns3mf9wrqsv05lpwkvnyg3gq0e5pa90yrth',
    updated_at = NOW()
WHERE method_name = 'BTC Bitcoin' AND currency = 'BTC';

-- 2. Update USDT TRC20 address to: TTs6p5TT2a6kuyAzZX18pX4TZKfrJKstCy
UPDATE deposit_methods 
SET address = 'TTs6p5TT2a6kuyAzZX18pX4TZKfrJKstCy',
    updated_at = NOW()
WHERE method_name = 'USDT TRC20' AND currency = 'USDT';

-- 3. Verify the updates
SELECT 
    'UPDATED_BTC_ADDRESS' as info,
    id,
    method_name,
    currency,
    address,
    updated_at
FROM deposit_methods 
WHERE method_name = 'BTC Bitcoin' AND currency = 'BTC';

SELECT 
    'UPDATED_USDT_ADDRESS' as info,
    id,
    method_name,
    currency,
    network,
    address,
    updated_at
FROM deposit_methods 
WHERE method_name = 'USDT TRC20' AND currency = 'USDT';

-- 4. Show all current deposit methods after update
SELECT 
    'ALL_DEPOSIT_METHODS_AFTER_UPDATE' as info,
    id,
    method_type,
    method_name,
    currency,
    network,
    address,
    paypal_email,
    bank_name,
    account_number,
    routing_number,
    min_amount,
    max_amount,
    is_active,
    created_at,
    updated_at
FROM deposit_methods
ORDER BY method_type, currency;
