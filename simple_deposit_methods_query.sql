-- Simple query to see all deposit methods without conditions

-- 1. Check if table exists and show ALL data
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'deposit_methods') THEN
        RAISE NOTICE '=== DEPOSIT_METHODS TABLE EXISTS ===';
        
        -- Show ALL records without any conditions
        RAISE NOTICE '=== ALL DEPOSIT METHODS ===';
        EXECUTE 'SELECT 
            id,
            method_name,
            method_type,
            currency,
            network,
            address,
            paypal_email,
            bank_name,
            account_number,
            routing_number,
            min_amount,
            max_amount,
            is_active,
            created_at,
            updated_at
        FROM deposit_methods 
        ORDER BY created_at DESC';
        
        -- Show count of all records
        RAISE NOTICE '=== TOTAL RECORD COUNT ===';
        EXECUTE 'SELECT COUNT(*) as total_records FROM deposit_methods';
        
    ELSE
        RAISE NOTICE '=== DEPOSIT_METHODS TABLE DOES NOT EXIST ===';
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error querying deposit_methods: %', SQLERRM;
END $$;

-- 2. Check for ANY deposit-related tables
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

-- 3. Check if there are any records in ANY table that might contain deposit info
DO $$
BEGIN
    RAISE NOTICE '=== CHECKING ALL TABLES FOR DEPOSIT DATA ===';
    
    -- Check deposit_addresses
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'deposit_addresses') THEN
        EXECUTE 'SELECT COUNT(*) as deposit_addresses_count FROM deposit_addresses';
    END IF;
    
    -- Check payment_methods
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'payment_methods') THEN
        EXECUTE 'SELECT COUNT(*) as payment_methods_count FROM payment_methods';
    END IF;
    
    -- Check deposit_methods
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'deposit_methods') THEN
        EXECUTE 'SELECT COUNT(*) as deposit_methods_count FROM deposit_methods';
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error checking counts: %', SQLERRM;
END $$;

-- 4. Show sample data from any table that has records
DO $$
BEGIN
    RAISE NOTICE '=== SAMPLE DATA FROM ANY TABLE ===';
    
    -- Try deposit_methods first
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'deposit_methods') THEN
        EXECUTE 'SELECT ''deposit_methods'' as table_name, COUNT(*) as count FROM deposit_methods';
    END IF;
    
    -- Try payment_methods
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'payment_methods') THEN
        EXECUTE 'SELECT ''payment_methods'' as table_name, COUNT(*) as count FROM payment_methods';
    END IF;
    
    -- Try deposit_addresses
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'deposit_addresses') THEN
        EXECUTE 'SELECT ''deposit_addresses'' as table_name, COUNT(*) as count FROM deposit_addresses';
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error getting sample data: %', SQLERRM;
END $$;

-- Final confirmation
DO $$
BEGIN
    RAISE NOTICE '=== SIMPLE DEPOSIT METHODS QUERY COMPLETE ===';
END $$;
