-- Check current investment_tiers table structure
SELECT 
    'CURRENT_INVESTMENT_TIERS_STRUCTURE' as section,
    column_name,
    data_type,
    is_nullable,
    column_default,
    ordinal_position
FROM information_schema.columns 
WHERE table_schema = 'public' 
    AND table_name = 'investment_tiers'
ORDER BY ordinal_position;

-- Check if table exists
SELECT 
    'INVESTMENT_TIERS_EXISTENCE' as section,
    table_name,
    table_type,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'investment_tiers')
        THEN 'EXISTS'
        ELSE 'MISSING'
    END as status
FROM information_schema.tables 
WHERE table_schema = 'public' 
    AND table_name = 'investment_tiers';
