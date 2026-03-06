-- Test Update and Verify deposit_methods table
-- This will test if updates actually persist

-- 1. First, see current state
DO $$
BEGIN
    RAISE NOTICE '=== CHECKING CURRENT STATE ===';
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'deposit_methods') THEN
        EXECUTE 'SELECT ''BEFORE UPDATE'' as status, * FROM deposit_methods WHERE method_type = ''crypto'' AND currency = ''BTC''';
    ELSE
        RAISE NOTICE 'deposit_methods table does not exist';
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error checking current state: %', SQLERRM;
END $$;

-- 2. Make a test update (only if table exists and has records)
DO $$
DECLARE
    _updated INTEGER;
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'deposit_methods') THEN
        -- Check if there are any records to update
        PERFORM 1 FROM deposit_methods WHERE method_type = 'crypto' AND currency = 'BTC' LIMIT 1;
        
        IF FOUND THEN
            RAISE NOTICE '=== MAKING TEST UPDATE ===';
            EXECUTE 'UPDATE deposit_methods 
                SET address = ''TEST_ADDRESS_'' || EXTRACT(EPOCH FROM NOW())::text,
                    updated_at = NOW()
                WHERE method_type = ''crypto'' AND currency = ''BTC''';
            
            GET DIAGNOSTICS _updated = ROW_COUNT;
            RAISE NOTICE 'Updated % records', _updated;
        ELSE
            RAISE NOTICE 'No records found to update - inserting test record';
            
            -- Insert a test record
            EXECUTE 'INSERT INTO deposit_methods (
                method_name, 
                method_type, 
                currency, 
                network, 
                address, 
                is_active
            ) VALUES (
                ''BTC Bitcoin'', 
                ''crypto'', 
                ''BTC'', 
                ''Bitcoin'', 
                ''TEST_ADDRESS_'' || EXTRACT(EPOCH FROM NOW())::text,
                true
            )';
            
            RAISE NOTICE 'Inserted test BTC record';
        END IF;
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error during test update: %', SQLERRM;
END $$;

-- 3. Check if update persisted
DO $$
BEGIN
    RAISE NOTICE '=== CHECKING AFTER UPDATE ===';
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'deposit_methods') THEN
        EXECUTE 'SELECT ''AFTER UPDATE'' as status, * FROM deposit_methods WHERE method_type = ''crypto'' AND currency = ''BTC''';
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error checking after update: %', SQLERRM;
END $$;

-- 4. Check if there are multiple records (duplicates)
DO $$
BEGIN
    RAISE NOTICE '=== CHECKING FOR DUPLICATES ===';
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'deposit_methods') THEN
        EXECUTE 'SELECT 
            method_type,
            currency,
            COUNT(*) as record_count,
            STRING_AGG(id::text, '', '') as all_ids
        FROM deposit_methods 
        WHERE method_type IN (''crypto'', ''paypal'', ''ach'')
        GROUP BY method_type, currency
        ORDER BY method_type, currency';
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error checking duplicates: %', SQLERRM;
END $$;

-- 5. Show all current deposit methods
DO $$
BEGIN
    RAISE NOTICE '=== ALL CURRENT DEPOSIT METHODS ===';
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'deposit_methods') THEN
        EXECUTE 'SELECT 
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
        ORDER BY method_type, currency, created_at DESC';
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error showing all methods: %', SQLERRM;
END $$;

-- 6. Check table structure to understand expected columns
DO $$
BEGIN
    RAISE NOTICE '=== TABLE STRUCTURE ===';
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'deposit_methods') THEN
        EXECUTE 'SELECT 
            column_name, 
            data_type, 
            is_nullable, 
            column_default
        FROM information_schema.columns 
        WHERE table_schema = ''public'' AND table_name = ''deposit_methods''
        ORDER BY ordinal_position';
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error checking structure: %', SQLERRM;
END $$;

-- Final confirmation
DO $$
BEGIN
    RAISE NOTICE '=== TEST UPDATE QUERY COMPLETE ===';
END $$;
