-- Fix investment periods for existing tiers
-- Updates investment_period_days to correct values

UPDATE public.investment_tiers 
SET investment_period_days = 3 
WHERE name = 'Tier 1';

UPDATE public.investment_tiers 
SET investment_period_days = 7 
WHERE name = 'Tier 2';

UPDATE public.investment_tiers 
SET investment_period_days = 14 
WHERE name = 'Tier 3';

UPDATE public.investment_tiers 
SET investment_period_days = 30 
WHERE name = 'Tier 4';

UPDATE public.investment_tiers 
SET investment_period_days = 365 
WHERE name = 'Tier 5';

-- Verify the updates
SELECT 
    '=== UPDATED INVESTMENT TIERS DATA ===' as section,
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
