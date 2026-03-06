-- Fix signal_usdt_purchases table structure and update USDT address

-- 1. Check if signal_usdt_purchases table exists and show its structure
SELECT 
    'SIGNAL_USDT_PURCHASES_STRUCTURE' as info,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public'
    AND table_name = 'signal_usdt_purchases'
ORDER BY ordinal_position;

-- 2. Add usdt_address column if it doesn't exist
DO $$
BEGIN
    -- Check if column exists before adding
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'signal_usdt_purchases' 
        AND column_name = 'usdt_address'
    ) THEN
        RAISE NOTICE 'Adding usdt_address column to signal_usdt_purchases table';
        ALTER TABLE signal_usdt_purchases 
        ADD COLUMN usdt_address VARCHAR(128);
    ELSE
        RAISE NOTICE 'usdt_address column already exists in signal_usdt_purchases';
    END IF;
END $$;

-- 3. Update USDT address in signal_usdt_purchases
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'signal_usdt_purchases') THEN
        -- Update if usdt_address column exists
        IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'signal_usdt_purchases' AND column_name = 'usdt_address') THEN
            RAISE NOTICE '=== UPDATING USDT ADDRESS IN SIGNAL_USDT_PURCHASES ===';
            UPDATE signal_usdt_purchases 
            SET usdt_address = 'TSM63D4VdE2nev1PoMmqTr8ti3me9JYsJ4' 
            WHERE usdt_address IS NULL OR usdt_address = '';
            
            RAISE NOTICE 'Updated % records with new USDT address', 
                (SELECT COUNT(*) FROM signal_usdt_purchases WHERE usdt_address = 'TSM63D4VdE2nev1PoMmqTr8ti3me9JYsJ4');
        ELSE
            RAISE NOTICE 'usdt_address column not found in signal_usdt_purchases table';
        END IF;
    ELSE
        RAISE NOTICE 'signal_usdt_purchases table does not exist';
    END IF;
END $$;

-- 4. Show updated table structure
SELECT 
    'UPDATED_SIGNAL_USDT_PURCHASES_STRUCTURE' as info,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public'
    AND table_name = 'signal_usdt_purchases'
ORDER BY ordinal_position;

-- 5. Show sample data to verify the update
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'signal_usdt_purchases') THEN
        RAISE NOTICE '=== SAMPLE DATA FROM SIGNAL_USDT_PURCHASES ===';
        EXECUTE 'SELECT id, user_id, signal_id, amount, usdt_address, status, created_at FROM signal_usdt_purchases LIMIT 5';
    END IF;
END $$;
