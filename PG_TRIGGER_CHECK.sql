-- ALTERNATIVE: Use PostgreSQL's pg_trigger system catalog
-- This works in all PostgreSQL versions

SELECT '=== TRIGGERS FROM PG_TRIGGER ===' as section;
SELECT 
    n.nspname as schema_name,
    c.relname as table_name,
    t.tgname as trigger_name,
    CASE 
        WHEN t.tgtype::integer & 1 != 0 THEN 'BEFORE'
        WHEN t.tgtype::integer & 2 != 0 THEN 'AFTER'
        WHEN t.tgtype::integer & 4 != 0 THEN 'INSTEAD OF'
        ELSE 'UNKNOWN'
    END as timing,
    CASE 
        WHEN t.tgtype::integer & 16 != 0 THEN 'INSERT'
        WHEN t.tgtype::integer & 32 != 0 THEN 'DELETE'
        WHEN t.tgtype::integer & 64 != 0 THEN 'UPDATE'
        ELSE 'UNKNOWN'
    END as event_type,
    pg_get_triggerdef(t.oid) as definition
FROM pg_trigger t
JOIN pg_class c ON t.tgrelid = c.oid
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE n.nspname IN ('public', 'auth')
    AND NOT t.tgisinternal
ORDER BY n.nspname, c.relname, t.tgname;
