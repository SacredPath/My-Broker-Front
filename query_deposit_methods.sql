-- Query deposit_methods table structure and current data

-- 1. Check if table exists and show structure
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'deposit_methods') THEN
        RAISE NOTICE '=== DEPOSIT_METHODS TABLE EXISTS ===';
        
        -- Show table structure
        RAISE NOTICE '=== TABLE STRUCTURE ===';
        EXECUTE 'SELECT 
            column_name, 
            data_type, 
            is_nullable, 
            column_default
        FROM information_schema.columns 
        WHERE table_schema = ''public'' AND table_name = ''deposit_methods''
        ORDER BY ordinal_position';
        
        -- Show current data
        RAISE NOTICE '=== CURRENT DATA ===';
        EXECUTE 'SELECT 
            method_name, 
            currency, 
            network, 
            address, 
            is_active, 
            created_at, 
            updated_at 
        FROM deposit_methods 
        ORDER BY method_type, currency';
        
    ELSE
        RAISE NOTICE '=== DEPOSIT_METHODS TABLE DOES NOT EXIST ===';
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error querying deposit_methods: %', SQLERRM;
END $$;

-- 2. Check for other related tables that might contain deposit addresses
DO $$
BEGIN
    RAISE NOTICE '=== CHECKING OTHER DEPOSIT TABLES ===';
    
    -- Check deposit_addresses table
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'deposit_addresses') THEN
        RAISE NOTICE 'deposit_addresses table exists';
        EXECUTE 'SELECT 
            id, 
            btc_address, 
            usdt_address, 
            updated_at 
        FROM deposit_addresses 
        LIMIT 3';
    ELSE
        RAISE NOTICE 'deposit_addresses table does not exist';
    END IF;
    
    -- Check payment_methods table
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'payment_methods') THEN
        RAISE NOTICE 'payment_methods table exists';
        EXECUTE 'SELECT 
            method_name, 
            currency, 
            address, 
            network, 
            is_active, 
            created_at, 
            updated_at 
        FROM payment_methods 
        WHERE currency IN (''BTC'', ''USDT'')
        ORDER BY currency';
    ELSE
        RAISE NOTICE 'payment_methods table does not exist';
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error checking other tables: %', SQLERRM;
END $$;

-- 3. Show all tables that might contain deposit information
DO $$
BEGIN
    RAISE NOTICE '=== ALL DEPOSIT-RELATED TABLES ===';
    
    EXECUTE 'SELECT 
        table_name, 
        table_type 
    FROM information_schema.tables 
    WHERE table_schema = ''public'' 
        AND (
            table_name LIKE ''%deposit%'' OR 
            table_name LIKE ''%payment%'' OR
            table_name LIKE ''%method%''
        )
    ORDER BY table_name';
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error listing tables: %', SQLERRM;
END $$;

-- Final confirmation
DO $$
BEGIN
    RAISE NOTICE '=== DEPOSIT METHODS QUERY COMPLETE ===';
END $$;
