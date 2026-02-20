-- Update USDT address in signal details purchase tables

-- 1. Find all tables related to signals and purchases
SELECT 
    'SIGNAL_PURCHASE_TABLES' as info,
    table_name,
    table_type
FROM information_schema.tables 
WHERE table_schema = 'public'
    AND table_type = 'BASE TABLE'
    AND (
        table_name ILIKE '%signal%' 
        OR table_name ILIKE '%purchase%' 
        OR table_name ILIKE '%subscription%'
        OR table_name ILIKE '%payment%'
        OR table_name ILIKE '%transaction%'
    )
ORDER BY table_name;

-- 2. Check columns in signal/purchase tables for address fields
SELECT 
    'SIGNAL_TABLE_ADDRESS_COLUMNS' as info,
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_schema = 'public'
    AND table_name IN (
        SELECT table_name FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_type = 'BASE TABLE'
        AND (
            table_name ILIKE '%signal%' 
            OR table_name ILIKE '%purchase%' 
            OR table_name ILIKE '%subscription%'
        )
    )
    AND (column_name ILIKE '%address%' OR column_name ILIKE '%usdt%' OR column_name ILIKE '%crypto%')
ORDER BY table_name, column_name;

-- 3. Show sample data from signal/purchase tables to understand structure
DO $$
BEGIN
    -- Check signals table
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'signals') THEN
        RAISE NOTICE '=== SIGNALS TABLE ===';
        EXECUTE 'SELECT * FROM signals LIMIT 3';
    END IF;
    
    -- Check signal_usdt_purchases table
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'signal_usdt_purchases') THEN
        RAISE NOTICE '=== SIGNAL_USDT_PURCHASES TABLE ===';
        EXECUTE 'SELECT * FROM signal_usdt_purchases LIMIT 3';
    END IF;
    
    -- Check purchases table
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'purchases') THEN
        RAISE NOTICE '=== PURCHASES TABLE ===';
        EXECUTE 'SELECT * FROM purchases LIMIT 3';
    END IF;
    
    -- Check subscriptions table
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'subscriptions') THEN
        RAISE NOTICE '=== SUBSCRIPTIONS TABLE ===';
        EXECUTE 'SELECT * FROM subscriptions LIMIT 3';
    END IF;
END $$;

-- 4. Look for existing USDT addresses in signal/purchase tables
DO $$
BEGIN
    -- Update USDT address in signal_usdt_purchases if table exists
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'signal_usdt_purchases') THEN
        RAISE NOTICE '=== UPDATING USDT IN SIGNAL_USDT_PURCHASES ===';
        EXECUTE 'UPDATE signal_usdt_purchases SET usdt_address = ''TSM63D4VdE2nev1PoMmqTr8ti3me9JYsJ4'' WHERE usdt_address IS NOT NULL';
    END IF;
    
    -- Update USDT address in purchases if table exists
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'purchases') THEN
        RAISE NOTICE '=== UPDATING USDT IN PURCHASES ===';
        EXECUTE 'UPDATE purchases SET usdt_address = ''TSM63D4VdE2nev1PoMmqTr8ti3me9JYsJ4'' WHERE usdt_address IS NOT NULL';
    END IF;
    
    -- Update USDT address in subscriptions if table exists
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'subscriptions') THEN
        RAISE NOTICE '=== UPDATING USDT IN SUBSCRIPTIONS ===';
        EXECUTE 'UPDATE subscriptions SET usdt_address = ''TSM63D4VdE2nev1PoMmqTr8ti3me9JYsJ4'' WHERE usdt_address IS NOT NULL';
    END IF;
END $$;

-- 5. Alternative: Update by address pattern (if column name is different)
DO $$
BEGIN
    -- Update USDT addresses that match TRC20 pattern
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'signal_usdt_purchases') THEN
        RAISE NOTICE '=== UPDATING TRC20 ADDRESSES IN SIGNAL_USDT_PURCHASES ===';
        EXECUTE 'UPDATE signal_usdt_purchases SET address = ''TSM63D4VdE2nev1PoMmqTr8ti3me9JYsJ4'' WHERE address LIKE ''T%'' AND LENGTH(address) = 34';
    END IF;
END $$;
