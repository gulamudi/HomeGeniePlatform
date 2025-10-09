-- Fix type mismatch in get_preferred_partners function
-- Cast v_service_category to service_category enum type

CREATE OR REPLACE FUNCTION public.get_preferred_partners(
    p_customer_id UUID,
    p_service_id UUID,
    p_scheduled_date TIMESTAMPTZ,
    p_duration_hours DECIMAL,
    p_limit INTEGER DEFAULT 3
)
RETURNS TABLE(
    partner_id UUID,
    partner_name TEXT,
    partner_phone TEXT,
    avatar_url TEXT,
    rating DECIMAL,
    total_jobs INTEGER,
    last_service_date TIMESTAMPTZ,
    services_count INTEGER,
    last_service_name TEXT
) AS $$
DECLARE
    v_service_category service_category;
BEGIN
    -- Get service category
    SELECT category INTO v_service_category
    FROM public.services
    WHERE id = p_service_id;

    IF v_service_category IS NULL THEN
        RAISE EXCEPTION 'Service not found: %', p_service_id;
    END IF;

    RETURN QUERY
    WITH customer_partner_history AS (
        -- Get all partners who have worked with this customer
        SELECT DISTINCT
            b.partner_id,
            MAX(b.scheduled_date) as last_service_date,
            COUNT(*) as services_count,
            (
                SELECT s.name
                FROM public.bookings b2
                INNER JOIN public.services s ON s.id = b2.service_id
                WHERE b2.customer_id = p_customer_id
                AND b2.partner_id = b.partner_id
                ORDER BY b2.scheduled_date DESC
                LIMIT 1
            ) as last_service_name
        FROM public.bookings b
        INNER JOIN public.services s ON s.id = b.service_id
        WHERE b.customer_id = p_customer_id
        AND b.partner_id IS NOT NULL
        AND b.status = 'completed'
        AND s.category = v_service_category
        GROUP BY b.partner_id
    ),
    available_partners AS (
        -- Check if these partners are available for the requested time
        SELECT
            cph.*,
            u.full_name,
            u.phone,
            u.avatar_url,
            pp.rating,
            pp.total_jobs,
            pp.verification_status,
            pp.availability,
            COALESCE(pa.is_accepting_jobs, true) as is_accepting_jobs
        FROM customer_partner_history cph
        INNER JOIN public.users u ON u.id = cph.partner_id
        INNER JOIN public.partner_profiles pp ON pp.user_id = cph.partner_id
        LEFT JOIN public.partner_availability pa ON pa.partner_id = cph.partner_id
        WHERE pp.verification_status = 'verified'
        AND v_service_category::text = ANY(pp.services)
        AND (pp.availability->>'isAvailable')::boolean = true
        -- Check no scheduling conflict
        AND NOT EXISTS(
            SELECT 1 FROM public.bookings b
            WHERE b.partner_id = cph.partner_id
            AND b.status IN ('confirmed', 'in_progress')
            AND (
                -- New booking starts during existing booking
                (p_scheduled_date >= b.scheduled_date
                    AND p_scheduled_date < b.scheduled_date + (b.duration_hours || ' hours')::interval)
                OR
                -- New booking ends during existing booking
                (p_scheduled_date + (p_duration_hours || ' hours')::interval > b.scheduled_date
                    AND p_scheduled_date + (p_duration_hours || ' hours')::interval <= b.scheduled_date + (b.duration_hours || ' hours')::interval)
                OR
                -- New booking completely overlaps existing booking
                (p_scheduled_date <= b.scheduled_date
                    AND p_scheduled_date + (p_duration_hours || ' hours')::interval >= b.scheduled_date + (b.duration_hours || ' hours')::interval)
            )
        )
    )
    SELECT
        ap.partner_id,
        ap.full_name as partner_name,
        ap.phone as partner_phone,
        ap.avatar_url,
        ap.rating,
        ap.total_jobs,
        ap.last_service_date,
        ap.services_count::INTEGER,
        ap.last_service_name
    FROM available_partners ap
    ORDER BY
        ap.services_count DESC,  -- More services with customer = higher priority
        ap.last_service_date DESC,  -- More recent service = higher priority
        ap.rating DESC  -- Higher rating = higher priority
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql STABLE;

-- Grant permissions
GRANT EXECUTE ON FUNCTION public.get_preferred_partners(UUID, UUID, TIMESTAMPTZ, DECIMAL, INTEGER) TO authenticated;

-- Add comment
COMMENT ON FUNCTION public.get_preferred_partners IS 'Returns partners who have completed services for this customer before, filtered by availability';

-- Log the change
DO $$
BEGIN
  RAISE NOTICE '✅ Fixed type mismatch in get_preferred_partners function';
END $$;
