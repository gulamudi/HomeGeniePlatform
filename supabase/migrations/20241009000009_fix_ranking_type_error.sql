-- Fix partner ranking function - type error with service_category enum
-- Cast enum to text when comparing with text array

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
    v_partner_log RECORD;
    v_count INTEGER;
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

    RAISE NOTICE '🔍 [rank_partners] Booking ID: %', p_booking_id;
    RAISE NOTICE '   Service category: %', v_booking.category;
    RAISE NOTICE '   Customer ID: %', v_booking.customer_id;
    RAISE NOTICE '   Scheduled: %', v_booking.scheduled_date;

    -- Get ranking weights from settings
    SELECT
        COALESCE((get_setting('ranking.weight_previous_customer')::text)::decimal, 30) as previous_customer_weight,
        COALESCE((get_setting('ranking.weight_distance')::text)::decimal, 25) as distance_weight,
        COALESCE((get_setting('ranking.weight_rating')::text)::decimal, 25) as rating_weight,
        COALESCE((get_setting('ranking.weight_availability')::text)::decimal, 20) as availability_weight,
        COALESCE((get_setting('booking.max_distance_km')::text)::decimal, 15) as max_distance_km
    INTO v_weights;

    RAISE NOTICE '⚙️ [rank_partners] Ranking weights:';
    RAISE NOTICE '   Previous customer: % pts', v_weights.previous_customer_weight;
    RAISE NOTICE '   Distance: % pts', v_weights.distance_weight;
    RAISE NOTICE '   Rating: % pts', v_weights.rating_weight;
    RAISE NOTICE '   Availability: % pts', v_weights.availability_weight;
    RAISE NOTICE '   Max distance: % km', v_weights.max_distance_km;

    -- Log ALL partners with their filter status
    RAISE NOTICE '🔍 [rank_partners] Checking all partners...';
    RAISE NOTICE '';

    -- Log each partner and why they pass/fail filters
    FOR v_partner_log IN (
        SELECT
            u.full_name,
            u.user_type,
            pp.verification_status,
            pp.services,
            pp.availability,
            CASE
                WHEN u.user_type != 'partner' THEN 'EXCLUDED: Not a partner user'
                WHEN pp.verification_status IS NULL THEN 'EXCLUDED: No partner profile'
                WHEN pp.verification_status != 'verified' THEN 'EXCLUDED: Not verified (status: ' || pp.verification_status || ')'
                WHEN NOT (v_booking.category::text = ANY(pp.services)) THEN 'EXCLUDED: Service category "' || v_booking.category || '" not in services'
                WHEN NOT (pp.availability->>'isAvailable')::boolean THEN 'EXCLUDED: Not available (availability flag)'
                ELSE 'PASSED: Initial filters'
            END as filter_status
        FROM public.users u
        LEFT JOIN public.partner_profiles pp ON pp.user_id = u.id
        WHERE u.user_type = 'partner'
    ) LOOP
        RAISE NOTICE '   • % - %', v_partner_log.full_name, v_partner_log.filter_status;
    END LOOP;

    RAISE NOTICE '';
    RAISE NOTICE '📊 [rank_partners] Checking distance and time slot availability...';
    RAISE NOTICE '';

    -- Log partners that passed initial filters but may fail distance/time checks
    FOR v_partner_log IN (
        WITH initial_pass AS (
            SELECT
                u.id as partner_id,
                u.full_name as partner_name,
                pp.availability,
                pa.current_location,
                -- Calculate distance
                CASE
                    WHEN v_booking.location IS NOT NULL AND pa.current_location IS NOT NULL
                    THEN ROUND((ST_Distance(v_booking.location, pa.current_location) / 1000)::numeric, 2)
                    ELSE NULL
                END as distance_km,
                -- Check time slot
                NOT EXISTS(
                    SELECT 1 FROM public.bookings b
                    WHERE b.partner_id = u.id
                    AND b.status IN ('confirmed', 'in_progress')
                    AND (
                        (v_booking.scheduled_date >= b.scheduled_date
                            AND v_booking.scheduled_date < b.scheduled_date + (b.duration_hours || ' hours')::interval)
                        OR
                        (v_booking.scheduled_date + (v_booking.duration_hours || ' hours')::interval > b.scheduled_date
                            AND v_booking.scheduled_date + (v_booking.duration_hours || ' hours')::interval <= b.scheduled_date + (b.duration_hours || ' hours')::interval)
                        OR
                        (v_booking.scheduled_date <= b.scheduled_date
                            AND v_booking.scheduled_date + (v_booking.duration_hours || ' hours')::interval >= b.scheduled_date + (b.duration_hours || ' hours')::interval)
                    )
                ) as is_available_time_slot
            FROM public.users u
            INNER JOIN public.partner_profiles pp ON pp.user_id = u.id
            LEFT JOIN public.partner_availability pa ON pa.partner_id = u.id
            WHERE u.user_type = 'partner'
            AND pp.verification_status = 'verified'
            AND v_booking.category::text = ANY(pp.services)
            AND (pp.availability->>'isAvailable')::boolean = true
        )
        SELECT
            partner_name,
            distance_km,
            is_available_time_slot,
            CASE
                WHEN NOT is_available_time_slot THEN 'EXCLUDED: Time slot conflict with existing booking'
                WHEN distance_km IS NOT NULL AND distance_km > v_weights.max_distance_km THEN 'EXCLUDED: Too far (>' || v_weights.max_distance_km || 'km)'
                WHEN distance_km IS NULL THEN 'INCLUDED: No location data (will rank lower)'
                ELSE 'INCLUDED: ' || distance_km || 'km away'
            END as status
        FROM initial_pass
    ) LOOP
        RAISE NOTICE '   • % - %', v_partner_log.partner_name, v_partner_log.status;
    END LOOP;

    RAISE NOTICE '';

    RETURN QUERY
    WITH all_partners AS (
        SELECT
            u.id as partner_id,
            u.full_name as partner_name,
            u.user_type,
            pp.verification_status,
            pp.services as partner_services,
            pp.availability,
            pp.rating as partner_rating,
            pp.total_jobs,
            u.phone as partner_phone,
            COALESCE(pa.is_online, false) as is_online,
            COALESCE(pa.is_accepting_jobs, true) as is_accepting_jobs,
            pa.current_location
        FROM public.users u
        INNER JOIN public.partner_profiles pp ON pp.user_id = u.id
        LEFT JOIN public.partner_availability pa ON pa.partner_id = u.id
        WHERE u.user_type = 'partner'
    ),
    partner_details AS (
        SELECT *
        FROM all_partners
        WHERE verification_status = 'verified'
        AND v_booking.category::text = ANY(partner_services)  -- FIX: Cast enum to text
        AND (availability->>'isAvailable')::boolean = true
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
            'availability', sp.score_availability,
            'total_score', ROUND((sp.score_previous + sp.score_distance + sp.score_rating + sp.score_availability)::numeric, 2)
        ) as score_breakdown
    FROM scored_partners sp
    ORDER BY rank_score DESC, sp.partner_rating DESC, sp.distance_km ASC NULLS LAST;
END;
$$ LANGUAGE plpgsql STABLE;

-- Log the fix
DO $$
BEGIN
  RAISE NOTICE '✅ Fixed partner ranking function - cast service_category enum to text';
END $$;
