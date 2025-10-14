-- Migration: Fix Admin User Creation Functions
-- Description: Update admin functions to create auth users first before creating profile records
-- Date: 2024-10-14

-- Drop and recreate the customer creation function
DROP FUNCTION IF EXISTS public.admin_create_customer_profile(TEXT, TEXT, TEXT, TEXT, UUID);

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

    -- First, create auth user record (required for foreign key constraint)
    -- Using a dummy password that will need to be set via OTP when user signs in
    INSERT INTO auth.users (
        id,
        instance_id,
        aud,
        role,
        email,
        phone,
        encrypted_password,
        email_confirmed_at,
        phone_confirmed_at,
        raw_app_meta_data,
        raw_user_meta_data,
        created_at,
        updated_at,
        confirmation_token,
        email_change,
        email_change_token_new,
        recovery_token
    ) VALUES (
        new_user_id,
        '00000000-0000-0000-0000-000000000000',
        'authenticated',
        'authenticated',
        p_email,
        p_phone,
        '',  -- Empty password, user will need to set via OTP
        CASE WHEN p_email IS NOT NULL THEN now() ELSE NULL END,
        NULL,  -- Phone not confirmed yet
        jsonb_build_object('provider', 'phone', 'providers', ARRAY['phone'], 'created_by_admin', true),
        jsonb_build_object('full_name', trim(p_first_name) || ' ' || trim(p_last_name), 'user_type', 'customer'),
        now(),
        now(),
        '',
        '',
        '',
        ''
    );

    -- Create user record in public.users
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

-- Drop and recreate the partner creation function
DROP FUNCTION IF EXISTS public.admin_create_partner_profile(TEXT, TEXT, TEXT, TEXT, TEXT[], UUID);

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

    -- First, create auth user record (required for foreign key constraint)
    -- Using a dummy password that will need to be set via OTP when user signs in
    INSERT INTO auth.users (
        id,
        instance_id,
        aud,
        role,
        email,
        phone,
        encrypted_password,
        email_confirmed_at,
        phone_confirmed_at,
        raw_app_meta_data,
        raw_user_meta_data,
        created_at,
        updated_at,
        confirmation_token,
        email_change,
        email_change_token_new,
        recovery_token
    ) VALUES (
        new_user_id,
        '00000000-0000-0000-0000-000000000000',
        'authenticated',
        'authenticated',
        p_email,
        p_phone,
        '',  -- Empty password, user will need to set via OTP
        CASE WHEN p_email IS NOT NULL THEN now() ELSE NULL END,
        NULL,  -- Phone not confirmed yet
        jsonb_build_object('provider', 'phone', 'providers', ARRAY['phone'], 'created_by_admin', true),
        jsonb_build_object('full_name', trim(p_first_name) || ' ' || trim(p_last_name), 'user_type', 'partner'),
        now(),
        now(),
        '',
        '',
        '',
        ''
    );

    -- Create user record in public.users
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

-- Re-grant execute permissions
GRANT EXECUTE ON FUNCTION public.admin_create_customer_profile(TEXT, TEXT, TEXT, TEXT, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_create_partner_profile(TEXT, TEXT, TEXT, TEXT, TEXT[], UUID) TO authenticated;

-- Add comments
COMMENT ON FUNCTION public.admin_create_customer_profile IS 'Admin function to create customer profile with auth user before user signup';
COMMENT ON FUNCTION public.admin_create_partner_profile IS 'Admin function to create partner profile with auth user before user signup';
