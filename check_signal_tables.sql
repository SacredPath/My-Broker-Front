-- Database Schema Investigation Queries
-- Run these queries to check table structures and find the correct table names

-- 1. Check all tables in the database
SELECT table_name, table_schema 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

-- 2. Check for signal-related tables (search for tables with 'signal' in the name)
SELECT table_name, table_schema 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name ILIKE '%signal%'
ORDER BY table_name;

-- 3. Check signal_purchases table structure if it exists
SELECT column_name, data_type, is_nullable, column_default 
FROM information_schema.columns 
WHERE table_name = 'signal_purchases' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- 4. Check for alternative table names that might contain signal purchases
SELECT column_name, data_type, is_nullable, column_default 
FROM information_schema.columns 
WHERE table_name IN (
    'signal_purchases', 
    'signal_purchase', 
    'signals', 
    'trading_signals',
    'user_signals',
    'signal_subscriptions',
    'purchases'
) 
AND table_schema = 'public'
ORDER BY table_name, ordinal_position;

-- 5. Check transactions table structure (for home page activity)
SELECT column_name, data_type, is_nullable, column_default 
FROM information_schema.columns 
WHERE table_name = 'transactions' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- 6. Sample data from signal_purchases (if table exists)
SELECT * FROM signal_purchases LIMIT 5;

-- 7. Sample data from transactions table (to understand structure)
SELECT * FROM transactions WHERE user_id = 'your-user-id' LIMIT 5;
