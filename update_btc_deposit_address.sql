-- Update BTC deposit address to: bc1qedhgd4n37kvxq692te6rdxn50ygtrtg9fmm72n

-- First, check current deposit addresses to see what table/column to update
SELECT 
    table_name,
    column_name,
    data_type
FROM information_schema.columns 
WHERE table_name IN ('deposits', 'deposit_addresses', 'wallet_addresses', 'payment_methods', 'user_wallets')
    AND (column_name ILIKE '%address%' OR column_name ILIKE '%btc%' OR column_name ILIKE '%bitcoin%')
ORDER BY table_name, column_name;

-- Check if there are existing BTC deposit addresses
SELECT 
    'CURRENT_BTC_ADDRESSES' as info,
    table_name,
    *
FROM (
    SELECT 'deposits' as table_name, id, user_id, currency, address, created_at FROM deposits WHERE currency = 'BTC' AND address IS NOT NULL
    UNION ALL
    SELECT 'deposit_addresses' as table_name, id, user_id, currency, address, created_at FROM deposit_addresses WHERE currency = 'BTC' AND address IS NOT NULL
    UNION ALL  
    SELECT 'wallet_addresses' as table_name, id, user_id, currency, address, created_at FROM wallet_addresses WHERE currency = 'BTC' AND address IS NOT NULL
    UNION ALL
    SELECT 'payment_methods' as table_name, id, user_id, currency, address, created_at FROM payment_methods WHERE currency = 'BTC' AND address IS NOT NULL
    UNION ALL
    SELECT 'user_wallets' as table_name, id, user_id, currency, address, created_at FROM user_wallets WHERE currency = 'BTC' AND address IS NOT NULL
) as all_addresses
LIMIT 10;

-- Update BTC deposit address (uncomment the correct table after checking above results)

-- Option 1: Update in deposits table
-- UPDATE deposits 
-- SET address = 'bc1qedhgd4n37kvxq692te6rdxn50ygtrtg9fmm72n'
-- WHERE currency = 'BTC' AND address IS NOT NULL;

-- Option 2: Update in deposit_addresses table  
-- UPDATE deposit_addresses
-- SET address = 'bc1qedhgd4n37kvxq692te6rdxn50ygtrtg9fmm72n'
-- WHERE currency = 'BTC' AND address IS NOT NULL;

-- Option 3: Update in wallet_addresses table
-- UPDATE wallet_addresses
-- SET address = 'bc1qedhgd4n37kvxq692te6rdxn50ygtrtg9fmm72n'
-- WHERE currency = 'BTC' AND address IS NOT NULL;

-- Option 4: Update in payment_methods table
-- UPDATE payment_methods
-- SET address = 'bc1qedhgd4n37kvxq692te6rdxn50ygtrtg9fmm72n'
-- WHERE currency = 'BTC' AND address IS NOT NULL;

-- Option 5: Update in user_wallets table
-- UPDATE user_wallets
-- SET address = 'bc1qedhgd4n37kvxq692te6rdxn50ygtrtg9fmm72n'
-- WHERE currency = 'BTC' AND address IS NOT NULL;

-- Verify the update
SELECT 
    'UPDATED_BTC_ADDRESSES' as info,
    *
FROM (
    SELECT 'deposits' as table_name, id, user_id, currency, address, created_at FROM deposits WHERE currency = 'BTC' AND address = 'bc1qedhgd4n37kvxq692te6rdxn50ygtrtg9fmm72n'
    UNION ALL
    SELECT 'deposit_addresses' as table_name, id, user_id, currency, address, created_at FROM deposit_addresses WHERE currency = 'BTC' AND address = 'bc1qedhgd4n37kvxq692te6rdxn50ygtrtg9fmm72n'
    UNION ALL  
    SELECT 'wallet_addresses' as table_name, id, user_id, currency, address, created_at FROM wallet_addresses WHERE currency = 'BTC' AND address = 'bc1qedhgd4n37kvxq692te6rdxn50ygtrtg9fmm72n'
    UNION ALL
    SELECT 'payment_methods' as table_name, id, user_id, currency, address, created_at FROM payment_methods WHERE currency = 'BTC' AND address = 'bc1qedhgd4n37kvxq692te6rdxn50ygtrtg9fmm72n'
    UNION ALL
    SELECT 'user_wallets' as table_name, id, user_id, currency, address, created_at FROM user_wallets WHERE currency = 'BTC' AND address = 'bc1qedhgd4n37kvxq692te6rdxn50ygtrtg9fmm72n'
) as updated_addresses;
