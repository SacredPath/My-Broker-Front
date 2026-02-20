-- Complete the deposit_methods table structure and populate it

-- 1. Add missing columns to deposit_methods table
DO $$
BEGIN
    RAISE NOTICE '=== ADDING MISSING COLUMNS TO DEPOSIT_METHODS ===';
    
    -- Add missing columns if they don't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'deposit_methods' AND column_name = 'method_type') THEN
        EXECUTE 'ALTER TABLE deposit_methods ADD COLUMN method_type TEXT';
        RAISE NOTICE 'Added method_type column';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'deposit_methods' AND column_name = 'method_name') THEN
        EXECUTE 'ALTER TABLE deposit_methods ADD COLUMN method_name TEXT';
        RAISE NOTICE 'Added method_name column';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'deposit_methods' AND column_name = 'currency') THEN
        EXECUTE 'ALTER TABLE deposit_methods ADD COLUMN currency TEXT';
        RAISE NOTICE 'Added currency column';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'deposit_methods' AND column_name = 'network') THEN
        EXECUTE 'ALTER TABLE deposit_methods ADD COLUMN network TEXT';
        RAISE NOTICE 'Added network column';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'deposit_methods' AND column_name = 'bank_name') THEN
        EXECUTE 'ALTER TABLE deposit_methods ADD COLUMN bank_name TEXT';
        RAISE NOTICE 'Added bank_name column';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'deposit_methods' AND column_name = 'account_number') THEN
        EXECUTE 'ALTER TABLE deposit_methods ADD COLUMN account_number TEXT';
        RAISE NOTICE 'Added account_number column';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'deposit_methods' AND column_name = 'routing_number') THEN
        EXECUTE 'ALTER TABLE deposit_methods ADD COLUMN routing_number TEXT';
        RAISE NOTICE 'Added routing_number column';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'deposit_methods' AND column_name = 'paypal_email') THEN
        EXECUTE 'ALTER TABLE deposit_methods ADD COLUMN paypal_email TEXT';
        RAISE NOTICE 'Added paypal_email column';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'deposit_methods' AND column_name = 'paypal_business_name') THEN
        EXECUTE 'ALTER TABLE deposit_methods ADD COLUMN paypal_business_name TEXT';
        RAISE NOTICE 'Added paypal_business_name column';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'deposit_methods' AND column_name = 'min_amount') THEN
        EXECUTE 'ALTER TABLE deposit_methods ADD COLUMN min_amount NUMERIC';
        RAISE NOTICE 'Added min_amount column';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'deposit_methods' AND column_name = 'max_amount') THEN
        EXECUTE 'ALTER TABLE deposit_methods ADD COLUMN max_amount NUMERIC';
        RAISE NOTICE 'Added max_amount column';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'deposit_methods' AND column_name = 'fee_percentage') THEN
        EXECUTE 'ALTER TABLE deposit_methods ADD COLUMN fee_percentage NUMERIC';
        RAISE NOTICE 'Added fee_percentage column';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'deposit_methods' AND column_name = 'fixed_fee') THEN
        EXECUTE 'ALTER TABLE deposit_methods ADD COLUMN fixed_fee NUMERIC';
        RAISE NOTICE 'Added fixed_fee column';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'deposit_methods' AND column_name = 'processing_time_hours') THEN
        EXECUTE 'ALTER TABLE deposit_methods ADD COLUMN processing_time_hours INTEGER';
        RAISE NOTICE 'Added processing_time_hours column';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'deposit_methods' AND column_name = 'instructions') THEN
        EXECUTE 'ALTER TABLE deposit_methods ADD COLUMN instructions TEXT';
        RAISE NOTICE 'Added instructions column';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'deposit_methods' AND column_name = 'requires_verification') THEN
        EXECUTE 'ALTER TABLE deposit_methods ADD COLUMN requires_verification BOOLEAN DEFAULT false';
        RAISE NOTICE 'Added requires_verification column';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'deposit_methods' AND column_name = 'verification_fields') THEN
        EXECUTE 'ALTER TABLE deposit_methods ADD COLUMN verification_fields JSONB';
        RAISE NOTICE 'Added verification_fields column';
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error adding columns: %', SQLERRM;
END $$;

