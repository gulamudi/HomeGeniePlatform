-- Enable Realtime for notifications table
-- This allows the notifications table to broadcast changes via WebSocket

-- First, ensure the publication exists (it should be created by default)
-- If not, this will create it
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime'
  ) THEN
    CREATE PUBLICATION supabase_realtime;
  END IF;
END $$;

-- Drop table from publication if it exists, then add it (ensures clean state)
DO $$
BEGIN
  -- Try to drop the table from publication (ignore errors if it doesn't exist)
  BEGIN
    ALTER PUBLICATION supabase_realtime DROP TABLE notifications;
  EXCEPTION
    WHEN OTHERS THEN
      -- Table wasn't in publication or publication doesn't exist, that's fine
      RAISE NOTICE 'Table not in publication or publication does not exist yet';
  END;

  -- Add notifications table to the realtime publication
  BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE notifications;
    RAISE NOTICE 'Added notifications table to supabase_realtime publication';
  EXCEPTION
    WHEN duplicate_object THEN
      -- Table already in publication, that's fine
      RAISE NOTICE 'Table already in publication';
  END;
END $$;

-- Grant necessary permissions for realtime
-- The authenticated role needs to be able to listen to changes
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT SELECT ON public.notifications TO anon, authenticated;

-- Ensure the RLS policy allows SELECT for realtime
-- The existing policy "Users can view their own notifications" should handle this
-- But let's verify it's working correctly by recreating it if needed

-- Drop and recreate the SELECT policy to ensure it works with Realtime
DROP POLICY IF EXISTS "Users can view their own notifications" ON public.notifications;

CREATE POLICY "Users can view their own notifications"
ON public.notifications
FOR SELECT
TO authenticated
USING (user_id = auth.uid());

-- Also allow service_role to insert notifications (for edge functions)
DROP POLICY IF EXISTS "Service role can insert notifications" ON public.notifications;

CREATE POLICY "Service role can insert notifications"
ON public.notifications
FOR INSERT
TO service_role
WITH CHECK (true);

-- Log the configuration
DO $$
BEGIN
  RAISE NOTICE 'Realtime enabled for notifications table';
  RAISE NOTICE 'RLS policies updated for authenticated users';
END $$;
