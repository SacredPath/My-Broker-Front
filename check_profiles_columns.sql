-- Check the exact structure of the profiles table
SELECT 
    column_name,
    ordinal_position,
    column_default,
    is_nullable,
    data_type,
    character_maximum_length,
    numeric_precision,
    numeric_scale
FROM information_schema.columns 
WHERE table_schema = 'public'
    AND table_name = 'profiles'
ORDER BY ordinal_position;
