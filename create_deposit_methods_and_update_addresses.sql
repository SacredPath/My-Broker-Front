-- Create deposit_methods table first, then update addresses

-- 1. Create deposit_methods table
CREATE TABLE IF NOT EXISTS public.deposit_methods (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    method_name VARCHAR(50) NOT NULL,
    method_type VARCHAR(20) DEFAULT 'crypto',
    currency VARCHAR(10) NOT NULL,
    network VARCHAR(20) DEFAULT NULL,
    address VARCHAR(128) NOT NULL,
    paypal_email VARCHAR(255),
    bank_name VARCHAR(255),
    account_number VARCHAR(50),
    routing_number VARCHAR(50),
    min_amount DECIMAL(20,8) DEFAULT 0,
    max_amount DECIMAL(20,8) DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_deposit_methods_method_name ON public.deposit_methods(method_name);
CREATE INDEX IF NOT EXISTS idx_deposit_methods_currency ON public.deposit_methods(currency);

-- Enable Row Level Security
ALTER TABLE public.deposit_methods ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Service role full access to deposit_methods" ON public.deposit_methods
    FOR ALL USING (auth.jwt() ->> 'role' = 'service_role');

CREATE POLICY "Authenticated users can read deposit_methods" ON public.deposit_methods
    FOR SELECT USING (auth.role() = 'authenticated');

-- Grant permissions
GRANT SELECT ON public.deposit_methods TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.deposit_methods TO service_role;

-- 2. Now update addresses (same as previous script)
DO $$
BEGIN
    RAISE NOTICE '=== UPDATING BTC ADDRESS TO bc1q86kns3mf9wrqsv05lpwkvnyg3gq0e5pa90yrth ===';
    
    -- Update deposit_addresses table if it exists
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'deposit_addresses') THEN
        UPDATE deposit_addresses 
        SET btc_address = 'bc1q86kns3mf9wrqsv05lpwkvnyg3gq0e5pa90yrth' 
        WHERE btc_address IS NOT NULL;
        
        GET DIAGNOSTICS _count = ROW_COUNT;
        RAISE NOTICE 'Updated % records in deposit_addresses', _count;
    END IF;
    
    -- Update deposit_methods table if it exists
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'deposit_methods') THEN
        UPDATE deposit_methods 
        SET address = 'bc1q86kns3mf9wrqsv05lpwkvnyg3gq0e5pa90yrth',
            updated_at = NOW()
        WHERE method_name = 'BTC Bitcoin' AND currency = 'BTC';
        
        GET DIAGNOSTICS _count = ROW_COUNT;
        RAISE NOTICE 'Updated % records in deposit_methods', _count;
    END IF;
    
    -- Update purchases table if it exists
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'purchases') THEN
        UPDATE purchases 
        SET btc_address = 'bc1q86kns3mf9wrqsv05lpwkvnyg3gq0e5pa90yrth' 
        WHERE btc_address IS NOT NULL;
        
        GET DIAGNOSTICS _count = ROW_COUNT;
        RAISE NOTICE 'Updated % records in purchases', _count;
    END IF;
    
    -- Update subscriptions table if it exists
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'subscriptions') THEN
        UPDATE subscriptions 
        SET btc_address = 'bc1q86kns3mf9wrqsv05lpwkvnyg3gq0e5pa90yrth' 
        WHERE btc_address IS NOT NULL;
        
        GET DIAGNOSTICS _count = ROW_COUNT;
        RAISE NOTICE 'Updated % records in subscriptions', _count;
    END IF;
    
    -- Update signal_usdt_purchases table if it exists
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'signal_usdt_purchases') THEN
        UPDATE signal_usdt_purchases 
        SET usdt_address = 'TTs6p5TT2a6kuyAzZX18pX4TZKfrJKstCy' 
        WHERE usdt_address IS NOT NULL;
        
        GET DIAGNOSTICS _count = ROW_COUNT;
        RAISE NOTICE 'Updated % records in signal_usdt_purchases', _count;
    END IF;
    
    -- Update purchases table if it exists
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'purchases') THEN
        UPDATE purchases 
        SET usdt_address = 'TTs6p5TT2a6kuyAzZX18pX4TZKfrJKstCy' 
        WHERE usdt_address IS NOT NULL;
        
        GET DIAGNOSTICS _count = ROW_COUNT;
        RAISE NOTICE 'Updated % records in purchases', _count;
    END IF;
    
    -- Update subscriptions table if it exists
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'subscriptions') THEN
        UPDATE subscriptions 
        SET usdt_address = 'TTs6p5TT2a6kuyAzZX18pX4TZKfrJKstCy' 
        WHERE usdt_address IS NOT NULL;
        
        GET DIAGNOSTICS _count = ROW_COUNT;
        RAISE NOTICE 'Updated % records in subscriptions', _count;
    END IF;
    
END $$;

-- 3. Verify the updates
DO $$
BEGIN
    RAISE NOTICE '=== VERIFYING UPDATES ===';
    
    -- Check if deposit_methods table exists and has records
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'deposit_methods') THEN
        PERFORM 1;
        RAISE NOTICE 'deposit_methods table exists and is accessible';
    END IF;
    
    -- Show sample data from deposit_methods
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'deposit_methods') THEN
        RAISE NOTICE '=== SAMPLE DEPOSIT METHODS ===';
        EXECUTE 'SELECT method_name, currency, network, address FROM deposit_methods LIMIT 5';
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error during verification: %', SQLERRM;
END $$;

-- Final confirmation
DO $$
BEGIN
    RAISE NOTICE '=== DEPOSIT METHODS AND ADDRESSES UPDATE COMPLETE ===';
END $$;
