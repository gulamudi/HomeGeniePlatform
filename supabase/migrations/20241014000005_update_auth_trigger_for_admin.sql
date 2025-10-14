-- Migration: Update Auth Trigger to Support Admin Users
-- Description: Update the handle_new_user trigger to create admin_users profile for admin user type
-- Date: 2024-10-14

-- Update the handle_new_user function to support admin user type
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  user_type_value text;
  full_name_value text;
  phone_value text;
BEGIN
  -- Extract user_type from user metadata (set during signup)
  user_type_value := COALESCE(NEW.raw_user_meta_data->>'user_type', 'customer');

  -- Extract phone from user metadata or phone field
  phone_value := COALESCE(NEW.phone, NEW.raw_user_meta_data->>'phone');

  -- Generate a temporary full name if not provided
  full_name_value := COALESCE(
    NEW.raw_user_meta_data->>'full_name',
    'User ' || SUBSTRING(phone_value FROM '.....$')
  );

  -- Insert into users table
  INSERT INTO public.users (id, email, phone, full_name, user_type)
  VALUES (
    NEW.id,
    NEW.email,
    phone_value,
    full_name_value,
    user_type_value::public.user_type
  )
  ON CONFLICT (id) DO NOTHING;

  -- Insert into appropriate profile table based on user_type
  IF user_type_value = 'customer' THEN
    INSERT INTO public.customer_profiles (user_id)
    VALUES (NEW.id)
    ON CONFLICT (user_id) DO NOTHING;
  ELSIF user_type_value = 'partner' THEN
    INSERT INTO public.partner_profiles (user_id)
    VALUES (NEW.id)
    ON CONFLICT (user_id) DO NOTHING;
  ELSIF user_type_value = 'admin' THEN
    INSERT INTO public.admin_users (user_id, role, permissions)
    VALUES (
      NEW.id,
      'admin', -- Default role
      '{
        "manage_customers": true,
        "manage_partners": true,
        "manage_bookings": true,
        "manage_services": false,
        "view_analytics": true
      }'::jsonb
    )
    ON CONFLICT (user_id) DO NOTHING;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- The trigger already exists from the previous migration, no need to recreate it
-- But we add a comment to document the change
COMMENT ON FUNCTION public.handle_new_user() IS 'Handles new user creation from Supabase Auth and creates appropriate profile (customer, partner, or admin)';
