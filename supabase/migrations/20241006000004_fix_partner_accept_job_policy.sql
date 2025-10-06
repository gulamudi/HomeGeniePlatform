-- Fix RLS policy to allow partners to accept unassigned jobs
-- The existing policy only allows partners to update bookings they're already assigned to
-- But when accepting a job, partner_id is NULL, so they need permission to claim it

-- Drop the old policy
DROP POLICY IF EXISTS "Partners can update assigned bookings" ON public.bookings;

-- Create new policy that allows partners to:
-- 1. Update bookings they're already assigned to
-- 2. Accept unassigned bookings (partner_id IS NULL and status = 'pending')
CREATE POLICY "Partners can update and accept bookings" ON public.bookings
    FOR UPDATE USING (
        partner_id = auth.uid()  -- Already assigned bookings
        OR (
            partner_id IS NULL   -- Unassigned bookings
            AND status = 'pending'
        )
    )
    WITH CHECK (
        partner_id = auth.uid()  -- Can only assign to themselves
    );

-- Also need to fix booking_timeline policy to allow partners to insert timeline entries
-- Partners can insert timeline entries for bookings they're assigned to OR when they're accepting a job
DROP POLICY IF EXISTS "Users can insert timeline for their bookings" ON public.booking_timeline;

CREATE POLICY "Users can insert timeline for their bookings" ON public.booking_timeline
    FOR INSERT WITH CHECK (
        -- Partner accepting a job (they are the one performing the action)
        (updated_by = auth.uid() AND updated_by_type = 'partner')
        OR
        -- Customer or partner updating their own booking
        EXISTS (
            SELECT 1 FROM public.bookings b
            WHERE b.id = booking_id
            AND (
                (b.customer_id = auth.uid() AND updated_by_type = 'customer')
                OR
                (b.partner_id = auth.uid() AND updated_by_type = 'partner')
            )
        )
    );
