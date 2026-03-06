-- Step 1: First, let's see what names are actually in both tables
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

-- Step 2: Check what foreign key constraints exist
SELECT 
    tc.table_name, 
    tc.constraint_name, 
    tc.constraint_type,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name 
FROM information_schema.table_constraints AS tc 
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
    AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY' 
    AND (ccu.table_name = 'investment_tiers' OR tc.table_name = 'investment_tiers');
