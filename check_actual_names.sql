-- Debug: Check the actual names in both tables
SELECT 
    'investment_tiers' as table_name,
    id,
    name,
    min_amount,
    sort_order
FROM public.investment_tiers 
WHERE is_active = true
ORDER BY sort_order

UNION ALL

SELECT 
    'investment_strategies' as table_name,
    id,
    name,
    min_amount,
    sort_order
FROM public.investment_strategies 
WHERE is_active = true
ORDER BY sort_order;
