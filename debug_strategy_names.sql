-- Debug: Check what's actually in the investment_strategies table
SELECT 
    id,
    name,
    description,
    asset_class,
    min_amount,
    max_amount,
    investment_period_days,
    daily_roi,
    sort_order,
    is_active
FROM public.investment_strategies 
ORDER BY sort_order;

-- Also check if the old investment_tiers table still exists and has data
SELECT 
    COUNT(*) as old_tiers_count,
    'investment_tiers' as table_name
FROM public.investment_tiers 
WHERE is_active = true

UNION ALL

SELECT 
    COUNT(*) as new_strategies_count,
    'investment_strategies' as table_name
FROM public.investment_strategies 
WHERE is_active = true;
