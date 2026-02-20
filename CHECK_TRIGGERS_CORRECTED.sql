-- CORRECTED TRIGGERS VERIFICATION
-- Uses proper PostgreSQL information_schema columns

-- 1. Show all triggers with their actual table information
SELECT 
    'ALL_TRIGGERS' as section,
    trigger_schema,
    trigger_name,
    event_manipulation as event_type,
    action_timing as timing,
    action_condition,
    LEFT(action_statement, 100) as statement_preview
FROM information_schema.triggers
WHERE trigger_schema IN ('public', 'auth')
ORDER BY trigger_schema, trigger_name;

-- 2. Check specific expected triggers
SELECT 'EXPECTED_TRIGGERS_STATUS' as section;
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

-- 3. Show trigger details for deployed triggers
SELECT 'DEPLOYED_TRIGGER_DETAILS' as section;
SELECT 
    t.trigger_name,
    t.event_manipulation as event_type,
    t.action_timing as timing,
    CASE 
        WHEN t.action_statement LIKE '%INSERT%' THEN 'INSERT'
        WHEN t.action_statement LIKE '%UPDATE%' THEN 'UPDATE'
        WHEN t.action_statement LIKE '%DELETE%' THEN 'DELETE'
        ELSE 'OTHER'
    END as action_type,
    LEFT(t.action_statement, 200) as statement_preview
FROM information_schema.triggers t
WHERE t.trigger_schema IN ('public', 'auth')
    AND EXISTS (
        SELECT 1 FROM (VALUES 
            ('on_auth_user_created'), ('on_auth_user_updated'),
            ('handle_user_positions_updated_at'), ('trigger_set_position_maturity'),
            ('handle_investment_tiers_updated_at'), ('notification_settings_updated_at')
        ) AS expected(trigger_name) WHERE expected.trigger_name = t.trigger_name
    )
ORDER BY t.trigger_name;
