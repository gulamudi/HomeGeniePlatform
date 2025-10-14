-- Migration: Admin Database Functions
-- Description: Create database functions for admin CRUD operations
-- Date: 2024-10-14

-- Function 1: Get Dashboard Stats
CREATE OR REPLACE FUNCTION public.get_dashboard_stats()
RETURNS TABLE (
    active_bookings BIGINT,
    pending_verifications BIGINT,
    total_clients BIGINT,
    active_partners BIGINT
) AS $$
BEGIN
    -- Check if admin
    IF NOT public.is_admin() THEN
        RAISE EXCEPTION 'Unauthorized: Only admins can view dashboard stats';
    END IF;

    RETURN QUERY
    SELECT
        (SELECT COUNT(*) FROM public.bookings WHERE status IN ('pending', 'confirmed', 'in_progress'))::BIGINT AS active_bookings,
        (SELECT COUNT(*) FROM public.partner_profiles WHERE verification_status = 'pending')::BIGINT AS pending_verifications,
        (SELECT COUNT(*) FROM public.users WHERE user_type = 'customer')::BIGINT AS total_clients,
        (SELECT COUNT(*) FROM public.partner_profiles WHERE verification_status = 'verified')::BIGINT AS active_partners;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function 2: Admin Create Customer Profile
CREATE OR REPLACE FUNCTION public.admin_create_customer_profile(
    p_phone TEXT,
    p_first_name TEXT,
    p_last_name TEXT,
    p_email TEXT DEFAULT NULL,
    p_admin_id UUID DEFAULT auth.uid()
)
RETURNS UUID AS $$
DECLARE
    new_user_id UUID;
    existing_user UUID;
BEGIN
    -- Check if admin
    IF NOT public.is_admin() THEN
        RAISE EXCEPTION 'Unauthorized: Only admins can create customer profiles';
    END IF;

    -- Validate inputs
    IF p_phone IS NULL OR length(trim(p_phone)) < 10 THEN
        RAISE EXCEPTION 'Invalid phone number';
    END IF;

    IF p_first_name IS NULL OR length(trim(p_first_name)) < 2 THEN
        RAISE EXCEPTION 'Invalid first name';
    END IF;

    IF p_last_name IS NULL OR length(trim(p_last_name)) < 2 THEN
        RAISE EXCEPTION 'Invalid last name';
    END IF;

    -- Check if user already exists with this phone
    SELECT id INTO existing_user FROM public.users WHERE phone = p_phone;

    IF existing_user IS NOT NULL THEN
        RAISE EXCEPTION 'User with phone % already exists', p_phone;
    END IF;

    -- Create placeholder user_id
    new_user_id := gen_random_uuid();

    -- Create user record (without auth linkage yet)
    INSERT INTO public.users (id, phone, email, full_name, user_type)
    VALUES (new_user_id, p_phone, p_email, trim(p_first_name) || ' ' || trim(p_last_name), 'customer');

    -- Create customer profile with pending_phone for later linkage
    INSERT INTO public.customer_profiles (user_id, created_by_admin, pending_phone)
    VALUES (new_user_id, p_admin_id, p_phone);

    -- Log action
    INSERT INTO public.admin_actions_log (admin_id, action_type, target_type, target_id, description, metadata)
    VALUES (
        p_admin_id,
        'CREATE',
        'customer',
        new_user_id,
        'Created customer profile for ' || p_phone,
        jsonb_build_object('phone', p_phone, 'name', trim(p_first_name) || ' ' || trim(p_last_name))
    );

    RETURN new_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function 3: Admin Create Partner Profile
CREATE OR REPLACE FUNCTION public.admin_create_partner_profile(
    p_phone TEXT,
    p_first_name TEXT,
    p_last_name TEXT,
    p_email TEXT DEFAULT NULL,
    p_services TEXT[] DEFAULT '{}',
    p_admin_id UUID DEFAULT auth.uid()
)
RETURNS UUID AS $$
DECLARE
    new_user_id UUID;
    existing_user UUID;