-- 2. Insert comprehensive deposit methods with new addresses
DO $$
BEGIN
    RAISE NOTICE '=== INSERTING COMPREHENSIVE DEPOSIT METHODS ===';
    
    -- Clear existing data
    EXECUTE 'DELETE FROM deposit_methods';
    
    -- Insert BTC method
    EXECUTE 'INSERT INTO deposit_methods (
        method_type, method_name, currency, network, address,
        min_amount, max_amount, fee_percentage, fixed_fee, processing_time_hours,
        instructions, is_active, requires_verification, created_at, updated_at
    ) VALUES (
        ''crypto'', ''BTC Bitcoin'', ''BTC'', ''Bitcoin'', ''bc1q86kns3mf9wrqsv05lpwkvnyg3gq0e5pa90yrth'',
        0.0001, 10.0, 0.0, 0.0, 1,
        ''Send Bitcoin to this address. Your deposit will be credited after network confirmation.'', true, false, NOW(), NOW()
    )';
    
    -- Insert USDT method
    EXECUTE 'INSERT INTO deposit_methods (
        method_type, method_name, currency, network, address,
        min_amount, max_amount, fee_percentage, fixed_fee, processing_time_hours,
        instructions, is_active, requires_verification, created_at, updated_at
    ) VALUES (
        ''crypto'', ''USDT TRC20'', ''USDT'', ''TRC20'', ''TTs6p5TT2a6kuyAzZX18pX4TZKfrJKstCy'',
        10.0, 10000.0, 0.0, 0.0, 1,
        ''Send USDT (TRC20) to this address. Your deposit will be credited after network confirmation.'', true, false, NOW(), NOW()
    )';
    
    -- Insert PayPal method
    EXECUTE 'INSERT INTO deposit_methods (
        method_type, method_name, currency, paypal_email, paypal_business_name,
        min_amount, max_amount, fee_percentage, fixed_fee, processing_time_hours,
        instructions, is_active, requires_verification, verification_fields, created_at, updated_at
    ) VALUES (
        ''paypal'', ''PayPal Transfer'', ''USD'', ''business@example.com'', ''Example Business'',
        10.0, 5000.0, 2.9, 0.30, 1,
        ''Send PayPal payment to business@example.com. Include your user ID in the notes.'', true, true, 
        ''{"email": true, "business_name": true, "user_id": true}'', NOW(), NOW()
    )';
    
    -- Insert ACH method
    EXECUTE 'INSERT INTO deposit_methods (
        method_type, method_name, currency, bank_name, account_number, routing_number,
        min_amount, max_amount, fee_percentage, fixed_fee, processing_time_hours,
        instructions, is_active, requires_verification, verification_fields, created_at, updated_at
    ) VALUES (
        ''ach'', ''ACH Transfer'', ''USD'', ''Example Bank'', ''123456789'', ''021000021'',
        25.0, 25000.0, 0.0, 0.0, 3,
        ''Set up ACH transfer to Example Bank. Account: ****6789, Routing: 021000021'', true, true,
        ''{"bank_name": true, "account_number": true, "routing_number": true}'', NOW(), NOW()
    )';
    
    RAISE NOTICE 'Inserted 4 deposit methods with new addresses';
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error inserting deposit methods: %', SQLERRM;
END $$;

-- 3. Verify the data was inserted
DO $$
BEGIN
    RAISE NOTICE '=== VERIFYING DEPOSIT METHODS ===';
    
    EXECUTE 'SELECT 
        method_type, method_name, currency, network, address, 
        paypal_email, bank_name, is_active, created_at
    FROM deposit_methods 
    ORDER BY method_type, currency';
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error verifying deposit methods: %', SQLERRM;
END $$;

RAISE NOTICE '=== DEPOSIT METHODS SETUP COMPLETE ===';
