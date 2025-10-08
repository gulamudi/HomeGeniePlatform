-- Create a function to accept a job that bypasses RLS
-- This is a secure way to allow partners to accept jobs without complex RLS policies

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

    -- Delete notifications for OTHER partners (so they stop seeing this job offer)
    DELETE FROM notifications
    WHERE data->>'booking_id' = p_booking_id::text
    AND user_id != p_partner_id
    AND type = 'new_job_offer';

    -- Return success
    SELECT json_build_object(
        'success', true,
        'booking_id', p_booking_id,
        'partner_id', p_partner_id,
        'status', 'confirmed'
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
COMMENT ON FUNCTION public.accept_job IS 'Allows a partner to accept an unassigned job. Uses SECURITY DEFINER to bypass RLS policies.';
