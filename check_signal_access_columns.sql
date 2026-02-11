-- Check signal_access table structure
SELECT column_name, data_type, is_nullable, column_default 
FROM information_schema.columns 
WHERE table_name = 'signal_access' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- Sample data from signal_access table
SELECT * FROM signal_access LIMIT 3;
