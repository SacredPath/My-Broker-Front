-- Force update PayPal email to palantirinvestment@gmail.com and business name

-- 1. First, check current PayPal method
SELECT 
    'CURRENT_PAYPAL_BEFORE_UPDATE' as info,
    id,
    method_name,
    currency,
    paypal_email,
    paypal_business_name,
    min_amount,
    max_amount,
    is_active,
    updated_at
FROM deposit_methods 
WHERE method_name = 'PayPal Payment' AND currency = 'USD';

-- 2. Force update with exact values
UPDATE deposit_methods 
SET 
    paypal_email = 'palantirinvestment@gmail.com',
    paypal_business_name = 'Palantir Investments',
    address = 'palantirinvestment@gmail.com', -- Keep address consistent
    updated_at = NOW()
WHERE method_name = 'PayPal Payment' AND currency = 'USD';

-- 3. Verify the update
SELECT 
    'UPDATED_PAYPAL_AFTER_UPDATE' as info,
    id,
    method_name,
    currency,
    paypal_email,
    paypal_business_name,
    min_amount,
    max_amount,
    is_active,
    updated_at
FROM deposit_methods 
WHERE method_name = 'PayPal Payment' AND currency = 'USD';

-- 4. Show all PayPal methods to ensure no duplicates
SELECT 
    'ALL_PAYPAL_METHODS' as info,
    id,
    method_name,
    currency,
    paypal_email,
    paypal_business_name,
    is_active,
    created_at,
    updated_at
FROM deposit_methods 
WHERE method_type = 'paypal'
ORDER BY updated_at DESC;
