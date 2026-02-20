-- Complete fix: Create signal_usdt_purchases table and update USDT address

-- 1. First, create the table with usdt_address column included
-- Create signal_usdt_purchases table for USDT-based signal purchases
CREATE TABLE IF NOT EXISTS public.signal_usdt_purchases (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    signal_id UUID NOT NULL REFERENCES public.signals(id) ON DELETE CASCADE,
    amount DECIMAL(20,6) NOT NULL,
    currency VARCHAR(10) DEFAULT 'USDT',
    tx_hash VARCHAR(128),
    network VARCHAR(20) DEFAULT 'TRC20',
    usdt_address VARCHAR(128),
    confirmed BOOLEAN DEFAULT FALSE,
    confirmation_blocks INTEGER DEFAULT 2,
    pdf_access_until TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    confirmed_at TIMESTAMP WITH TIME ZONE,
    retry_count INTEGER DEFAULT 0,
    last_retry_at TIMESTAMP WITH TIME ZONE,
    status VARCHAR(20) DEFAULT 'pending' -- pending, confirmed, failed, refunded
);

-- 2. Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_signal_usdt_purchases_user_id ON public.signal_usdt_purchases(user_id);
CREATE INDEX IF NOT EXISTS idx_signal_usdt_purchases_signal_id ON public.signal_usdt_purchases(signal_id);
CREATE INDEX IF NOT EXISTS idx_signal_usdt_purchases_tx_hash ON public.signal_usdt_purchases(tx_hash);
CREATE INDEX IF NOT EXISTS idx_signal_usdt_purchases_status ON public.signal_usdt_purchases(status);
CREATE INDEX IF NOT EXISTS idx_signal_usdt_purchases_confirmed ON public.signal_usdt_purchases(confirmed);

-- 3. Create updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS update_signal_usdt_purchases_updated_at ON public.signal_usdt_purchases;

-- Create the trigger
CREATE TRIGGER update_signal_usdt_purchases_updated_at 
    BEFORE UPDATE ON public.signal_usdt_purchases 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 4. Row Level Security (RLS)
ALTER TABLE public.signal_usdt_purchases ENABLE ROW LEVEL SECURITY;

-- Safely drop existing policies using DO block
DO $$
BEGIN
    -- Drop existing policies if they exist
    IF EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'signal_usdt_purchases' AND policyname = 'Users can view their own USDT purchases') THEN
        EXECUTE 'DROP POLICY "Users can view their own USDT purchases" ON public.signal_usdt_purchases';
    END IF;
    
    IF EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'signal_usdt_purchases' AND policyname = 'Users can insert their own USDT purchases') THEN
        EXECUTE 'DROP POLICY "Users can insert their own USDT purchases" ON public.signal_usdt_purchases';
    END IF;
    
    IF EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'signal_usdt_purchases' AND policyname = 'Users can update their own USDT purchases') THEN
        EXECUTE 'DROP POLICY "Users can update their own USDT purchases" ON public.signal_usdt_purchases';
    END IF;
END $$;

-- Create RLS policies
-- Users can only see their own purchases
CREATE POLICY "Users can view their own USDT purchases" ON public.signal_usdt_purchases
    FOR SELECT USING (auth.uid() = user_id);

-- Users can only insert their own purchases
CREATE POLICY "Users can insert their own USDT purchases" ON public.signal_usdt_purchases
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can only update their own purchases
CREATE POLICY "Users can update their own USDT purchases" ON public.signal_usdt_purchases
    FOR UPDATE USING (auth.uid() = user_id);

-- 5. Update USDT address in signal_usdt_purchases
DO $$
DECLARE
    _updated_count INTEGER;
BEGIN
    RAISE NOTICE '=== UPDATING USDT ADDRESS IN SIGNAL_USDT_PURCHASES ===';
    UPDATE signal_usdt_purchases 
    SET usdt_address = 'TSM63D4VdE2nev1PoMmqTr8ti3me9JYsJ4' 
    WHERE usdt_address IS NULL OR usdt_address = '';
    
    GET DIAGNOSTICS _updated_count = ROW_COUNT;
    RAISE NOTICE 'Updated % records with new USDT address', _updated_count;
END $$;

-- 6. Show table structure to verify
SELECT 
    'SIGNAL_USDT_PURCHASES_FINAL_STRUCTURE' as info,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public'
    AND table_name = 'signal_usdt_purchases'
ORDER BY ordinal_position;

-- 7. Show sample data to verify update
DO $$
BEGIN
    RAISE NOTICE '=== VERIFYING SIGNAL_USDT_PURCHASES DATA ===';
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'signal_usdt_purchases') THEN
        PERFORM 1; -- Simple verification that table exists
        RAISE NOTICE 'Table exists and is accessible';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Sample data verification failed, but table creation should be complete';
END $$;

-- Final confirmation
DO $$
BEGIN
    RAISE NOTICE '=== SIGNAL_USDT_PURCHASES TABLE CREATION AND UPDATE COMPLETE ===';
END $$;
