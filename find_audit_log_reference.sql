-- Find what's referencing the missing audit_log_entries table
-- Run this in Supabase SQL Editor to identify the source of the error

-- 1. Check all function definitions for audit_log_entries references
SELECT 
    'FUNCTION_REFERENCES' as check_type,
    routine_name,
    routine_definition
FROM information_schema.routines 
WHERE 
    routine_schema = 'public' 
    AND routine_type = 'FUNCTION'
    AND routine_definition ILIKE '%audit_log_entries%';

-- 2. Check all trigger definitions for audit_log_entries references
SELECT 
    'TRIGGER_REFERENCES' as check_type,
    trigger_name,
    action_statement
FROM information_schema.triggers
WHERE 
    trigger_schema = 'public'
    AND action_statement ILIKE '%audit_log_entries%';

-- 3. Check all view definitions for audit_log_entries references
SELECT 
    'VIEW_REFERENCES' as check_type,
    table_name,
    view_definition
FROM information_schema.views
WHERE 
    table_schema = 'public'
    AND view_definition ILIKE '%audit_log_entries%';

-- 4. Search for any other objects that might reference audit_log_entries
SELECT 
    'OTHER_REFERENCES' as check_type,
    obj_description(c.oid) as object_description
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE 
    n.nspname = 'public'
    AND obj_description(c.oid) ILIKE '%audit_log_entries%';

-- 5. Check if there are any dependent objects that might be causing the issue
SELECT 
    'DEPENDENT_OBJECTS' as check_type,
    d.classid::regclass as source_table,
    d.objid,
    d.objsubid,
    d.refobjid::regclass as referenced_table,
    d.deptype
FROM pg_depend d
JOIN pg_class c ON c.oid = d.refobjid
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE 
    n.nspname = 'public'
    AND c.relname = 'audit_log_entries';