BEGIN
    -- Check if admin
    IF NOT public.is_admin() THEN
        RAISE EXCEPTION 'Unauthorized: Only admins can create partner profiles';
    END IF;

    -- Validate inputs
    IF p_phone IS NULL OR length(trim(p_phone)) < 10 THEN
        RAISE EXCEPTION 'Invalid phone number';
    END IF;

    IF p_first_name IS NULL OR length(trim(p_first_name)) < 2 THEN
        RAISE EXCEPTION 'Invalid first name';
    END IF;

    IF p_last_name IS NULL OR length(trim(p_last_name)) < 2 THEN
        RAISE EXCEPTION 'Invalid last name';
    END IF;

    -- Check if user already exists with this phone
    SELECT id INTO existing_user FROM public.users WHERE phone = p_phone;

    IF existing_user IS NOT NULL THEN
        RAISE EXCEPTION 'User with phone % already exists', p_phone;
    END IF;

    -- Create placeholder user_id
    new_user_id := gen_random_uuid();

    -- Create user record
    INSERT INTO public.users (id, phone, email, full_name, user_type)
    VALUES (new_user_id, p_phone, p_email, trim(p_first_name) || ' ' || trim(p_last_name), 'partner');

    -- Create partner profile
    INSERT INTO public.partner_profiles (
        user_id,
        created_by_admin,
        pending_phone,
        services,
        verification_status
    )
    VALUES (
        new_user_id,
        p_admin_id,
        p_phone,
        p_services,
        'pending'
    );

    -- Log action
    INSERT INTO public.admin_actions_log (admin_id, action_type, target_type, target_id, description, metadata)
    VALUES (
        p_admin_id,
        'CREATE',
        'partner',
        new_user_id,
        'Created partner profile for ' || p_phone,
        jsonb_build_object('phone', p_phone, 'name', trim(p_first_name) || ' ' || trim(p_last_name), 'services', p_services)
    );

    RETURN new_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function 4: Admin Create Booking
CREATE OR REPLACE FUNCTION public.admin_create_booking(
    p_customer_id UUID,
    p_service_id UUID,
    p_scheduled_date TIMESTAMPTZ,
    p_duration_hours DECIMAL,
    p_address JSONB,
    p_payment_method payment_method,
    p_total_amount DECIMAL,
    p_special_instructions TEXT DEFAULT NULL,
    p_preferred_partner_id UUID DEFAULT NULL,
    p_admin_id UUID DEFAULT auth.uid()
)
RETURNS UUID AS $$
DECLARE
    new_booking_id UUID;
    customer_user_type TEXT;
BEGIN
    -- Check if admin
    IF NOT public.is_admin() THEN
        RAISE EXCEPTION 'Unauthorized: Only admins can create bookings on behalf of customers';
    END IF;

    -- Verify customer exists and is customer type
    SELECT user_type INTO customer_user_type FROM public.users WHERE id = p_customer_id;

    IF customer_user_type IS NULL THEN
        RAISE EXCEPTION 'Customer not found';
    END IF;

    IF customer_user_type != 'customer' THEN
        RAISE EXCEPTION 'User is not a customer';
    END IF;

    -- Create booking (admin can bypass future date check)
    INSERT INTO public.bookings (
        customer_id,
        service_id,
        scheduled_date,
        duration_hours,
        address,
        payment_method,
        total_amount,
        special_instructions,
        preferred_partner_id,
        status
    )
    VALUES (
        p_customer_id,
        p_service_id,
        p_scheduled_date,
        p_duration_hours,
        p_address,
        p_payment_method,
        p_total_amount,
        p_special_instructions,
        p_preferred_partner_id,
        'pending'
    )
    RETURNING id INTO new_booking_id;

    -- Create initial timeline entry
    INSERT INTO public.booking_timeline (booking_id, status, updated_by, updated_by_type, notes)
    VALUES (new_booking_id, 'pending', p_admin_id, 'system', 'Booking created by admin');

    -- Log action
    INSERT INTO public.admin_actions_log (admin_id, action_type, target_type, target_id, description, metadata)
    VALUES (
        p_admin_id,
        'CREATE',
        'booking',
        new_booking_id,
        'Created booking for customer',
        jsonb_build_object('customer_id', p_customer_id, 'service_id', p_service_id, 'scheduled_date', p_scheduled_date)
    );

    RETURN new_booking_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function 5: Admin Assign Partner to Booking
CREATE OR REPLACE FUNCTION public.admin_assign_partner_to_booking(
    p_booking_id UUID,
    p_partner_id UUID,
    p_admin_id UUID DEFAULT auth.uid()
)
RETURNS BOOLEAN AS $$
DECLARE
    partner_user_type TEXT;
    booking_customer_id UUID;
