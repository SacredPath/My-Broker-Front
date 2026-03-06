-- Simple fix for investment_tiers table
-- Uses individual ALTER statements instead of DO blocks

-- First create the handle_updated_at function
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add missing columns individually
ALTER TABLE public.investment_tiers ADD COLUMN IF NOT EXISTS investment_period_days INTEGER NOT NULL DEFAULT 30;
ALTER TABLE public.investment_tiers ADD COLUMN IF NOT EXISTS sort_order INTEGER NOT NULL DEFAULT 0;
ALTER TABLE public.investment_tiers ADD COLUMN IF NOT EXISTS features JSONB;
ALTER TABLE public.investment_tiers ADD COLUMN IF NOT EXISTS allocation_mix JSONB;
ALTER TABLE public.investment_tiers ADD COLUMN IF NOT EXISTS is_active BOOLEAN NOT NULL DEFAULT true;
ALTER TABLE public.investment_tiers ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
ALTER TABLE public.investment_tiers ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_investment_tiers_active_sort ON public.investment_tiers(is_active, sort_order);
CREATE INDEX IF NOT EXISTS idx_investment_tiers_min_amount ON public.investment_tiers(min_amount);

-- Create trigger
DROP TRIGGER IF EXISTS handle_investment_tiers_updated_at ON public.investment_tiers;
CREATE TRIGGER handle_investment_tiers_updated_at
    BEFORE UPDATE ON public.investment_tiers
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Insert default data (only if table is empty)
INSERT INTO public.investment_tiers (name, description, min_amount, max_amount, investment_period_days, daily_roi, sort_order, features, allocation_mix) 
SELECT 
    name, description, min_amount, max_amount, investment_period_days, daily_roi, sort_order, 
    features::jsonb, allocation_mix::jsonb
FROM (VALUES 
    ('Tier 1', 'Entry-level investment tier with competitive returns.', 150.00, 1000.00, 3, 0.1, 1, '["Basic trading signals", "Email support", "Daily ROI payouts"]', '{"BTC": 40, "ETH": 30, "USDT": 30}'),
    ('Tier 2', 'Intermediate tier with enhanced returns and features.', 1000.01, 10000.00, 7, 0.0643, 2, '["Advanced trading signals", "Priority support", "Daily ROI payouts", "Portfolio analytics"]', '{"BTC": 35, "ETH": 35, "USDT": 30}'),
    ('Tier 3', 'Advanced tier for serious investors.', 10000.01, 20000.00, 14, 0.0357, 3, '["Premium trading signals", "24/7 support", "Daily ROI payouts", "Advanced analytics", "Risk management tools"]', '{"BTC": 30, "ETH": 40, "USDT": 30}'),
    ('Tier 4', 'Professional tier with high returns.', 20000.01, 50000.00, 30, 0.0333, 4, '["VIP trading signals", "Dedicated account manager", "Daily ROI payouts", "Custom analytics", "API access", "Lower fees"]', '{"BTC": 25, "ETH": 45, "USDT": 30}'),
    ('Tier 5', 'Elite tier for maximum returns and exclusive benefits.', 50000.01, 10000000.00, 60, 0.0333, 5, '["Exclusive signals", "Personal advisor", "Daily ROI payouts", "Custom strategies", "Priority API", "Zero fees", "Exclusive events"]', '{"BTC": 20, "ETH": 50, "USDT": 30}')
) AS t(name, description, min_amount, max_amount, investment_period_days, daily_roi, sort_order, features, allocation_mix)
WHERE NOT EXISTS (SELECT 1 FROM public.investment_tiers LIMIT 1)
ON CONFLICT (name) DO NOTHING;

-- Grant permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON public.investment_tiers TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.investment_tiers TO service_role;

-- Show final structure
SELECT 
    '=== FINAL INVESTMENT TIERS STRUCTURE ===' as section,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public' 
    AND table_name = 'investment_tiers'
ORDER BY ordinal_position;

-- Show data
SELECT 
    '=== INVESTMENT TIERS DATA ===' as section,
    id,
    name,
    min_amount,
    max_amount,
    daily_roi,
    investment_period_days,
    sort_order,
    is_active
FROM public.investment_tiers
ORDER BY sort_order;
