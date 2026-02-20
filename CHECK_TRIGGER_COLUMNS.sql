-- Check what columns are actually available in the triggers view
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_schema = 'information_schema' 
    AND table_name = 'triggers'
ORDER BY ordinal_position;
