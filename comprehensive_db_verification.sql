-- COMPREHENSIVE DATABASE VERIFICATION SCRIPT
-- Trading Platform Database Schema Verification
-- Run this in Supabase SQL Editor to verify all tables, columns, functions, and triggers

-- ========================================
-- 1. ALL TABLES IN PUBLIC SCHEMA
-- ========================================
SELECT 
    'PUBLIC_TABLES' as verification_type,
    table_name,
    table_type,
    CASE 
        WHEN table_name IN ('profiles', 'kyc_applications', 'kyc_status', 'notifications', 'notification_settings', 
                           'user_positions', 'investment_tiers', 'wallet_balances', 'positions', 'payout_methods',
                           'deposit_addresses', 'signal_purchases', 'signal_access', 'trading_signals') 
        THEN 'CORE_TABLE'
        ELSE 'SUPPORTING_TABLE'
    END as table_category
FROM information_schema.tables 
WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
ORDER BY table_category, table_name;

-- ========================================
-- 2. ALL COLUMNS WITH DETAILED INFO
-- ========================================
SELECT 
    'COLUMNS_DETAIL' as verification_type,
    table_name,
    column_name,
    ordinal_position,
    data_type,
    character_maximum_length,
    numeric_precision,
    numeric_scale,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public'
ORDER BY table_name, ordinal_position;

-- ========================================
-- 3. PRIMARY KEYS
-- ========================================
SELECT 
    'PRIMARY_KEYS' as verification_type,
    tc.table_name,
    tc.constraint_name,
    kcu.column_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu 
    ON tc.constraint_name = kcu.constraint_name 
    AND tc.table_schema = kcu.table_schema
WHERE 
    tc.constraint_type = 'PRIMARY KEY'
    AND tc.table_schema = 'public'
ORDER BY tc.table_name;

-- ========================================
-- 4. FOREIGN KEY RELATIONSHIPS
-- ========================================
SELECT 
    'FOREIGN_KEYS' as verification_type,
    tc.table_name,
    tc.constraint_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu 
    ON tc.constraint_name = kcu.constraint_name 
    AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage ccu 
    ON ccu.constraint_name = tc.constraint_name 
    AND ccu.table_schema = tc.table_schema
WHERE 
    tc.constraint_type = 'FOREIGN KEY'
    AND tc.table_schema = 'public'
ORDER BY tc.table_name, tc.constraint_name;

-- ========================================
-- 5. ALL INDEXES
-- ========================================
SELECT 
    'INDEXES' as verification_type,
    tablename,
    indexname,
    indexdef
FROM pg_indexes 
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

-- ========================================
-- 6. ALL FUNCTIONS
-- ========================================
SELECT 
    'FUNCTIONS' as verification_type,
    routine_name,
    routine_type,
    data_type,
    external_language,
    is_deterministic,
    sql_data_access,
    LEFT(routine_definition, 200) as definition_preview
FROM information_schema.routines
WHERE 
    routine_schema = 'public'
    AND routine_type = 'FUNCTION'
ORDER BY routine_name;

-- ========================================
-- 7. ALL TRIGGERS
-- ========================================
SELECT 
    'TRIGGERS' as verification_type,
    trigger_name,
    event_object_table as table_name,
    event_manipulation as event_type,
    action_timing,
    action_condition,
    LEFT(action_statement, 200) as statement_preview,
    action_orientation
FROM information_schema.triggers
WHERE 
    trigger_schema = 'public'
ORDER BY event_object_table, trigger_name;

-- ========================================
-- 8. CHECK CONSTRAINTS
-- ========================================
SELECT 
    'CHECK_CONSTRAINTS' as verification_type,
    tc.table_name,
    tc.constraint_name,
    cc.check_clause
FROM information_schema.table_constraints tc
JOIN information_schema.check_constraints cc 
    ON tc.constraint_name = cc.constraint_name
WHERE 
    tc.constraint_type = 'CHECK'
    AND tc.table_schema = 'public'
ORDER BY tc.table_name, tc.constraint_name;

-- ========================================
-- 9. UNIQUE CONSTRAINTS
-- ========================================
SELECT 
    'UNIQUE_CONSTRAINTS' as verification_type,
    tc.table_name,
    tc.constraint_name,
    kcu.column_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu 
    ON tc.constraint_name = kcu.constraint_name 
    AND tc.table_schema = kcu.table_schema
WHERE 
    tc.constraint_type = 'UNIQUE'
    AND tc.table_schema = 'public'
ORDER BY tc.table_name, tc.constraint_name;

-- ========================================
-- 10. RLS POLICIES
-- ========================================
SELECT 
    'RLS_POLICIES' as verification_type,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    LEFT(qual, 200) as qual_preview,
    LEFT(with_check, 200) as with_check_preview
FROM pg_policies 
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- ========================================
-- 11. TABLE SIZES AND ROW COUNTS
-- ========================================
SELECT 
    'TABLE_STATS' as verification_type,
    relname AS tablename,
    pg_size_pretty(pg_total_relation_size('public.'||relname)) AS size,
    pg_total_relation_size('public.'||relname) AS size_bytes,
    n_live_tup AS live_rows,
    n_dead_tup AS dead_rows,
    last_vacuum,
    last_autovacuum,
    last_analyze,
    last_autoanalyze
