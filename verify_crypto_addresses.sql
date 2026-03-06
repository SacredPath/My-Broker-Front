-- Verify BTC and USDT addresses in CORRECT database: rfszagckgghcygkomybc.supabase.co

-- 1. Check current crypto deposit methods
SELECT 
    'CRYPTO_METHODS_CHECK' as info,
    id,
    method_name,
    method_type,
    currency,
    network,
    address,
    is_active,
    created_at,
    updated_at
FROM deposit_methods 
WHERE method_type = 'crypto'
ORDER BY currency, updated_at DESC;

-- 2. Verify specific BTC address
SELECT 
    'BTC_ADDRESS_VERIFICATION' as info,
    id,
    method_name,
    currency,
    network,
    address,
    is_active,
    CASE 
        WHEN address = 'bc1q86kns3mf9wrqsv05lpwkvnyg3gq0e5pa90yrth' THEN 'CORRECT_BTC_ADDRESS'
        ELSE 'INCORRECT_OR_MISSING_BTC_ADDRESS'
    END as verification_status,
    updated_at
FROM deposit_methods 
WHERE currency = 'BTC' AND method_type = 'crypto';

-- 3. Verify specific USDT address
SELECT 
    'USDT_ADDRESS_VERIFICATION' as info,
    id,
    method_name,
    currency,
    network,
    address,
    is_active,
    CASE 
        WHEN address = 'TTs6p5TT2a6kuyAzZX18pX4TZKfrJKstCy' THEN 'CORRECT_USDT_ADDRESS'
        ELSE 'INCORRECT_OR_MISSING_USDT_ADDRESS'
    END as verification_status,
    updated_at
FROM deposit_methods 
WHERE currency = 'USDT' AND method_type = 'crypto';

-- 4. Check for any duplicate or inactive crypto methods
SELECT 
    'DUPLICATE_CRYPTO_CHECK' as info,
    currency,
    COUNT(*) as total_methods,
    COUNT(CASE WHEN is_active = true THEN 1 END) as active_methods,
    COUNT(CASE WHEN is_active = false THEN 1 END) as inactive_methods
FROM deposit_methods 
WHERE method_type = 'crypto'
GROUP BY currency
ORDER BY currency;

-- 5. Show all active methods for complete picture
SELECT 
    'ALL_ACTIVE_METHODS_SUMMARY' as info,
    method_type,
    currency,
    COUNT(*) as count,
    MAX(updated_at) as last_updated
FROM deposit_methods 
WHERE is_active = true
GROUP BY method_type, currency
ORDER BY method_type, currency;
