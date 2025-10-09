-- Partner ranking function for smart job assignment
-- Scores partners based on: previous customer work, distance, rating, availability

CREATE OR REPLACE FUNCTION public.rank_partners_for_booking(
    p_booking_id UUID
)
RETURNS TABLE(
    partner_id UUID,
    partner_name TEXT,
    partner_phone TEXT,
    partner_rating DECIMAL,
    total_jobs INTEGER,
    distance_km DECIMAL,
    rank_score DECIMAL,
    worked_with_customer BOOLEAN,
    is_online BOOLEAN,
    score_breakdown JSONB
) AS $$
DECLARE
    v_booking RECORD;
    v_service RECORD;
    v_weights RECORD;
BEGIN
    -- Get booking details
    SELECT
        b.id,
        b.customer_id,
        b.service_id,
        b.location,
        b.scheduled_date,
        b.duration_hours,
        s.category
    INTO v_booking
    FROM public.bookings b
    INNER JOIN public.services s ON s.id = b.service_id
    WHERE b.id = p_booking_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Booking not found: %', p_booking_id;
    END IF;

    -- Get ranking weights from settings
    SELECT
        COALESCE((get_setting('ranking.weight_previous_customer')::text)::decimal, 30) as previous_customer_weight,
        COALESCE((get_setting('ranking.weight_distance')::text)::decimal, 25) as distance_weight,
        COALESCE((get_setting('ranking.weight_rating')::text)::decimal, 25) as rating_weight,
        COALESCE((get_setting('ranking.weight_availability')::text)::decimal, 20) as availability_weight,
        COALESCE((get_setting('booking.max_distance_km')::text)::decimal, 15) as max_distance_km
    INTO v_weights;

    RETURN QUERY
    WITH partner_details AS (
        SELECT
            u.id as partner_id,
            u.full_name as partner_name,
            u.phone as partner_phone,
            pp.rating as partner_rating,
            pp.total_jobs,
            pp.availability,
            COALESCE(pa.is_online, false) as is_online,
            COALESCE(pa.is_accepting_jobs, true) as is_accepting_jobs,
            pa.current_location,
            pp.verification_status,
            pp.services as partner_services
        FROM public.users u
        INNER JOIN public.partner_profiles pp ON pp.user_id = u.id
        LEFT JOIN public.partner_availability pa ON pa.partner_id = u.id
        WHERE u.user_type = 'partner'
        AND pp.verification_status = 'verified'
        AND v_booking.category = ANY(pp.services)
        AND (pp.availability->>'isAvailable')::boolean = true
    ),
    partner_scores AS (
        SELECT
            pd.*,
            -- Calculate distance (if both locations available)
            CASE
                WHEN v_booking.location IS NOT NULL AND pd.current_location IS NOT NULL
                THEN ROUND((ST_Distance(
                    v_booking.location,
                    pd.current_location
                ) / 1000)::numeric, 2)
                ELSE NULL
            END as distance_km,

            -- Check if worked with customer before
            EXISTS(
                SELECT 1 FROM public.bookings b
                WHERE b.customer_id = v_booking.customer_id
                AND b.partner_id = pd.partner_id
                AND b.status = 'completed'
            ) as worked_with_customer,

            -- Check for overlapping bookings
            NOT EXISTS(
                SELECT 1 FROM public.bookings b
                WHERE b.partner_id = pd.partner_id
                AND b.status IN ('confirmed', 'in_progress')
                AND (
                    -- New booking starts during existing booking
                    (v_booking.scheduled_date >= b.scheduled_date
                        AND v_booking.scheduled_date < b.scheduled_date + (b.duration_hours || ' hours')::interval)
                    OR
                    -- New booking ends during existing booking
                    (v_booking.scheduled_date + (v_booking.duration_hours || ' hours')::interval > b.scheduled_date
                        AND v_booking.scheduled_date + (v_booking.duration_hours || ' hours')::interval <= b.scheduled_date + (b.duration_hours || ' hours')::interval)
                    OR
                    -- New booking completely overlaps existing booking
                    (v_booking.scheduled_date <= b.scheduled_date
                        AND v_booking.scheduled_date + (v_booking.duration_hours || ' hours')::interval >= b.scheduled_date + (b.duration_hours || ' hours')::interval)
                )
            ) as is_available_time_slot
        FROM partner_details pd
    ),
    scored_partners AS (
        SELECT
            ps.*,
            -- Score: Previous customer work (0-30 points)
            CASE WHEN ps.worked_with_customer THEN v_weights.previous_customer_weight ELSE 0 END as score_previous,

            -- Score: Distance (0-25 points) - closer is better
            CASE
                WHEN ps.distance_km IS NULL THEN 0
                WHEN ps.distance_km <= 2 THEN v_weights.distance_weight
                WHEN ps.distance_km <= 5 THEN v_weights.distance_weight * 0.8
                WHEN ps.distance_km <= 10 THEN v_weights.distance_weight * 0.6
                WHEN ps.distance_km <= v_weights.max_distance_km THEN v_weights.distance_weight * 0.4
                ELSE 0
            END as score_distance,

            -- Score: Rating (0-25 points)
            CASE
                WHEN ps.partner_rating >= 4.5 THEN v_weights.rating_weight
                WHEN ps.partner_rating >= 4.0 THEN v_weights.rating_weight * 0.8
                WHEN ps.partner_rating >= 3.5 THEN v_weights.rating_weight * 0.6
                WHEN ps.partner_rating >= 3.0 THEN v_weights.rating_weight * 0.4
                ELSE v_weights.rating_weight * 0.2
            END as score_rating,

            -- Score: Availability (0-20 points)
            CASE
                WHEN ps.is_online AND ps.is_accepting_jobs AND ps.is_available_time_slot THEN v_weights.availability_weight
                WHEN ps.is_accepting_jobs AND ps.is_available_time_slot THEN v_weights.availability_weight * 0.7
                WHEN ps.is_available_time_slot THEN v_weights.availability_weight * 0.5
                ELSE 0
            END as score_availability
        FROM partner_scores ps
        WHERE ps.is_available_time_slot = true -- Only include partners with no scheduling conflict
        AND (ps.distance_km IS NULL OR ps.distance_km <= v_weights.max_distance_km) -- Within max distance
    )
    SELECT
        sp.partner_id,
        sp.partner_name,
        sp.partner_phone,
        sp.partner_rating,
        sp.total_jobs,
        sp.distance_km,
        ROUND((sp.score_previous + sp.score_distance + sp.score_rating + sp.score_availability)::numeric, 2) as rank_score,
        sp.worked_with_customer,
        sp.is_online,
        jsonb_build_object(
            'previous_customer', sp.score_previous,
            'distance', sp.score_distance,
            'rating', sp.score_rating,
            'availability', sp.score_availability
        ) as score_breakdown
    FROM scored_partners sp
    ORDER BY rank_score DESC, sp.partner_rating DESC, sp.distance_km ASC NULLS LAST;
END;
$$ LANGUAGE plpgsql STABLE;

-- Grant permissions
GRANT EXECUTE ON FUNCTION public.rank_partners_for_booking(UUID) TO service_role, authenticated;

-- Add comment
COMMENT ON FUNCTION public.rank_partners_for_booking IS 'Ranks partners for a booking based on multiple criteria: previous work, distance, rating, availability';

-- Log the change
DO $$
BEGIN
  RAISE NOTICE '✅ Created partner ranking function with smart scoring algorithm';
END $$;
