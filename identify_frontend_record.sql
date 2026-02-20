-- Identify which specific deposit_methods record frontend is showing

-- 1. Check all current records with details
SELECT 'ALL_CURRENT_DEPOSIT_METHODS' as info, 
    id,
    method_type,
    method_name, 
    currency, 
    network, 
    address, 
    is_active, 
    created_at, 
    updated_at,
    CASE 
        WHEN address LIKE 'TEST_ADDRESS_%' THEN 'TEST_RECORD'
        WHEN address LIKE 'bc1q86kns3mf9wrqsv05lpwkvnyg3gq0e5pa90yrth' THEN 'NEW_BTC'
        WHEN address LIKE 'TTs6p5TT2a6kuyAzZX18pX4TZKfrJKstCy' THEN 'NEW_USDT'
        WHEN address LIKE 'TSM63D4VdE2nev1PoMmqTr8ti3me9JYsJ4' THEN 'OLD_USDT'
        ELSE 'UNKNOWN'
    END as address_type,
    -- Calculate age to identify newest
    EXTRACT(EPOCH FROM NOW()) - EXTRACT(EPOCH FROM created_at) as age_seconds
FROM deposit_methods 
WHERE is_active = true 
ORDER BY created_at DESC;

-- 2. Find the exact record that frontend might be showing
SELECT 'FRONTEND_RECORD_DETAILS' as info, 
    id,
    method_type,
    method_name, 
    currency, 
    address, 
    is_active, 
    created_at, 
    updated_at,
    CASE 
        WHEN address LIKE 'TEST_ADDRESS_%' THEN 'TEST_RECORD'
        WHEN address LIKE 'bc1q86kns3mf9wrqsv05lpwkvnyg3gq0e5pa90yrth' THEN 'NEW_BTC'
        WHEN address LIKE 'TTs6p5TT2a6kuyAzZX18pX4TZKfrJKstCy' THEN 'NEW_USDT'
        WHEN address LIKE 'TSM63D4VdE2nev1PoMmqTr8ti3me9JYsJ4' THEN 'OLD_USDT'
        ELSE 'UNKNOWN'
    END as address_type
FROM deposit_methods 
WHERE is_active = true 
ORDER BY created_at DESC
LIMIT 5;

-- 3. Check if there are multiple active records for same currency
SELECT 'ACTIVE_RECORDS_BY_CURRENCY' as info, 
    currency,
    COUNT(*) as active_count,
    STRING_AGG(id::text, ', ' ORDER BY created_at DESC) as all_ids
FROM deposit_methods 
WHERE is_active = true 
GROUP BY currency
ORDER BY currency;

-- 4. Identify the newest record for each currency
SELECT 'NEWEST_RECORDS' as info, 
    currency,
    id,
    method_name,
    address,
    created_at
FROM (
    SELECT 
        currency, 
        id, 
        method_name, 
        address, 
        created_at,
        ROW_NUMBER() OVER (PARTITION BY currency ORDER BY created_at DESC) as rn
    FROM deposit_methods 
    WHERE is_active = true
) ranked
WHERE rn = 1;
