-- Create service_areas table for location-based service coverage
-- Supports multiple cities and areas within each city

CREATE TABLE public.service_areas (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL CHECK (length(name) >= 2),
    city TEXT NOT NULL CHECK (length(city) >= 2),
    state TEXT NOT NULL DEFAULT 'Maharashtra',
    center_location GEOGRAPHY(POINT, 4326) NOT NULL,
    radius_km DECIMAL(5,2) NOT NULL CHECK (radius_km > 0 AND radius_km <= 50),
    is_active BOOLEAN DEFAULT true,
    display_order INTEGER DEFAULT 0,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX idx_service_areas_city ON public.service_areas(city);
CREATE INDEX idx_service_areas_active ON public.service_areas(is_active);
CREATE INDEX idx_service_areas_location ON public.service_areas USING GIST(center_location);
CREATE INDEX idx_service_areas_display_order ON public.service_areas(display_order);

-- Add updated_at trigger
CREATE TRIGGER update_service_areas_updated_at
    BEFORE UPDATE ON public.service_areas
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Enable RLS
ALTER TABLE public.service_areas ENABLE ROW LEVEL SECURITY;

-- Anyone can view active service areas (for area selection)
CREATE POLICY "Anyone can view active service areas" ON public.service_areas
    FOR SELECT USING (is_active = true);

-- Add comment
COMMENT ON TABLE public.service_areas IS 'Defines geographic areas where services are available';

-- Helper function to check if a location is within any service area
CREATE OR REPLACE FUNCTION public.is_location_serviced(
    p_lat DECIMAL,
    p_lng DECIMAL
)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.service_areas
        WHERE is_active = true
        AND ST_DWithin(
            center_location,
            ST_MakePoint(p_lng, p_lat)::geography,
            radius_km * 1000  -- Convert km to meters
        )
    );
END;
$$ LANGUAGE plpgsql;

-- Helper function to get nearest service area
CREATE OR REPLACE FUNCTION public.get_nearest_service_area(
    p_lat DECIMAL,
    p_lng DECIMAL
)
RETURNS TABLE(
    area_id UUID,
    area_name TEXT,
    city TEXT,
    distance_km DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        id,
        name,
        service_areas.city,
        ROUND((ST_Distance(
            center_location,
            ST_MakePoint(p_lng, p_lat)::geography
        ) / 1000)::numeric, 2) as distance_km
    FROM public.service_areas
    WHERE is_active = true
    ORDER BY center_location <-> ST_MakePoint(p_lng, p_lat)::geography
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- Grant permissions
GRANT EXECUTE ON FUNCTION public.is_location_serviced(DECIMAL, DECIMAL) TO authenticated, anon;
GRANT EXECUTE ON FUNCTION public.get_nearest_service_area(DECIMAL, DECIMAL) TO authenticated, anon;

-- Log the change
DO $$
BEGIN
  RAISE NOTICE '✅ Created service_areas table with location-based coverage';
END $$;
