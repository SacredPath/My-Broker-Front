-- Update PayPal email address to OPTIONSHAREINVEST@GMAIL.COM

-- 1. Update PayPal email address
UPDATE deposit_methods 
SET paypal_email = 'OPTIONSHAREINVEST@GMAIL.COM',
    updated_at = NOW()
WHERE method_name = 'PayPal Payment' AND currency = 'USD';

-- 2. Verify the PayPal update
SELECT 
    'UPDATED_PAYPAL_ADDRESS' as info,
    id,
    method_name,
    currency,
    paypal_email,
    paypal_business_name,
    updated_at
FROM deposit_methods 
WHERE method_name = 'PayPal Payment' AND currency = 'USD';

-- 3. Show all current deposit methods after PayPal update
SELECT 
    'ALL_DEPOSIT_METHODS_AFTER_PAYPAL_UPDATE' as info,
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
