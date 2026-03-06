-- Simple verification script for investment_strategies migration
-- This checks if the migration was successful

-- Check if investment_strategies table exists and has data
SELECT 
    'investment_strategies table' as item,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'investment_strategies' AND table_schema = 'public') 
        THEN '✅ EXISTS' 
        ELSE '❌ MISSING' 
    END as status;

-- Check if old investment_tiers table is gone
SELECT 
    'old investment_tiers table' as item,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'investment_tiers' AND table_schema = 'public') 
        THEN '❌ STILL EXISTS (should be removed)' 
        ELSE '✅ SUCCESSFULLY REMOVED' 
    END as status;

-- Check data in investment_strategies
SELECT 
    COUNT(*) as strategy_count,
    'investment_strategies records' as item
FROM public.investment_strategies 
WHERE is_active = true;

-- Check foreign key constraints
SELECT 
    tc.table_name,
    tc.constraint_name,
    ccu.table_name as references_table
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage ccu ON tc.constraint_name = ccu.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY' 
    AND ccu.table_name = 'investment_strategies';
