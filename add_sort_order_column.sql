-- Quick fix: Add missing sort_order column to investment_tiers table
ALTER TABLE public.investment_tiers ADD COLUMN IF NOT EXISTS sort_order INTEGER NOT NULL DEFAULT 0;

-- Verify the column was added
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public' 
    AND table_name = 'investment_tiers'
    AND column_name = 'sort_order';
