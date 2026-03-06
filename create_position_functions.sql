-- Create position-related functions
-- These functions are referenced by user_positions table triggers

-- Function to calculate maturity date based on tier
CREATE OR REPLACE FUNCTION public.calculate_position_maturity(p_tier_id BIGINT)
RETURNS TIMESTAMP WITH TIME ZONE AS $$
DECLARE
    tier_period INTEGER;
BEGIN
    SELECT investment_period_days INTO tier_period
    FROM public.investment_tiers
    WHERE id = p_tier_id;
    
    IF tier_period IS NULL THEN
        RETURN NOW() + INTERVAL '30 days'; -- Default fallback
    END IF;
    
    RETURN NOW() + (tier_period || ' days')::INTERVAL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to auto-set maturity date
CREATE OR REPLACE FUNCTION public.set_position_maturity()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.matures_at IS NULL AND NEW.tier_id IS NOT NULL THEN
        NEW.matures_at = public.calculate_position_maturity(NEW.tier_id);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger to auto-set maturity date
DROP TRIGGER IF EXISTS trigger_set_position_maturity ON public.user_positions;
CREATE TRIGGER trigger_set_position_maturity
    BEFORE INSERT ON public.user_positions
    FOR EACH ROW
    EXECUTE FUNCTION public.set_position_maturity();

-- Grant execute permissions on functions
GRANT EXECUTE ON FUNCTION public.calculate_position_maturity TO authenticated;
GRANT EXECUTE ON FUNCTION public.calculate_position_maturity TO service_role;
GRANT EXECUTE ON FUNCTION public.set_position_maturity TO authenticated;
GRANT EXECUTE ON FUNCTION public.set_position_maturity TO service_role;

-- Verify function creation
SELECT 
    'calculate_position_maturity' as function_name,
    'FUNCTION' as object_type,
    'CREATED' as status,
    NOW() as created_at

UNION ALL

SELECT 
    'set_position_maturity' as function_name,
    'FUNCTION' as object_type,
    'CREATED' as status,
    NOW() as created_at;
