-- Ensure PayPal method exists with correct email address

-- 1. Check if PayPal method exists
SELECT 
    'CHECK_PAYPAL_METHOD' as info,
    id,
    method_name,
    currency,
    paypal_email,
    is_active
FROM deposit_methods 
WHERE method_name = 'PayPal Payment' AND currency = 'USD';

-- 2. Insert PayPal method if it doesn't exist
INSERT INTO deposit_methods (
    id,
    method_type,
    method_name,
    currency,
    network,
    address,
    paypal_email,
    paypal_business_name,
    bank_name,
    account_number,
    routing_number,
    min_amount,
    max_amount,
    is_active,
    created_at,
    updated_at
) 
SELECT 
    gen_random_uuid(),
    'paypal',
    'PayPal Payment',
    'USD',
    null,
    'palantirinvestment@gmail.com', -- Use email as address for PayPal
    'palantirinvestment@gmail.com',
    'Palantir Investments',
    null,
    null,
    null,
    10.00,
    50000.00,
    true,
    NOW(),
    NOW()
WHERE NOT EXISTS (
    SELECT 1 FROM deposit_methods 
    WHERE method_name = 'PayPal Payment' AND currency = 'USD'
);

-- 3. Update PayPal email if method exists
UPDATE deposit_methods 
SET paypal_email = 'palantirinvestment@gmail.com',
    paypal_business_name = 'Palantir Investments',
    updated_at = NOW()
WHERE method_name = 'PayPal Payment' AND currency = 'USD';

-- 4. Verify final PayPal method
SELECT 
    'FINAL_PAYPAL_METHOD' as info,
    id,
    method_name,
    currency,
    paypal_email,
    paypal_business_name,
    min_amount,
    max_amount,
    is_active,
    created_at,
    updated_at
FROM deposit_methods 
WHERE method_name = 'PayPal Payment' AND currency = 'USD';

-- 5. Show all deposit methods
SELECT 
    'ALL_DEPOSIT_METHODS_FINAL' as info,
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
