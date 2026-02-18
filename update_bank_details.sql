-- Update bank details to BANK OF AMERICA and account name OPTIONSHARES

-- 1. Update bank name and account name
UPDATE deposit_methods 
SET bank_name = 'BANK OF AMERICA',
    updated_at = NOW()
WHERE method_name = 'ACH Bank Transfer' AND currency = 'USD';

-- Note: account_number field shows masked format (****1234), 
-- if you need to update the actual account number, you'll need the full unmasked value
-- The account name might be in a different field or table

-- 2. Verify the bank update
SELECT 
    'UPDATED_BANK_DETAILS' as info,
    id,
    method_name,
    currency,
    bank_name,
    account_number,
    routing_number,
    updated_at
FROM deposit_methods 
WHERE method_name = 'ACH Bank Transfer' AND currency = 'USD';

-- 3. Show all current deposit methods after bank update
SELECT 
    'ALL_DEPOSIT_METHODS_AFTER_BANK_UPDATE' as info,
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

-- 4. Check if there are other bank-related fields or tables
SELECT 
    'BANK_RELATED_COLUMNS' as info,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_schema = 'public' 
    AND (column_name ILIKE '%account%' OR column_name ILIKE '%holder%' OR column_name ILIKE '%name%')
    AND table_name IN ('deposit_methods', 'user_profiles', 'users', 'bank_accounts')
ORDER BY table_name, column_name;
