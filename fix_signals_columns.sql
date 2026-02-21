-- Add missing columns to signals table
-- This fixes signals API errors

ALTER TABLE signals 
ADD COLUMN IF NOT EXISTS category TEXT;

ALTER TABLE signals 
ADD COLUMN IF NOT EXISTS risk_level TEXT;

-- Verify columns were added
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'signals' 
    AND table_schema = 'public'
    AND column_name IN ('category', 'risk_level')
ORDER BY column_name;
