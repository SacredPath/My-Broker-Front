-- Simple step-by-step deposit methods setup

-- 1. First check current state
SELECT 'CURRENT_DEPOSIT_METHODS_STATE' as info, COUNT(*) as current_count FROM deposit_methods;

-- 2. Add method_type column if missing
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'deposit_methods' AND column_name = 'method_type') THEN
        EXECUTE 'ALTER TABLE deposit_methods ADD COLUMN method_type TEXT';
        RAISE NOTICE 'Added method_type column';
    ELSE
        RAISE NOTICE 'method_type column already exists';
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error adding method_type: %', SQLERRM;
END $$;

-- 3. Add method_name column if missing
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'deposit_methods' AND column_name = 'method_name') THEN
        EXECUTE 'ALTER TABLE deposit_methods ADD COLUMN method_name TEXT';
        RAISE NOTICE 'Added method_name column';
    ELSE
        RAISE NOTICE 'method_name column already exists';
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error adding method_name: %', SQLERRM;
END $$;

-- 4. Add currency column if missing
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'deposit_methods' AND column_name = 'currency') THEN
        EXECUTE 'ALTER TABLE deposit_methods ADD COLUMN currency TEXT';
        RAISE NOTICE 'Added currency column';
    ELSE
        RAISE NOTICE 'currency column already exists';
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error adding currency: %', SQLERRM;
END $$;

-- 5. Add network column if missing
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'deposit_methods' AND column_name = 'network') THEN
        EXECUTE 'ALTER TABLE deposit_methods ADD COLUMN network TEXT';
        RAISE NOTICE 'Added network column';
    ELSE
        RAISE NOTICE 'network column already exists';
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error adding network: %', SQLERRM;
END $$;

-- 6. Insert basic BTC method
DO $$
BEGIN
    EXECUTE 'INSERT INTO deposit_methods (method_type, method_name, currency, network, address, is_active, created_at, updated_at) 
    VALUES (''crypto'', ''BTC Bitcoin'', ''BTC'', ''Bitcoin'', ''bc1q86kns3mf9wrqsv05lpwkvnyg3gq0e5pa90yrth'', true, NOW(), NOW())';
    
    RAISE NOTICE 'Inserted BTC method';
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error inserting BTC method: %', SQLERRM;
END $$;

-- 7. Insert basic USDT method
DO $$
BEGIN
    EXECUTE 'INSERT INTO deposit_methods (method_type, method_name, currency, network, address, is_active, created_at, updated_at) 
    VALUES (''crypto'', ''USDT TRC20'', ''USDT'', ''TRC20'', ''TTs6p5TT2a6kuyAzZX18pX4TZKfrJKstCy'', true, NOW(), NOW())';
    
    RAISE NOTICE 'Inserted USDT method';
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error inserting USDT method: %', SQLERRM;
END $$;

-- 8. Verify the results
SELECT 'FINAL_DEPOSIT_METHODS' as info, * FROM deposit_methods ORDER BY created_at DESC;
