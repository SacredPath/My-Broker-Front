-- Update BTC and USDT deposit addresses using correct column names

-- 1. Update BTC address to: bc1qedhgd4n37kvxq692te6rdxn50ygtrtg9fmm72n
UPDATE deposit_methods 
SET address = 'bc1qedhgd4n37kvxq692te6rdxn50ygtrtg9fmm72n',
    updated_at = NOW()
WHERE method_name = 'BTC Bitcoin' AND currency = 'BTC';

-- 2. Update USDT TRC20 address to: TSM63D4VdE2nev1PoMmqTr8ti3me9JYsJ4
UPDATE deposit_methods 
SET address = 'TSM63D4VdE2nev1PoMmqTr8ti3me9JYsJ4',
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
