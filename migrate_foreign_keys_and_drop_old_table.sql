-- Migration script: Update foreign key constraints from investment_tiers to investment_strategies
-- This will allow us to safely drop the old table

-- Step 1: Drop the old foreign key constraints
ALTER TABLE public.daily_autogrowth_log DROP CONSTRAINT IF EXISTS daily_autogrowth_log_tier_id_fkey;
ALTER TABLE public.user_positions DROP CONSTRAINT IF EXISTS user_positions_tier_id_fkey;

-- Step 2: Add new foreign key constraints pointing to investment_strategies
ALTER TABLE public.daily_autogrowth_log 
ADD CONSTRAINT daily_autogrowth_log_tier_id_fkey 
FOREIGN KEY (tier_id) REFERENCES public.investment_strategies(id) 
ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE public.user_positions 
ADD CONSTRAINT user_positions_tier_id_fkey 
FOREIGN KEY (tier_id) REFERENCES public.investment_strategies(id) 
ON DELETE CASCADE ON UPDATE CASCADE;

-- Step 3: Now we can safely drop the old table
DROP TABLE IF EXISTS public.investment_tiers;

-- Step 4: Verify the migration worked
SELECT 
    'investment_strategies' as table_name,
    COUNT(*) as record_count
FROM public.investment_strategies 
WHERE is_active = true

UNION ALL

SELECT 
    'investment_tiers' as table_name,
    COUNT(*) as record_count
FROM public.investment_tiers;
