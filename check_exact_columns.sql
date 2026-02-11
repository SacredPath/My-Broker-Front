-- Check exact column structure for signal_access table
SELECT column_name, data_type, is_nullable, column_default 
FROM information_schema.columns 
WHERE table_name = 'signal_access' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- Check exact column structure for signals table
SELECT column_name, data_type, is_nullable, column_default 
FROM information_schema.columns 
WHERE table_name = 'signals' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- Sample data from signal_access table
SELECT * FROM signal_access LIMIT 3;

-- Sample data from signals table  
SELECT * FROM signals LIMIT 3;
