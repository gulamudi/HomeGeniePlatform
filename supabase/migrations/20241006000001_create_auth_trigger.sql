-- Create a function to handle new user creation from Supabase Auth
-- This replaces the manual user creation currently done in the Flutter app
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
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger on auth.users table
-- This fires whenever a new user is created via Supabase Auth
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON ALL TABLES IN SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO postgres, anon, authenticated, service_role;
