-- Query deposit_methods table with correct column names

-- 1. Show table structure first to see actual column names
SELECT 
    'DEPOSIT_METHODS_COLUMNS' as info,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public' AND table_name = 'deposit_methods'
ORDER BY ordinal_position;

-- 2. Show sample data to understand structure
SELECT 
    'SAMPLE_DATA' as info,
    *
FROM deposit_methods
LIMIT 3;

-- 3. Show all current deposit methods (using correct column names)
-- After seeing the structure above, replace 'method' with actual column name
SELECT 
    'ALL_DEPOSIT_METHODS' as info,
    *
FROM deposit_methods
ORDER BY created_at DESC;

-- 4. Look for PayPal methods (adjust column names after seeing structure)
SELECT 
    'PAYPAL_METHODS' as info,
    *
FROM deposit_methods
WHERE 
    -- Replace 'method' with actual column name from structure above
    (method ILIKE '%paypal%' OR type ILIKE '%paypal%' OR name ILIKE '%paypal%')
ORDER BY created_at DESC;

-- 5. Look for bank methods (adjust column names after seeing structure)
SELECT 
    'BANK_METHODS' as info,
    *
FROM deposit_methods
WHERE 
    -- Replace 'method' with actual column name from structure above
    (method ILIKE '%bank%' OR type ILIKE '%bank%' OR name ILIKE '%bank%')
ORDER BY created_at DESC;

-- 6. Look for BTC methods (adjust column names after seeing structure)
SELECT 
    'BTC_METHODS' as info,
    *
FROM deposit_methods
WHERE 
    -- Replace 'method' with actual column name from structure above
    (method ILIKE '%btc%' OR type ILIKE '%btc%' OR name ILIKE '%btc%' OR currency ILIKE '%btc%')
    OR (address ILIKE 'bc1%' OR address ILIKE '1%' OR address ILIKE '3%')
ORDER BY created_at DESC;

-- 7. Look for USDT methods (adjust column names after seeing structure)
SELECT 
    'USDT_METHODS' as info,
    *
FROM deposit_methods
WHERE 
    -- Replace 'method' with actual column name from structure above
    (method ILIKE '%usdt%' OR type ILIKE '%usdt%' OR name ILIKE '%usdt%' OR currency ILIKE '%usdt%')
    OR (method ILIKE '%tether%' OR type ILIKE '%tether%' OR name ILIKE '%tether%')
ORDER BY created_at DESC;

-- 8. Count by payment type (adjust column names after seeing structure)
SELECT 
    'METHODS_COUNT_BY_TYPE' as info,
    method,  -- Replace with actual column name
    currency,
    COUNT(*) as count,
    MIN(created_at) as first_added,
    MAX(created_at) as last_added
FROM deposit_methods
GROUP BY method, currency  -- Replace with actual column name
ORDER BY count DESC;

-- 9. Show unique payment types (adjust column names after seeing structure)
SELECT 
    'UNIQUE_PAYMENT_TYPES' as info,
    method as payment_method,  -- Replace with actual column name
    type,
    currency
FROM deposit_methods
GROUP BY method, type, currency  -- Replace with actual column name
ORDER BY payment_method;
