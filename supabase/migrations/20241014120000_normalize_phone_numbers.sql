-- Migration: Normalize Phone Numbers
-- Description: Add phone normalization function and update all user creation paths to use it
-- Date: 2024-10-14

-- Create a function to normalize phone numbers to E.164 format
CREATE OR REPLACE FUNCTION public.normalize_phone(phone_input TEXT, country_code TEXT DEFAULT '91')
RETURNS TEXT AS $$
DECLARE
  cleaned TEXT;
  normalized TEXT;
BEGIN
  -- Return NULL if input is NULL or empty
  IF phone_input IS NULL OR length(trim(phone_input)) = 0 THEN
    RETURN NULL;
  END IF;

  -- Remove all whitespace, dashes, parentheses, dots, and other formatting
  cleaned := regexp_replace(phone_input, '[\s\-\(\)\.]', '', 'g');

  -- Remove any leading zeros
  cleaned := regexp_replace(cleaned, '^0+', '');

  -- If it already has a +, remove it temporarily
  IF cleaned ~ '^\+' THEN
    cleaned := substring(cleaned from 2);
  END IF;

  -- If it starts with country code (e.g., 91), keep it as is
  -- If it doesn't, add the default country code
  IF NOT cleaned ~ ('^' || country_code) THEN
    cleaned := country_code || cleaned;
  END IF;

  -- Add the + prefix
  normalized := '+' || cleaned;

  -- Validate the final format for Indian numbers (should be +91 followed by 10 digits)
  IF country_code = '91' AND NOT (normalized ~ '^\+91\d{10}$') THEN
    RAISE EXCEPTION 'Invalid Indian phone number format. Expected +91XXXXXXXXXX (10 digits after +91), got: %', normalized;
  END IF;

  RETURN normalized;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Update the handle_new_user trigger to normalize phone numbers
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  user_type_value text;
  full_name_value text;
  phone_value text;
  normalized_phone text;
BEGIN
  -- Log trigger execution
  RAISE LOG 'handle_new_user trigger fired for user %', NEW.id;

  -- Extract user_type from user metadata (set during signup)
  user_type_value := COALESCE(NEW.raw_user_meta_data->>'user_type', 'customer');
  RAISE LOG 'User type: %', user_type_value;

  -- Extract phone from user metadata or phone field
  phone_value := COALESCE(NEW.phone, NEW.raw_user_meta_data->>'phone');
  RAISE LOG 'Phone value from auth.users: %', phone_value;

  -- IMPORTANT: Normalize the phone number to E.164 format
  normalized_phone := public.normalize_phone(phone_value);
  RAISE LOG 'Normalized phone: %', normalized_phone;

  -- Generate a temporary full name if not provided
  full_name_value := COALESCE(
    NEW.raw_user_meta_data->>'full_name',
    'User ' || SUBSTRING(normalized_phone FROM '.....$')
  );

  -- Insert into users table with NORMALIZED phone
  INSERT INTO public.users (id, email, phone, full_name, user_type)
  VALUES (
    NEW.id,
    NEW.email,
    normalized_phone,  -- Use normalized phone here
    full_name_value,
    user_type_value::public.user_type
  )
  ON CONFLICT (id) DO NOTHING;
  RAISE LOG 'Inserted/skipped user in public.users';

  -- Insert into appropriate profile table based on user_type
  IF user_type_value = 'customer' THEN
    INSERT INTO public.customer_profiles (user_id)
    VALUES (NEW.id)
    ON CONFLICT (user_id) DO NOTHING;
    RAISE LOG 'Inserted/skipped customer profile';
  ELSIF user_type_value = 'partner' THEN
    INSERT INTO public.partner_profiles (user_id)
    VALUES (NEW.id)
    ON CONFLICT (user_id) DO NOTHING;
    RAISE LOG 'Inserted/skipped partner profile';
  ELSIF user_type_value = 'admin' THEN
    INSERT INTO public.admin_users (user_id, role, permissions)
    VALUES (
      NEW.id,
      'admin',
      '{
        "manage_customers": true,
        "manage_partners": true,
        "manage_bookings": true,
        "manage_services": false,
        "view_analytics": true
      }'::jsonb
    )
    ON CONFLICT (user_id) DO NOTHING;
    RAISE LOG 'Inserted/skipped admin profile';
  END IF;

  RAISE LOG 'handle_new_user completed successfully for user %', NEW.id;
  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    RAISE LOG 'handle_new_user failed for user %: %', NEW.id, SQLERRM;
    RAISE; -- Re-raise the error
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Update admin_create_customer_profile to normalize phone
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
    normalized_phone TEXT;
