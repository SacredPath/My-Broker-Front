-- Just show deposit_methods table structure and sample data

-- 1. Show table structure to see actual column names
SELECT 
    'DEPOSIT_METHODS_COLUMNS' as info,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public' AND table_name = 'deposit_methods'
ORDER BY ordinal_position;

-- 2. Show sample data to see actual column names and values
SELECT 
    'SAMPLE_DATA' as info,
    *
FROM deposit_methods
LIMIT 5;

-- 3. Show all data without filtering by non-existent columns
SELECT 
    'ALL_DEPOSIT_METHODS' as info,
    *
FROM deposit_methods
ORDER BY created_at DESC NULLS LAST;
