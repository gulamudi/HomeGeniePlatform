-- Create job_notifications table for batch notification system
-- Tracks which partners were notified for each job and when

CREATE TABLE public.job_notifications (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    booking_id UUID REFERENCES public.bookings(id) ON DELETE CASCADE NOT NULL,
    partner_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    notification_id UUID REFERENCES public.notifications(id) ON DELETE SET NULL,
    batch_number INTEGER NOT NULL CHECK (batch_number > 0 AND batch_number <= 10),
    rank_score DECIMAL(5,2) CHECK (rank_score >= 0 AND rank_score <= 100),
    sent_at TIMESTAMPTZ DEFAULT NOW(),
    expires_at TIMESTAMPTZ NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('pending', 'expired', 'accepted', 'rejected', 'cancelled')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    -- Ensure one notification per partner per booking
    CONSTRAINT unique_booking_partner UNIQUE (booking_id, partner_id)
);

-- Create indexes for performance
CREATE INDEX idx_job_notifications_booking_id ON public.job_notifications(booking_id);
CREATE INDEX idx_job_notifications_partner_id ON public.job_notifications(partner_id);
CREATE INDEX idx_job_notifications_status ON public.job_notifications(status);
CREATE INDEX idx_job_notifications_expires_at ON public.job_notifications(expires_at) WHERE status = 'pending';
CREATE INDEX idx_job_notifications_batch ON public.job_notifications(booking_id, batch_number);

-- Add updated_at trigger
CREATE TRIGGER update_job_notifications_updated_at
    BEFORE UPDATE ON public.job_notifications
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Enable RLS
ALTER TABLE public.job_notifications ENABLE ROW LEVEL SECURITY;

-- Partners can view their own notifications
CREATE POLICY "Partners can view their own job notifications" ON public.job_notifications
    FOR SELECT USING (partner_id = auth.uid());

-- Service role can manage all notifications
CREATE POLICY "Service role can manage job notifications" ON public.job_notifications
    FOR ALL TO service_role
    USING (true)
    WITH CHECK (true);

-- Add comment
COMMENT ON TABLE public.job_notifications IS 'Tracks batch notifications sent to partners for job offers with expiry';

-- Function to get expired notifications that need next batch
CREATE OR REPLACE FUNCTION public.get_expired_job_notifications()
RETURNS TABLE(
    booking_id UUID,
    current_batch INTEGER,
    notification_count INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        jn.booking_id,
        jn.batch_number as current_batch,
        COUNT(*)::INTEGER as notification_count
    FROM public.job_notifications jn
    INNER JOIN public.bookings b ON b.id = jn.booking_id
    WHERE jn.status = 'pending'
    AND jn.expires_at < NOW()
    AND b.status = 'pending'
    AND b.partner_id IS NULL
    GROUP BY jn.booking_id, jn.batch_number;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to mark expired notifications
CREATE OR REPLACE FUNCTION public.mark_expired_notifications()
RETURNS INTEGER AS $$
DECLARE
    updated_count INTEGER;
BEGIN
    UPDATE public.job_notifications
    SET status = 'expired',
        updated_at = NOW()
    WHERE status = 'pending'
    AND expires_at < NOW();

    GET DIAGNOSTICS updated_count = ROW_COUNT;
    RETURN updated_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to cancel all notifications for a booking
CREATE OR REPLACE FUNCTION public.cancel_job_notifications(
    p_booking_id UUID,
    p_except_partner_id UUID DEFAULT NULL
)
RETURNS INTEGER AS $$
DECLARE
    cancelled_count INTEGER;
BEGIN
    -- Cancel pending notifications for this booking
    UPDATE public.job_notifications
    SET status = 'cancelled',
        updated_at = NOW()
    WHERE booking_id = p_booking_id
    AND status = 'pending'
    AND (p_except_partner_id IS NULL OR partner_id != p_except_partner_id);

    GET DIAGNOSTICS cancelled_count = ROW_COUNT;

    -- Delete corresponding notifications from notifications table
    DELETE FROM public.notifications
    WHERE data->>'booking_id' = p_booking_id::text
    AND type = 'new_job_offer'
    AND (p_except_partner_id IS NULL OR user_id != p_except_partner_id);

    RETURN cancelled_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant permissions
GRANT EXECUTE ON FUNCTION public.get_expired_job_notifications() TO service_role;
GRANT EXECUTE ON FUNCTION public.mark_expired_notifications() TO service_role;
GRANT EXECUTE ON FUNCTION public.cancel_job_notifications(UUID, UUID) TO service_role, authenticated;

-- Log the change
DO $$
BEGIN
  RAISE NOTICE '✅ Created job_notifications table with batch notification system';
END $$;
