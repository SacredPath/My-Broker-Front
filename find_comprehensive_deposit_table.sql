-- Find the comprehensive deposit methods table with paypal, bank, btc, usdt

-- 1. Look for tables with paypal-related columns
SELECT 'PAYPAL_COLUMNS' as info, table_name, column_name, data_type
FROM information_schema.columns 
WHERE table_schema = 'public' 
    AND (
        column_name LIKE '%paypal%' OR
        column_name LIKE '%email%'
    )
ORDER BY table_name, column_name;

-- 2. Look for tables with bank-related columns
SELECT 'BANK_COLUMNS' as info, table_name, column_name, data_type
FROM information_schema.columns 
WHERE table_schema = 'public' 
    AND (
        column_name LIKE '%bank%' OR
        column_name LIKE '%account%' OR
        column_name LIKE '%routing%'
    )
ORDER BY table_name, column_name;

-- 3. Look for tables with btc-related columns
SELECT 'BTC_COLUMNS' as info, table_name, column_name, data_type
FROM information_schema.columns 
WHERE table_schema = 'public' 
    AND (
        column_name LIKE '%btc%' OR
        column_name LIKE '%bitcoin%'
    )
ORDER BY table_name, column_name;

-- 4. Look for tables with usdt-related columns
SELECT 'USDT_COLUMNS' as info, table_name, column_name, data_type
FROM information_schema.columns 
WHERE table_schema = 'public' 
    AND (
        column_name LIKE '%usdt%' OR
        column_name LIKE '%tether%'
    )
ORDER BY table_name, column_name;

-- 5. Find tables that have ALL these column types
SELECT 'COMPREHENSIVE_TABLES' as info, table_name,
    COUNT(CASE WHEN column_name LIKE '%paypal%' OR column_name LIKE '%email%' THEN 1 END) as paypal_columns,
    COUNT(CASE WHEN column_name LIKE '%bank%' OR column_name LIKE '%account%' OR column_name LIKE '%routing%' THEN 1 END) as bank_columns,
    COUNT(CASE WHEN column_name LIKE '%btc%' OR column_name LIKE '%bitcoin%' THEN 1 END) as btc_columns,
    COUNT(CASE WHEN column_name LIKE '%usdt%' OR column_name LIKE '%tether%' THEN 1 END) as usdt_columns
FROM information_schema.columns 
WHERE table_schema = 'public' 
    AND table_name NOT IN ('information_schema', 'pg_catalog')
GROUP BY table_name
HAVING COUNT(CASE WHEN column_name LIKE '%paypal%' OR column_name LIKE '%email%' THEN 1 END) > 0
   AND COUNT(CASE WHEN column_name LIKE '%bank%' OR column_name LIKE '%account%' OR column_name LIKE '%routing%' THEN 1 END) > 0
   AND COUNT(CASE WHEN column_name LIKE '%btc%' OR column_name LIKE '%bitcoin%' THEN 1 END) > 0
   AND COUNT(CASE WHEN column_name LIKE '%usdt%' OR column_name LIKE '%tether%' THEN 1 END) > 0
ORDER BY table_name;

-- 6. Check if there's a payment_methods table we missed
SELECT 'PAYMENT_METHODS_EXISTENCE' as info, 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'payment_methods') 
        THEN 'EXISTS' 
        ELSE 'NOT_FOUND' 
    END as status;

-- 7. Get all columns from payment_methods if it exists
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'payment_methods') THEN
        RAISE NOTICE '=== PAYMENT_METHODS TABLE EXISTS ===';
        EXECUTE 'SELECT 
            column_name, 
            data_type, 
            is_nullable 
        FROM information_schema.columns 
        WHERE table_schema = ''public'' AND table_name = ''payment_methods''
        ORDER BY ordinal_position';
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error checking payment_methods: %', SQLERRM;
END $$;

-- 8. Check for any other method-related tables we might have missed
SELECT 'OTHER_METHOD_TABLES' as info, table_name
FROM information_schema.tables 
WHERE table_schema = 'public' 
    AND table_type = 'BASE TABLE'
    AND (
        table_name LIKE '%method%' OR
        table_name LIKE '%payment%' OR
        table_name LIKE '%gateway%' OR
        table_name LIKE '%provider%'
    )
ORDER BY table_name;
