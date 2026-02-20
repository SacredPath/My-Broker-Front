-- Update PayPal email in the CORRECT database: rfszagckgghcygkomybc.supabase.co

-- 1. First, check current PayPal method in correct database
SELECT 
    'CURRENT_PAYPAL_BEFORE_UPDATE' as info,
    id,
    method_name,
    method_type,
    currency,
    paypal_email,
    paypal_business_name,
    is_active,
    created_at,
    updated_at
FROM deposit_methods 
WHERE method_type = 'paypal' OR method_name LIKE '%PayPal%'
ORDER BY updated_at DESC;

-- 2. Update PayPal email to palantirinvestment@gmail.com
UPDATE deposit_methods 
SET 
    paypal_email = 'palantirinvestment@gmail.com',
    paypal_business_name = 'Palantir Investments',
    address = 'palantirinvestment@gmail.com',
    updated_at = NOW()
WHERE method_type = 'paypal' OR method_name LIKE '%PayPal%';

-- 3. Verify the update
SELECT 
    'UPDATED_PAYPAL_AFTER_UPDATE' as info,
    id,
    method_name,
    method_type,
    currency,
    paypal_email,
    paypal_business_name,
    is_active,
    updated_at
FROM deposit_methods 
WHERE method_type = 'paypal' OR method_name LIKE '%PayPal%'
ORDER BY updated_at DESC;

-- 4. Show all active deposit methods
SELECT 
    'ALL_ACTIVE_METHODS' as info,
    id,
    method_name,
    method_type,
    currency,
    paypal_email,
    paypal_business_name,
    is_active,
    updated_at
FROM deposit_methods 
WHERE is_active = true
ORDER BY method_type, updated_at DESC;

-- 5. Add cache version field if it doesn't exist (for future cache busting)
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

-- 6. Increment cache version for PayPal method
UPDATE deposit_methods 
SET cache_version = cache_version + 1
WHERE method_type = 'paypal' OR method_name LIKE '%PayPal%';

-- 7. Final verification with cache version
SELECT 
    'FINAL_VERIFICATION' as info,
    id,
    method_name,
    method_type,
    paypal_email,
    paypal_business_name,
    cache_version,
    updated_at
FROM deposit_methods 
WHERE method_type = 'paypal' OR method_name LIKE '%PayPal%'
ORDER BY updated_at DESC;
