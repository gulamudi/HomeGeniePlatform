-- Remove service_pricing_tiers table
-- Using simple base_price from services table instead of complex tiered pricing

-- Drop RLS policies
DROP POLICY IF EXISTS "Anyone can view pricing tiers for active services" ON public.service_pricing_tiers;

-- Drop triggers
DROP TRIGGER IF EXISTS update_service_pricing_tiers_updated_at ON public.service_pricing_tiers;

-- Drop the table (CASCADE will remove foreign key constraints)
DROP TABLE IF EXISTS public.service_pricing_tiers CASCADE;

-- Log the change
DO $$
BEGIN
  RAISE NOTICE '✅ Removed service_pricing_tiers table - Using services.base_price for pricing';
END $$;
