-- Migration script: Copy data from investment_tiers to investment_strategies
-- This script migrates from Investment Tiers to Investment Strategies

-- First, clear any existing data in the new table (in case of re-run)
TRUNCATE TABLE public.investment_strategies RESTART IDENTITY;

-- Insert the new investment strategies with data from existing tiers
INSERT INTO public.investment_strategies (
    name, 
    description, 
    asset_class,
    min_amount, 
    max_amount, 
    investment_period_days, 
    daily_roi, 
    sort_order, 
    features, 
    allocation_mix
) 
SELECT 
    CASE 
        WHEN t.name = 'Tier 1' THEN 'Global Equities Strategy'
        WHEN t.name = 'Tier 2' THEN 'Exchange-Traded Funds (ETF) Strategy'
        WHEN t.name = 'Tier 3' THEN 'Digital Assets & DeFi Strategy'
        WHEN t.name = 'Tier 4' THEN 'Real Assets – Real Estate Strategy'
        WHEN t.name = 'Tier 5' THEN 'Commodities & Natural Resources Strategy'
        ELSE t.name
    END as name,
    CASE 
        WHEN t.name = 'Tier 1' THEN 'Diversified global equity portfolio with exposure to developed and emerging markets.'
        WHEN t.name = 'Tier 2' THEN 'Indexed and thematic ETFs providing diversified exposure to various market segments.'
        WHEN t.name = 'Tier 3' THEN 'Digital assets and blockchain protocol investments for high-growth potential.'
        WHEN t.name = 'Tier 4' THEN 'Private real estate investments with stable income and capital appreciation.'
        WHEN t.name = 'Tier 5' THEN 'Precious metals and energy commodities for inflation hedging and diversification.'
        ELSE t.description
    END as description,
    CASE 
        WHEN t.name = 'Tier 1' THEN 'Public Markets – Equities'
        WHEN t.name = 'Tier 2' THEN 'Indexed & Thematic ETFs'
        WHEN t.name = 'Tier 3' THEN 'Digital Assets / Blockchain Protocols'
        WHEN t.name = 'Tier 4' THEN 'Private Real Estate'
        WHEN t.name = 'Tier 5' THEN 'Precious Metals & Energy'
        ELSE 'Traditional Markets'
    END as asset_class,
    t.min_amount,
    t.max_amount,
    t.investment_period_days,
    t.daily_roi,
    t.sort_order,
    t.features,
    t.allocation_mix
FROM public.investment_tiers t
WHERE t.is_active = true
ORDER BY t.sort_order;

-- Verify the migration
SELECT 
    'MIGRATION_VERIFICATION' as section,
    id,
    name,
    asset_class,
    min_amount,
    max_amount,
    investment_period_days,
    daily_roi,
    sort_order
FROM public.investment_strategies 
ORDER BY sort_order;

-- Show count of migrated records
SELECT 
    'MIGRATION_COUNT' as section,
    COUNT(*) as strategies_migrated
FROM public.investment_strategies;

-- Optional: Create a backup of the old table before making changes
-- CREATE TABLE investment_tiers_backup AS SELECT * FROM investment_tiers;

-- Optional: After successful migration, you might want to rename the old table
-- ALTER TABLE investment_tiers RENAME TO investment_tiers_deprecated;
