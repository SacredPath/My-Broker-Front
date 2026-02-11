-- Create signal_usdt_purchases table for USDT-based signal purchases
CREATE TABLE IF NOT EXISTS public.signal_usdt_purchases (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    signal_id UUID NOT NULL REFERENCES public.signals(id) ON DELETE CASCADE,
    amount DECIMAL(20,6) NOT NULL,
    currency VARCHAR(10) DEFAULT 'USDT',
    tx_hash VARCHAR(128),
    network VARCHAR(20) DEFAULT 'TRC20',
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

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_signal_usdt_purchases_user_id ON public.signal_usdt_purchases(user_id);
CREATE INDEX IF NOT EXISTS idx_signal_usdt_purchases_signal_id ON public.signal_usdt_purchases(signal_id);
CREATE INDEX IF NOT EXISTS idx_signal_usdt_purchases_tx_hash ON public.signal_usdt_purchases(tx_hash);
CREATE INDEX IF NOT EXISTS idx_signal_usdt_purchases_status ON public.signal_usdt_purchases(status);
CREATE INDEX IF NOT EXISTS idx_signal_usdt_purchases_confirmed ON public.signal_usdt_purchases(confirmed);

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_signal_usdt_purchases_updated_at 
    BEFORE UPDATE ON public.signal_usdt_purchases 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Row Level Security (RLS)
ALTER TABLE public.signal_usdt_purchases ENABLE ROW LEVEL SECURITY;

-- Users can only see their own purchases
CREATE POLICY "Users can view their own USDT purchases" ON public.signal_usdt_purchases
    FOR SELECT USING (auth.uid() = user_id);

-- Users can only insert their own purchases
CREATE POLICY "Users can insert their own USDT purchases" ON public.signal_usdt_purchases
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can only update their own purchases
CREATE POLICY "Users can update their own USDT purchases" ON public.signal_usdt_purchases
    FOR UPDATE USING (auth.uid() = user_id);
