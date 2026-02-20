-- Find where actual deposit data is stored

-- 1. Check ALL tables for ANY deposit-related data
DO $$
BEGIN
    RAISE NOTICE '=== SEARCHING FOR DEPOSIT DATA IN ALL TABLES ===';
    
    -- Get all table names
    EXECUTE 'SELECT 
        table_name,
        (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = t.table_name AND table_schema = ''public'') as column_count
    FROM information_schema.tables t
    WHERE table_schema = ''public'' AND table_type = ''BASE TABLE''
    ORDER BY table_name';
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error listing tables: %', SQLERRM;
END $$;

-- 2. Check for tables that might contain BTC/USDT addresses
DO $$
BEGIN
    RAISE NOTICE '=== SEARCHING FOR BTC/USDT ADDRESS COLUMNS ===';
    
    -- Look for columns that might contain addresses
    EXECUTE 'SELECT 
        table_name,
        column_name,
        data_type
    FROM information_schema.columns 
    WHERE table_schema = ''public'' 
        AND (
            column_name LIKE ''%address%'' OR
            column_name LIKE ''%btc%'' OR
            column_name LIKE ''%usdt%'' OR
            column_name LIKE ''%crypto%'' OR
            column_name LIKE ''%deposit%''
        )
    ORDER BY table_name, column_name';
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error searching address columns: %', SQLERRM;
END $$;

-- 3. Check common table names that might contain deposit data
DO $$
BEGIN
    RAISE NOTICE '=== CHECKING COMMON DEPOSIT TABLES ===';
    
    -- Check for common deposit table names
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'payment_methods') THEN
        RAISE NOTICE 'payment_methods table exists';
        EXECUTE 'SELECT COUNT(*) as record_count FROM payment_methods';
        EXECUTE 'SELECT * FROM payment_methods LIMIT 3';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'deposit_addresses') THEN
        RAISE NOTICE 'deposit_addresses table exists';
        EXECUTE 'SELECT COUNT(*) as record_count FROM deposit_addresses';
        EXECUTE 'SELECT * FROM deposit_addresses LIMIT 3';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'deposits') THEN
        RAISE NOTICE 'deposits table exists';
        EXECUTE 'SELECT COUNT(*) as record_count FROM deposits';
        EXECUTE 'SELECT * FROM deposits LIMIT 3';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'payments') THEN
        RAISE NOTICE 'payments table exists';
        EXECUTE 'SELECT COUNT(*) as record_count FROM payments';
        EXECUTE 'SELECT * FROM payments LIMIT 3';
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error checking common tables: %', SQLERRM;
END $$;

-- 4. Search for any table containing BTC or USDT data
DO $$
BEGIN
    RAISE NOTICE '=== SEARCHING FOR ANY TABLE WITH BTC/USDT DATA ===';
    
    -- Create a dynamic query to search all tables
    EXECUTE 'WITH table_columns AS (
        SELECT table_name, column_name
        FROM information_schema.columns 
        WHERE table_schema = ''public'' 
            AND data_type IN (''text'', ''varchar'', ''character varying'')
    )
    SELECT 
        tc.table_name,
        tc.column_name,
        ''Found column'' as info
    FROM table_columns tc
    WHERE tc.column_name LIKE ''%address%'' 
       OR tc.column_name LIKE ''%btc%'' 
       OR tc.column_name LIKE ''%usdt%''
    ORDER BY tc.table_name, tc.column_name';
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error searching for BTC/USDT data: %', SQLERRM;
END $$;

-- 5. Check if there are any hardcoded addresses in the database
DO $$
BEGIN
    RAISE NOTICE '=== SEARCHING FOR HARDCODED ADDRESSES ===';
    
    -- Look for old BTC address pattern
    EXECUTE 'SELECT 
        ''Searching for old BTC addresses'' as info,
        COUNT(*) as found_count
    FROM information_schema.columns c
    WHERE c.table_schema = ''public'' 
        AND c.data_type IN (''text'', ''varchar'', ''character varying'')
        AND EXISTS (
            SELECT 1 FROM information_schema.tables t 
            WHERE t.table_name = c.table_name AND t.table_schema = ''public''
        )';
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error searching hardcoded addresses: %', SQLERRM;
END $$;

-- Final confirmation
DO $$
BEGIN
    RAISE NOTICE '=== DEPOSIT DATA SEARCH COMPLETE ===';
END $$;
