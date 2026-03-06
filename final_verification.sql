-- Final verification: Check if foreign key constraints are pointing to the new table
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
    AND ccu.table_name = 'investment_strategies';

-- Also check the actual strategy names to confirm migration worked
SELECT 
    id,
    name,
    asset_class,
    min_amount,
    max_amount,
    sort_order
FROM public.investment_strategies 
WHERE is_active = true
ORDER BY sort_order;
