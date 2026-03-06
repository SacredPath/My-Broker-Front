-- Update BTC deposit address to: bc1qedhgd4n37kvxq692te6rdxn50ygtrtg9fmm72n
-- Fixed version - checking actual enum values first

-- First, check what currency enum values are available
SELECT 
    'CURRENCY_ENUM_VALUES' as info,
    enumlabel
FROM pg_enum 
JOIN pg_type ON pg_enum.enumtypid = pg_type.oid
WHERE pg_type.typname = 'currency_code'
ORDER BY enumlabel;

-- Check table structures and find which tables have address columns
SELECT 
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name IN ('deposits', 'deposit_addresses', 'wallet_addresses', 'payment_methods', 'user_wallets')
    AND (column_name ILIKE '%address%' OR column_name ILIKE '%btc%' OR column_name ILIKE '%bitcoin%')
ORDER BY table_name, column_name;

-- Check if there are any existing addresses (using correct currency values)
SELECT 
    'CURRENT_ADDRESSES' as info,
    table_name,
    currency,
    address,
    created_at
FROM (
    SELECT 'deposits' as table_name, currency, address, created_at FROM deposits WHERE address IS NOT NULL LIMIT 5
    UNION ALL
    SELECT 'deposit_addresses' as table_name, currency, address, created_at FROM deposit_addresses WHERE address IS NOT NULL LIMIT 5
    UNION ALL  
    SELECT 'wallet_addresses' as table_name, currency, address, created_at FROM wallet_addresses WHERE address IS NOT NULL LIMIT 5
    UNION ALL
    SELECT 'payment_methods' as table_name, currency, address, created_at FROM payment_methods WHERE address IS NOT NULL LIMIT 5
    UNION ALL
    SELECT 'user_wallets' as table_name, currency, address, created_at FROM user_wallets WHERE address IS NOT NULL LIMIT 5
) as all_addresses
WHERE address IS NOT NULL;

-- Update statements - use correct currency value after checking enum above
-- Replace 'CORRECT_CURRENCY_CODE' with the actual enum value (e.g., 'bitcoin', 'btc', etc.)

-- Option 1: Update in deposits table
-- UPDATE deposits 
-- SET address = 'bc1qedhgd4n37kvxq692te6rdxn50ygtrtg9fmm72n'
-- WHERE currency = 'CORRECT_CURRENCY_CODE' AND address IS NOT NULL;

-- Option 2: Update in deposit_addresses table  
-- UPDATE deposit_addresses
-- SET address = 'bc1qedhgd4n37kvxq692te6rdxn50ygtrtg9fmm72n'
-- WHERE currency = 'CORRECT_CURRENCY_CODE' AND address IS NOT NULL;

-- Option 3: Update in wallet_addresses table
-- UPDATE wallet_addresses
-- SET address = 'bc1qedhgd4n37kvxq692te6rdxn50ygtrtg9fmm72n'
-- WHERE currency = 'CORRECT_CURRENCY_CODE' AND address IS NOT NULL;

-- Option 4: Update in payment_methods table
-- UPDATE payment_methods
-- SET address = 'bc1qedhgd4n37kvxq692te6rdxn50ygtrtg9fmm72n'
-- WHERE currency = 'CORRECT_CURRENCY_CODE' AND address IS NOT NULL;

-- Option 5: Update in user_wallets table
-- UPDATE user_wallets
-- SET address = 'bc1qedhgd4n37kvxq692te6rdxn50ygtrtg9fmm72n'
-- WHERE currency = 'CORRECT_CURRENCY_CODE' AND address IS NOT NULL;

-- Alternative: Update by address pattern if currency enum is the issue
-- UPDATE deposits 
-- SET address = 'bc1qedhgd4n37kvxq692te6rdxn50ygtrtg9fmm72n'
-- WHERE address IS NOT NULL AND address LIKE 'bc1%';

-- Verify the update
SELECT 
    'UPDATED_ADDRESSES' as info,
    table_name,
    currency,
    address,
    created_at
FROM (
    SELECT 'deposits' as table_name, currency, address, created_at FROM deposits WHERE address = 'bc1qedhgd4n37kvxq692te6rdxn50ygtrtg9fmm72n'
    UNION ALL
    SELECT 'deposit_addresses' as table_name, currency, address, created_at FROM deposit_addresses WHERE address = 'bc1qedhgd4n37kvxq692te6rdxn50ygtrtg9fmm72n'
    UNION ALL  
    SELECT 'wallet_addresses' as table_name, currency, address, created_at FROM wallet_addresses WHERE address = 'bc1qedhgd4n37kvxq692te6rdxn50ygtrtg9fmm72n'
    UNION ALL
    SELECT 'payment_methods' as table_name, currency, address, created_at FROM payment_methods WHERE address = 'bc1qedhgd4n37kvxq692te6rdxn50ygtrtg9fmm72n'
    UNION ALL
    SELECT 'user_wallets' as table_name, currency, address, created_at FROM user_wallets WHERE address = 'bc1qedhgd4n37kvxq692te6rdxn50ygtrtg9fmm72n'
) as updated_addresses;