BEGIN
    -- Check if admin
    IF NOT public.is_admin() THEN
        RAISE EXCEPTION 'Unauthorized: Only admins can assign partners to bookings';
    END IF;

    -- Verify partner exists and is partner type
    SELECT user_type INTO partner_user_type FROM public.users WHERE id = p_partner_id;

    IF partner_user_type IS NULL THEN
        RAISE EXCEPTION 'Partner not found';
    END IF;

    IF partner_user_type != 'partner' THEN
        RAISE EXCEPTION 'User is not a partner';
    END IF;

    -- Update booking
    UPDATE public.bookings
    SET partner_id = p_partner_id,
        status = CASE WHEN status = 'pending' THEN 'confirmed' ELSE status END,
        updated_at = NOW()
    WHERE id = p_booking_id
    RETURNING customer_id INTO booking_customer_id;

    IF booking_customer_id IS NULL THEN
        RAISE EXCEPTION 'Booking not found';
    END IF;

    -- Create timeline entry
    INSERT INTO public.booking_timeline (booking_id, status, updated_by, updated_by_type, notes)
    VALUES (p_booking_id, 'confirmed', p_admin_id, 'system', 'Partner assigned by admin');

    -- Create notification for partner
    INSERT INTO public.notifications (user_id, type, title, body, data)
    VALUES (
        p_partner_id,
        'booking_assigned',
        'New Booking Assigned',
        'You have been assigned a new booking by admin',
        jsonb_build_object('booking_id', p_booking_id, 'assigned_by', 'admin')
    );

    -- Log action
    INSERT INTO public.admin_actions_log (admin_id, action_type, target_type, target_id, description, metadata)
    VALUES (
        p_admin_id,
        'ASSIGN_PARTNER',
        'booking',
        p_booking_id,
        'Assigned partner to booking',
        jsonb_build_object('partner_id', p_partner_id, 'booking_id', p_booking_id)
    );

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function 6: Admin Update Booking Status
CREATE OR REPLACE FUNCTION public.admin_update_booking_status(
    p_booking_id UUID,
    p_new_status booking_status,
    p_notes TEXT DEFAULT NULL,
    p_admin_id UUID DEFAULT auth.uid()
)
RETURNS BOOLEAN AS $$
BEGIN
    -- Check if admin
    IF NOT public.is_admin() THEN
        RAISE EXCEPTION 'Unauthorized: Only admins can update booking status';
    END IF;

    -- Update booking
    UPDATE public.bookings
    SET status = p_new_status,
        updated_at = NOW()
    WHERE id = p_booking_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Booking not found';
    END IF;

    -- Create timeline entry
    INSERT INTO public.booking_timeline (booking_id, status, updated_by, updated_by_type, notes)
    VALUES (p_booking_id, p_new_status, p_admin_id, 'system', COALESCE(p_notes, 'Status updated by admin'));

    -- Log action
    INSERT INTO public.admin_actions_log (admin_id, action_type, target_type, target_id, description, metadata)
    VALUES (
        p_admin_id,
        'UPDATE_STATUS',
        'booking',
        p_booking_id,
        'Updated booking status to ' || p_new_status::TEXT,
        jsonb_build_object('new_status', p_new_status, 'notes', p_notes)
    );

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function 7: Admin Reschedule Booking
CREATE OR REPLACE FUNCTION public.admin_reschedule_booking(
    p_booking_id UUID,
    p_new_date TIMESTAMPTZ,
    p_admin_id UUID DEFAULT auth.uid()
)
RETURNS BOOLEAN AS $$
BEGIN
    -- Check if admin
    IF NOT public.is_admin() THEN
        RAISE EXCEPTION 'Unauthorized: Only admins can reschedule bookings';
    END IF;

    -- Update booking
    UPDATE public.bookings
    SET scheduled_date = p_new_date,
        updated_at = NOW()
    WHERE id = p_booking_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Booking not found';
    END IF;

    -- Create timeline entry
    INSERT INTO public.booking_timeline (booking_id, status, updated_by, updated_by_type, notes)
    SELECT status, p_admin_id, 'system', 'Booking rescheduled by admin to ' || p_new_date::TEXT
    FROM public.bookings WHERE id = p_booking_id;

    -- Log action
    INSERT INTO public.admin_actions_log (admin_id, action_type, target_type, target_id, description, metadata)
    VALUES (
        p_admin_id,
        'RESCHEDULE',
        'booking',
        p_booking_id,
        'Rescheduled booking',
        jsonb_build_object('new_date', p_new_date)
    );

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION public.get_dashboard_stats() TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_create_customer_profile(TEXT, TEXT, TEXT, TEXT, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_create_partner_profile(TEXT, TEXT, TEXT, TEXT, TEXT[], UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_create_booking(UUID, UUID, TIMESTAMPTZ, DECIMAL, JSONB, payment_method, DECIMAL, TEXT, UUID, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_assign_partner_to_booking(UUID, UUID, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_update_booking_status(UUID, booking_status, TEXT, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_reschedule_booking(UUID, TIMESTAMPTZ, UUID) TO authenticated;

-- Add comments
COMMENT ON FUNCTION public.get_dashboard_stats() IS 'Get admin dashboard statistics';
COMMENT ON FUNCTION public.admin_create_customer_profile IS 'Admin function to create customer profile before user signup';
COMMENT ON FUNCTION public.admin_create_partner_profile IS 'Admin function to create partner profile before user signup';
COMMENT ON FUNCTION public.admin_create_booking IS 'Admin function to create booking on behalf of customer';
COMMENT ON FUNCTION public.admin_assign_partner_to_booking IS 'Admin function to assign partner to a booking';
COMMENT ON FUNCTION public.admin_update_booking_status IS 'Admin function to update booking status';
COMMENT ON FUNCTION public.admin_reschedule_booking IS 'Admin function to reschedule a booking';
