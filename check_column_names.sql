-- Debug: Check the actual column names in the investment_strategies table
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'investment_strategies' 
    AND table_schema = 'public'
ORDER BY ordinal_position;
