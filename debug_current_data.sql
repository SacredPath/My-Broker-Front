-- Debug: Check what's actually in the database right now
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
WHERE is_active = true
ORDER BY sort_order;
