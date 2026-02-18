-- Query deposit_methods table for current deposit methods

-- 1. Show table structure first
SELECT 
    'DEPOSIT_METHODS_COLUMNS' as info,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public' AND table_name = 'deposit_methods'
ORDER BY ordinal_position;

-- 2. Show all current deposit methods
SELECT 
    'ALL_DEPOSIT_METHODS' as info,
    *
FROM deposit_methods
ORDER BY created_at DESC;

-- 3. Count methods by type/currency
SELECT 
    'METHODS_COUNT_BY_TYPE' as info,
    method,
    currency,
    COUNT(*) as count,
    MIN(created_at) as first_added,
    MAX(created_at) as last_added
FROM deposit_methods
GROUP BY method, currency
ORDER BY count DESC;

-- 4. Look for specific payment types
SELECT 
    'PAYPAL_METHODS' as info,
    *
FROM deposit_methods
WHERE method ILIKE '%paypal%' OR type ILIKE '%paypal%' OR name ILIKE '%paypal%'
ORDER BY created_at DESC;

SELECT 
    'BANK_METHODS' as info,
    *
FROM deposit_methods
WHERE method ILIKE '%bank%' OR type ILIKE '%bank%' OR name ILIKE '%bank%'
ORDER BY created_at DESC;

SELECT 
    'BTC_METHODS' as info,
    *
FROM deposit_methods
WHERE 
    (method ILIKE '%btc%' OR type ILIKE '%btc%' OR name ILIKE '%btc%' OR currency ILIKE '%btc%')
    OR (address ILIKE 'bc1%' OR address ILIKE '1%' OR address ILIKE '3%')
ORDER BY created_at DESC;

SELECT 
    'USDT_METHODS' as info,
    *
FROM deposit_methods
WHERE 
    (method ILIKE '%usdt%' OR type ILIKE '%usdt%' OR name ILIKE '%usdt%' OR currency ILIKE '%usdt%')
    OR (method ILIKE '%tether%' OR type ILIKE '%tether%' OR name ILIKE '%tether%')
ORDER BY created_at DESC;

-- 5. Show unique payment types available
SELECT 
    'UNIQUE_PAYMENT_TYPES' as info,
    method as payment_method,
    type,
    currency
FROM deposit_methods
GROUP BY method, type, currency
ORDER BY payment_method;