FROM pg_stat_user_tables
ORDER BY relname;

-- ========================================
-- 12. ENUM TYPES
-- ========================================
SELECT 
    'ENUM_TYPES' as verification_type,
    t.typname AS type_name,
    e.enumlabel AS enum_value,
    e.enumsortorder AS sort_order
FROM pg_type t
JOIN pg_enum e ON t.oid = e.enumtypid
JOIN pg_namespace n ON n.oid = t.typnamespace
WHERE 
    t.typtype = 'e'
    AND n.nspname = 'public'
ORDER BY type_name, sort_order;

-- ========================================
-- 13. VIEWS
-- ========================================
SELECT 
    'VIEWS' as verification_type,
    table_name,
    is_updatable,
    is_insertable_into,
    LEFT(view_definition, 200) as definition_preview
FROM information_schema.views
WHERE 
    table_schema = 'public'
ORDER BY table_name;

-- ========================================
-- 14. SEQUENCES
-- ========================================
SELECT 
    'SEQUENCES' as verification_type,
    sequence_name,
    data_type,
    start_value,
    minimum_value,
    maximum_value,
    increment,
    cycle_option
FROM information_schema.sequences
WHERE 
    sequence_schema = 'public'
ORDER BY sequence_name;

-- ========================================
-- 15. EXPECTED CORE TABLES VERIFICATION
-- ========================================
SELECT 
    'EXPECTED_TABLES_CHECK' as verification_type,
    expected_table,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.tables 
            WHERE table_schema = 'public' AND table_name = expected_table
        ) THEN 'EXISTS'
        ELSE 'MISSING'
    END as status
FROM (VALUES 
    ('profiles'),
    ('kyc_applications'),
    ('kyc_status'),
    ('notifications'),
    ('notification_settings'),
    ('user_positions'),
    ('investment_tiers'),
    ('wallet_balances'),
    ('positions'),
    ('payout_methods'),
    ('deposit_addresses'),
    ('signal_purchases'),
    ('signal_access'),
    ('trading_signals')
) AS t(expected_table)
ORDER BY expected_table;

-- ========================================
-- 16. CRITICAL BUSINESS LOGIC VERIFICATION
-- ========================================

-- Check if handle_updated_at function exists (used by multiple tables)
SELECT 
    'CRITICAL_FUNCTIONS' as verification_type,
    'handle_updated_at' as function_name,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.routines 
            WHERE routine_schema = 'public' AND routine_name = 'handle_updated_at'
        ) THEN 'EXISTS'
        ELSE 'MISSING'
    END as status
UNION ALL
-- Check if calculate_position_maturity function exists
SELECT 
    'CRITICAL_FUNCTIONS' as verification_type,
    'calculate_position_maturity' as function_name,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.routines 
            WHERE routine_schema = 'public' AND routine_name = 'calculate_position_maturity'
        ) THEN 'EXISTS'
        ELSE 'MISSING'
    END as status
UNION ALL
-- Check if set_position_maturity function exists
SELECT 
    'CRITICAL_FUNCTIONS' as verification_type,
    'set_position_maturity' as function_name,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.routines 
            WHERE routine_schema = 'public' AND routine_name = 'set_position_maturity'
        ) THEN 'EXISTS'
        ELSE 'MISSING'
    END as status;

-- ========================================
-- 17. SUPABASE AUTH SCHEMA TABLES
-- ========================================
SELECT 
    'AUTH_TABLES' as verification_type,
    table_name,
    table_type
FROM information_schema.tables 
WHERE table_schema = 'auth' AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- ========================================
-- 18. SUMMARY REPORT
-- ========================================
SELECT 
    'SUMMARY' as verification_type,
    'Total Public Tables' as metric,
    COUNT(*)::text as value
FROM information_schema.tables 
WHERE table_schema = 'public' AND table_type = 'BASE TABLE'

UNION ALL

SELECT 
    'SUMMARY' as verification_type,
    'Total Public Functions' as metric,
    COUNT(*)::text as value
FROM information_schema.routines 
WHERE routine_schema = 'public' AND routine_type = 'FUNCTION'

UNION ALL

SELECT 
    'SUMMARY' as verification_type,
    'Total Public Triggers' as metric,
    COUNT(*)::text as value
FROM information_schema.triggers 
WHERE trigger_schema = 'public'

UNION ALL

SELECT 
    'SUMMARY' as verification_type,
    'Total RLS Policies' as metric,
    COUNT(*)::text as value
FROM pg_policies 
WHERE schemaname = 'public';

-- ========================================
-- VERIFICATION COMPLETE
-- ========================================
-- Review the output above to ensure:
-- 1. All expected tables exist
-- 2. All columns have correct data types and constraints
-- 3. All foreign key relationships are properly defined
-- 4. All indexes are present for performance
-- 5. All functions and triggers are correctly implemented
-- 6. RLS policies are in place for security
-- 7. Check constraints enforce data integrity
-- 8. Table sizes are reasonable and not bloated
