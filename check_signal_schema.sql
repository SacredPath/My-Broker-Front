-- Check signal_purchases table structure
SELECT column_name, data_type, is_nullable, column_default 
FROM information_schema.columns 
WHERE table_name = 'signal_purchases' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- Check signal_access table structure  
SELECT column_name, data_type, is_nullable, column_default 
FROM information_schema.columns 
WHERE table_name = 'signal_access' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- Check trading_signals table structure
SELECT column_name, data_type, is_nullable, column_default 
FROM information_schema.columns 
WHERE table_name = 'trading_signals' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- Sample data from each table
SELECT * FROM signal_purchases LIMIT 3;
SELECT * FROM signal_access LIMIT 3;  
SELECT * FROM trading_signals LIMIT 3;
