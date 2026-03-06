-- Check if notifications table exists
SELECT table_name, table_schema 
FROM information_schema.tables 
WHERE table_name LIKE '%notification%' 
   OR table_name LIKE '%message%'
   OR table_name LIKE '%alert%'
ORDER BY table_name;

-- Check all tables to see if any notification-related columns exist
SELECT 
    table_name,
    column_name,
    data_type
FROM information_schema.columns 
WHERE column_name LIKE '%notification%' 
   OR column_name LIKE '%message%'
   OR column_name LIKE '%alert%'
   OR column_name LIKE '%notify%'
ORDER BY table_name, column_name;

-- Check if there are any functions for notifications
SELECT routine_name, routine_type 
FROM information_schema.routines 
WHERE routine_name LIKE '%notification%' 
   OR routine_name LIKE '%message%'
   OR routine_name LIKE '%alert%'
ORDER BY routine_name;
