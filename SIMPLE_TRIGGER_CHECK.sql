-- SIMPLE TRIGGER VERIFICATION
-- Uses only columns that definitely exist in PostgreSQL

-- 1. Check what trigger columns are available
SELECT '=== AVAILABLE TRIGGER COLUMNS ===' as section;
SELECT 
    column_name,
    data_type
FROM information_schema.columns 
WHERE table_schema = 'information_schema' 
    AND table_name = 'triggers'
    AND column_name IN ('trigger_schema', 'trigger_name', 'action_timing', 'action_condition', 'action_statement', 'action_orientation')
ORDER BY ordinal_position;

-- 2. Show all existing triggers
SELECT '=== ALL EXISTING TRIGGERS ===' as section;
SELECT 
    trigger_schema,
    trigger_name,
    action_timing,
    LEFT(action_statement, 100) as statement_preview
FROM information_schema.triggers
WHERE trigger_schema IN ('public', 'auth')
ORDER BY trigger_schema, trigger_name;

-- 3. Check expected triggers status
SELECT '=== EXPECTED TRIGGERS STATUS ===' as section;
SELECT 
    expected_trigger,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.triggers 
            WHERE trigger_schema IN ('public', 'auth') AND trigger_name = expected_trigger
        ) THEN '✅ DEPLOYED'
        ELSE '❌ MISSING'
    END as status
FROM (VALUES 
    ('on_auth_user_created'),
    ('on_auth_user_updated'),
    ('handle_user_positions_updated_at'),
    ('trigger_set_position_maturity'),
    ('handle_investment_tiers_updated_at'),
    ('notification_settings_updated_at')
) AS t(expected_trigger)
ORDER BY expected_trigger;
