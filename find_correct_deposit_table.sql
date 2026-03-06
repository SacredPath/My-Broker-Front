-- Find the correct deposit table structure

-- 1. Show all tables in the database
SELECT 
    'ALL_TABLES' as info,
    table_schema,
    table_name,
    table_type
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND (table_name LIKE '%deposit%' OR table_name LIKE '%payment%' OR table_name LIKE '%method%')
ORDER BY table_name;

-- 2. Check if there are other method-related tables
SELECT 
    'METHOD_RELATED_TABLES' as info,
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_schema = 'public' 
AND table_name LIKE '%method%'
ORDER BY table_name, ordinal_position;

-- 3. Show structure of all deposit-related tables
SELECT 
    'DEPOSIT_TABLE_STRUCTURES' as info,
    table_name,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public' 
AND table_name LIKE '%deposit%'
ORDER BY table_name, ordinal_position;

-- 4. Check for any tables with paypal_email column
SELECT 
    'PAYPAL_EMAIL_COLUMNS' as info,
    table_name,
    column_name,
    data_type
FROM information_schema.columns 
WHERE table_schema = 'public' 
AND column_name = 'paypal_email'
ORDER BY table_name;
