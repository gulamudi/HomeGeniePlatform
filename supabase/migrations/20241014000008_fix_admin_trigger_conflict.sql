-- Migration: Fix Admin User Creation - Let Trigger Handle Everything
-- Description: Remove duplicate inserts and let the on_auth_user_created trigger handle user/profile creation
-- Date: 2024-10-14

-- Drop and recreate the customer creation function - let trigger do the work
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
    existing_user_id UUID;
    existing_auth_user_id UUID;
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

    -- Check if user already exists with this phone in public.users
    SELECT id INTO existing_user_id FROM public.users WHERE phone = p_phone;
    IF existing_user_id IS NOT NULL THEN
        RAISE EXCEPTION 'User with phone % already exists', p_phone;
    END IF;

    -- Check if user already exists with this phone in auth.users
    SELECT id INTO existing_auth_user_id FROM auth.users WHERE phone = p_phone;
    IF existing_auth_user_id IS NOT NULL THEN
        RAISE EXCEPTION 'User with phone % already exists', p_phone;
    END IF;

    -- Generate new user_id
    new_user_id := gen_random_uuid();

    -- Create auth user record
    -- The trigger will automatically create public.users and customer_profiles records
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
        crypt('temporary_password_' || new_user_id::text, gen_salt('bf')),
        CASE WHEN p_email IS NOT NULL THEN now() ELSE NULL END,
        NULL,
        jsonb_build_object('provider', 'phone', 'providers', ARRAY['phone'], 'created_by_admin', true),
        jsonb_build_object(
            'full_name', trim(p_first_name) || ' ' || trim(p_last_name),
            'user_type', 'customer',
            'phone', p_phone
        ),
        now(),
        now(),
        '',
        '',
        '',
        ''
    );

    -- The trigger has already created the user and customer_profile
    -- Now update the customer_profile with admin-specific fields
    UPDATE public.customer_profiles
    SET
        created_by_admin = p_admin_id,
        pending_phone = p_phone
    WHERE user_id = new_user_id;

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
EXCEPTION
    WHEN OTHERS THEN
        -- Log the full error for debugging
        RAISE EXCEPTION 'Error creating customer: % (SQLSTATE: %)', SQLERRM, SQLSTATE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop and recreate the partner creation function - let trigger do the work
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
    existing_user_id UUID;
    existing_auth_user_id UUID;
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

    -- Check if user already exists with this phone in public.users
    SELECT id INTO existing_user_id FROM public.users WHERE phone = p_phone;
    IF existing_user_id IS NOT NULL THEN
        RAISE EXCEPTION 'User with phone % already exists', p_phone;
    END IF;

    -- Check if user already exists with this phone in auth.users
    SELECT id INTO existing_auth_user_id FROM auth.users WHERE phone = p_phone;
    IF existing_auth_user_id IS NOT NULL THEN
        RAISE EXCEPTION 'User with phone % already exists', p_phone;
    END IF;

    -- Generate new user_id
    new_user_id := gen_random_uuid();

    -- Create auth user record
    -- The trigger will automatically create public.users and partner_profiles records
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
        crypt('temporary_password_' || new_user_id::text, gen_salt('bf')),
        CASE WHEN p_email IS NOT NULL THEN now() ELSE NULL END,
        NULL,
        jsonb_build_object('provider', 'phone', 'providers', ARRAY['phone'], 'created_by_admin', true),
        jsonb_build_object(
            'full_name', trim(p_first_name) || ' ' || trim(p_last_name),
            'user_type', 'partner',
            'phone', p_phone
        ),
        now(),
        now(),
        '',
        '',
        '',
        ''
    );

    -- The trigger has already created the user and partner_profile
    -- Now update the partner_profile with admin-specific fields
    UPDATE public.partner_profiles
    SET
        created_by_admin = p_admin_id,
        pending_phone = p_phone,
        services = p_services,
        verification_status = 'pending'
    WHERE user_id = new_user_id;

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
EXCEPTION
    WHEN OTHERS THEN
        -- Log the full error for debugging
        RAISE EXCEPTION 'Error creating partner: % (SQLSTATE: %)', SQLERRM, SQLSTATE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Re-grant execute permissions
GRANT EXECUTE ON FUNCTION public.admin_create_customer_profile(TEXT, TEXT, TEXT, TEXT, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_create_partner_profile(TEXT, TEXT, TEXT, TEXT, TEXT[], UUID) TO authenticated;

-- Add comments
COMMENT ON FUNCTION public.admin_create_customer_profile IS 'Admin function to create customer - trigger handles user/profile creation, function updates admin fields';
COMMENT ON FUNCTION public.admin_create_partner_profile IS 'Admin function to create partner - trigger handles user/profile creation, function updates admin fields';
