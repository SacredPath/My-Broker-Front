-- Check the actual notifications table schema
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'notifications' 
    AND table_schema = 'public'
ORDER BY ordinal_position;

-- Check if notifications table exists
SELECT 
    EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_name = 'notifications' 
        AND table_schema = 'public'
    ) as table_exists;

-- Show sample data to verify structure
SELECT * FROM notifications LIMIT 3;
