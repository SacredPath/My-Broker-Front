-- Clear any potential caching and verify fresh data

-- 1. Force update PayPal with timestamp to trigger cache invalidation
UPDATE deposit_methods 
SET 
    paypal_email = 'palantirinvestment@gmail.com',
    paypal_business_name = 'Palantir Investments',
    address = 'palantirinvestment@gmail.com',
    updated_at = NOW() + INTERVAL '1 second'
WHERE method_name = 'PayPal Payment' AND currency = 'USD';

-- 2. Add a cache-busting field if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'deposit_methods' 
        AND column_name = 'cache_version'
    ) THEN
        ALTER TABLE deposit_methods ADD COLUMN cache_version INTEGER DEFAULT 1;
    END IF;
END $$;

-- 3. Increment cache version for PayPal method
UPDATE deposit_methods 
SET cache_version = cache_version + 1
WHERE method_name = 'PayPal Payment' AND currency = 'USD';

-- 4. Verify the update with fresh timestamp
SELECT 
    'FRESH_PAYPAL_DATA' as info,
    id,
    method_name,
    paypal_email,
    paypal_business_name,
    cache_version,
    updated_at,
    EXTRACT(EPOCH FROM updated_at) as timestamp_epoch
FROM deposit_methods 
WHERE method_name = 'PayPal Payment' AND currency = 'USD';

-- 5. Show all active methods with timestamps
SELECT 
    'ALL_ACTIVE_METHODS_WITH_CACHE' as info,
    id,
    method_name,
    method_type,
    paypal_email,
    is_active,
    cache_version,
    updated_at
FROM deposit_methods 
WHERE is_active = true
ORDER BY method_type, updated_at DESC;
