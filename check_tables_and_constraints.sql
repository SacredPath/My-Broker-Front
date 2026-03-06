-- Step 1: Check what names are in the old table
SELECT 
    'investment_tiers' as table_name,
    id,
    name,
    min_amount,
    sort_order
FROM public.investment_tiers 
WHERE is_active = true
ORDER BY sort_order;

-- Step 2: Check what names are in the new table
SELECT 
    'investment_strategies' as table_name,
    id,
    name,
    min_amount,
    sort_order
FROM public.investment_strategies 
WHERE is_active = true
ORDER BY sort_order;

-- Step 3: Check foreign key constraints
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
