-- Debug: Check what the API function is actually returning
-- This simulates what the JavaScript fetchStrategiesList() function does

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
    is_active,
    features,
    allocation_mix
FROM public.investment_strategies 
WHERE is_active = true
ORDER BY sort_order;
