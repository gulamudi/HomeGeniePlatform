-- Change notification expiry from minutes to seconds for finer control
-- Update app settings to use seconds instead

-- Update existing settings
UPDATE public.app_settings
SET
    value = '30',  -- 30 seconds for testing (was 30 minutes)
    description = 'Seconds before notification expires and moves to next batch'
WHERE key = 'notifications.expiry_minutes';

-- Rename the key to be more accurate
UPDATE public.app_settings
SET key = 'notifications.expiry_seconds'
WHERE key = 'notifications.expiry_minutes';

-- Update retry delay to seconds
UPDATE public.app_settings
SET
    value = '60',  -- 1 minute between batches
    key = 'notifications.retry_delay_seconds',
    description = 'Seconds to wait before sending next batch'
WHERE key = 'notifications.retry_delay_minutes';

-- Add a helper to quickly change expiry time
INSERT INTO public.app_settings (key, value, category, description) VALUES
('notifications.expiry_mode', '"testing"', 'notifications', 'Mode: "testing" (30s) or "production" (1800s/30min)')
ON CONFLICT (key) DO UPDATE SET value = '"testing"';

-- Log the change
DO $$
BEGIN
  RAISE NOTICE '✅ Changed notification expiry to seconds';
  RAISE NOTICE '   Testing mode: 30 seconds';
  RAISE NOTICE '   Production mode: 1800 seconds (30 minutes)';
  RAISE NOTICE '   Update app_settings to switch modes';
END $$;
