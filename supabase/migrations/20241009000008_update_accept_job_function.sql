-- Update accept_job function to work with job_notifications system
-- Cancels all other notifications when a partner accepts a job

CREATE OR REPLACE FUNCTION public.accept_job(
    p_booking_id UUID,
    p_partner_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER -- This allows the function to bypass RLS
SET search_path = public
AS $$
DECLARE
    v_result JSON;
    v_cancelled_count INTEGER;
BEGIN
    -- Verify the caller is the partner (security check)
    IF auth.uid() != p_partner_id THEN
        RAISE EXCEPTION 'Unauthorized: You can only accept jobs for yourself';
    END IF;

    -- Verify the booking exists and is pending
    IF NOT EXISTS (
        SELECT 1 FROM bookings
        WHERE id = p_booking_id
        AND status = 'pending'
        AND partner_id IS NULL
    ) THEN
        RAISE EXCEPTION 'Booking not found or already assigned';
    END IF;

    -- Update the booking
    UPDATE bookings
    SET
        partner_id = p_partner_id,
        status = 'confirmed',
        updated_at = NOW()
    WHERE id = p_booking_id;

    -- Insert timeline entry
    INSERT INTO booking_timeline (
        booking_id,
        status,
        updated_by,
        updated_by_type,
        notes
    ) VALUES (
        p_booking_id,
        'confirmed',
        p_partner_id,
        'partner',
        'Job accepted by partner'
    );

    -- Mark this partner's notification as accepted
    UPDATE job_notifications
    SET status = 'accepted',
        updated_at = NOW()
    WHERE booking_id = p_booking_id
    AND partner_id = p_partner_id
    AND status = 'pending';

    -- Cancel all other job notifications for this booking
    SELECT cancel_job_notifications(p_booking_id, p_partner_id) INTO v_cancelled_count;

    -- Return success
    SELECT json_build_object(
        'success', true,
        'booking_id', p_booking_id,
        'partner_id', p_partner_id,
        'status', 'confirmed',
        'cancelled_notifications', v_cancelled_count
    ) INTO v_result;

    RETURN v_result;

EXCEPTION WHEN OTHERS THEN
    -- Return error
    RETURN json_build_object(
        'success', false,
        'error', SQLERRM
    );
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.accept_job(UUID, UUID) TO authenticated;

-- Add comment
COMMENT ON FUNCTION public.accept_job IS 'Allows a partner to accept an unassigned job. Uses SECURITY DEFINER to bypass RLS policies. Cancels all other notifications.';

-- Log the change
DO $$
BEGIN
  RAISE NOTICE '✅ Updated accept_job function to work with job_notifications system';
END $$;