BEGIN
    -- Check if admin
    IF NOT public.is_admin() THEN
        RAISE EXCEPTION 'Unauthorized: Only admins can create customer profiles';
    END IF;

    -- Normalize phone number
    normalized_phone := public.normalize_phone(p_phone);

    -- Validate inputs
    IF normalized_phone IS NULL THEN
        RAISE EXCEPTION 'Invalid phone number';
    END IF;

    IF p_first_name IS NULL OR length(trim(p_first_name)) < 2 THEN
        RAISE EXCEPTION 'Invalid first name';
    END IF;

    IF p_last_name IS NULL OR length(trim(p_last_name)) < 2 THEN
        RAISE EXCEPTION 'Invalid last name';
    END IF;

    -- Check if user already exists with this phone (using normalized phone)
    SELECT id INTO existing_user FROM public.users WHERE phone = normalized_phone;

    IF existing_user IS NOT NULL THEN
        RAISE EXCEPTION 'User with phone % already exists', normalized_phone;
    END IF;

    -- Create placeholder user_id
    new_user_id := gen_random_uuid();

    -- First, create auth user record (required for foreign key constraint)
    -- The handle_new_user trigger will automatically create the public.users record
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
        normalized_phone,  -- Use normalized phone
        '',
        CASE WHEN p_email IS NOT NULL THEN now() ELSE NULL END,
        NULL,
        jsonb_build_object('provider', 'phone', 'providers', ARRAY['phone'], 'created_by_admin', true),
        jsonb_build_object('full_name', trim(p_first_name) || ' ' || trim(p_last_name), 'user_type', 'customer'),
        now(),
        now(),
        '',
        '',
        '',
        ''
    );

    -- NOTE: public.users record is created automatically by the handle_new_user trigger
    -- NOTE: customer_profiles record is also created by the trigger

    -- Update customer profile with admin metadata
    UPDATE public.customer_profiles
    SET created_by_admin = p_admin_id,
        pending_phone = normalized_phone
    WHERE user_id = new_user_id;

    -- Log action
    INSERT INTO public.admin_actions_log (admin_id, action_type, target_type, target_id, description, metadata)
    VALUES (
        p_admin_id,
        'CREATE',
        'customer',
        new_user_id,
        'Created customer profile for ' || normalized_phone,
        jsonb_build_object('phone', normalized_phone, 'name', trim(p_first_name) || ' ' || trim(p_last_name))
    );

    RETURN new_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Update admin_create_partner_profile to normalize phone
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
    normalized_phone TEXT;
BEGIN
    -- Check if admin
    IF NOT public.is_admin() THEN
        RAISE EXCEPTION 'Unauthorized: Only admins can create partner profiles';
    END IF;

    -- Normalize phone number
    normalized_phone := public.normalize_phone(p_phone);

    -- Validate inputs
    IF normalized_phone IS NULL THEN
        RAISE EXCEPTION 'Invalid phone number';
    END IF;

    IF p_first_name IS NULL OR length(trim(p_first_name)) < 2 THEN
        RAISE EXCEPTION 'Invalid first name';
    END IF;

    IF p_last_name IS NULL OR length(trim(p_last_name)) < 2 THEN
        RAISE EXCEPTION 'Invalid last name';
    END IF;

    -- Check if user already exists with this phone (using normalized phone)
    SELECT id INTO existing_user FROM public.users WHERE phone = normalized_phone;

    IF existing_user IS NOT NULL THEN
        RAISE EXCEPTION 'User with phone % already exists', normalized_phone;
    END IF;

    -- Create placeholder user_id
    new_user_id := gen_random_uuid();

    -- First, create auth user record (required for foreign key constraint)
    -- The handle_new_user trigger will automatically create the public.users record
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
        normalized_phone,  -- Use normalized phone
        '',
        CASE WHEN p_email IS NOT NULL THEN now() ELSE NULL END,
        NULL,
        jsonb_build_object('provider', 'phone', 'providers', ARRAY['phone'], 'created_by_admin', true),
        jsonb_build_object('full_name', trim(p_first_name) || ' ' || trim(p_last_name), 'user_type', 'partner'),
        now(),
        now(),
        '',
        '',
        '',
        ''
    );

    -- NOTE: public.users record is created automatically by the handle_new_user trigger
    -- NOTE: partner_profiles record is also created by the trigger

    -- Update partner profile with admin metadata
    UPDATE public.partner_profiles
    SET created_by_admin = p_admin_id,
        pending_phone = normalized_phone,
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
        'Created partner profile for ' || normalized_phone,
        jsonb_build_object('phone', normalized_phone, 'name', trim(p_first_name) || ' ' || trim(p_last_name), 'services', p_services)
    );

    RETURN new_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Add a comment
COMMENT ON FUNCTION public.normalize_phone(TEXT, TEXT) IS 'Normalizes phone numbers to E.164 format (+[country_code][number])';

-- Normalize existing phone numbers in the users table
UPDATE public.users
SET phone = public.normalize_phone(phone)
WHERE phone IS NOT NULL AND phone !~ '^\+91\d{10}$';

COMMENT ON FUNCTION public.handle_new_user() IS 'Handles new user creation from Supabase Auth with phone normalization and creates appropriate profile (customer, partner, or admin)';
