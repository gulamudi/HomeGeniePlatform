-- Create app_settings table for configurable application settings
-- Allows changing settings without code deployment

CREATE TABLE public.app_settings (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    key TEXT NOT NULL UNIQUE CHECK (length(key) >= 2),
    value JSONB NOT NULL,
    category TEXT NOT NULL CHECK (category IN ('booking', 'notifications', 'location', 'payments', 'general')),
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes
CREATE INDEX idx_app_settings_key ON public.app_settings(key);
CREATE INDEX idx_app_settings_category ON public.app_settings(category);
CREATE INDEX idx_app_settings_active ON public.app_settings(is_active);

-- Add updated_at trigger
CREATE TRIGGER update_app_settings_updated_at
    BEFORE UPDATE ON public.app_settings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Enable RLS
ALTER TABLE public.app_settings ENABLE ROW LEVEL SECURITY;

-- Anyone can view active settings (needed for app configuration)
CREATE POLICY "Anyone can view active app settings" ON public.app_settings
    FOR SELECT USING (is_active = true);

-- Add comment
COMMENT ON TABLE public.app_settings IS 'Configurable application settings stored in database';

-- Helper function to get setting value
CREATE OR REPLACE FUNCTION public.get_setting(
    p_key TEXT,
    p_default JSONB DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
    v_value JSONB;
BEGIN
    SELECT value INTO v_value
    FROM public.app_settings
    WHERE key = p_key AND is_active = true;

    RETURN COALESCE(v_value, p_default);
END;
$$ LANGUAGE plpgsql STABLE;

-- Grant permissions
GRANT EXECUTE ON FUNCTION public.get_setting(TEXT, JSONB) TO authenticated, anon;

-- Insert default settings
INSERT INTO public.app_settings (key, value, category, description) VALUES
-- Booking settings
('booking.max_distance_km', '15', 'booking', 'Maximum distance (km) for partner assignment'),
('booking.cancellation_hours', '24', 'booking', 'Minimum hours before booking to allow cancellation'),
('booking.reschedule_hours', '12', 'booking', 'Minimum hours before booking to allow rescheduling'),

-- Notification settings
('notifications.batch_size', '5', 'notifications', 'Number of partners to notify per batch'),
('notifications.expiry_minutes', '30', 'notifications', 'Minutes before notification expires'),
('notifications.max_batches', '3', 'notifications', 'Maximum number of notification batches'),
('notifications.retry_delay_minutes', '5', 'notifications', 'Minutes to wait before next batch'),

-- Location settings
('location.default_radius_km', '10', 'location', 'Default search radius for partners'),
('location.max_radius_km', '25', 'location', 'Maximum allowed search radius'),

-- Partner ranking weights (0-100)
('ranking.weight_previous_customer', '30', 'booking', 'Weight for partners who worked with customer before'),
('ranking.weight_distance', '25', 'booking', 'Weight for partner distance from job'),
('ranking.weight_rating', '25', 'booking', 'Weight for partner rating'),
('ranking.weight_availability', '20', 'booking', 'Weight for partner online status and availability'),

-- General settings
('general.service_hours_start', '"08:00"', 'general', 'Service start time'),
('general.service_hours_end', '"20:00"', 'general', 'Service end time'),
('general.app_version', '"1.0.0"', 'general', 'Current app version'),
('general.timezone', '"Asia/Kolkata"', 'general', 'Application timezone for booking times (India)');

-- Log the change
DO $$
BEGIN
  RAISE NOTICE '✅ Created app_settings table with default configuration';
END $$;
