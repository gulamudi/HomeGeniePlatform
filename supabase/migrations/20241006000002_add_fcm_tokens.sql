-- Add table to track partner availability and online status
-- Used for smart partner assignment
CREATE TABLE public.partner_availability (
    partner_id UUID REFERENCES public.users(id) ON DELETE CASCADE PRIMARY KEY,
    is_online BOOLEAN DEFAULT false,
    is_accepting_jobs BOOLEAN DEFAULT true,
    last_seen TIMESTAMPTZ DEFAULT NOW(),
    current_location GEOGRAPHY(POINT, 4326),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index for location-based partner searches
CREATE INDEX idx_partner_availability_location ON public.partner_availability USING GIST(current_location);
CREATE INDEX idx_partner_availability_online ON public.partner_availability(is_online, is_accepting_jobs);

-- Add trigger for updated_at
CREATE TRIGGER update_partner_availability_updated_at
    BEFORE UPDATE ON public.partner_availability
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
