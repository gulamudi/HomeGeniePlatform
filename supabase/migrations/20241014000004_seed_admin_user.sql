-- Migration: Seed Initial Admin User
-- Description: Create a default admin user for development/testing
-- Date: 2024-10-14

-- This admin user will be able to login with phone +917777777777 and OTP 123456
-- After first login via Supabase Auth, the trigger will link to this profile

-- NOTE: In production, you should manually create admin users via SQL
-- and never expose admin registration in the app

-- Insert admin user entry (this will be linked when they first login via Supabase Auth)
-- The user record will be created automatically by Supabase Auth when they verify OTP
-- But we pre-create the admin_users entry so they have admin permissions

-- For now, we'll document the process. After the user authenticates via Supabase Auth,
-- you'll need to:
-- 1. Get their UUID from auth.users table
-- 2. Update the users table to set user_type = 'admin'
-- 3. Insert into admin_users table

-- Here's a helper function to promote a user to admin:
CREATE OR REPLACE FUNCTION public.promote_user_to_admin(
    user_phone TEXT,
    admin_role TEXT DEFAULT 'admin'
)
RETURNS VOID AS $$
DECLARE
    user_uuid UUID;
BEGIN
    -- Get the user ID
    SELECT id INTO user_uuid FROM public.users WHERE phone = user_phone;

    IF user_uuid IS NULL THEN
        RAISE EXCEPTION 'User with phone % not found', user_phone;
    END IF;

    -- Update user type to admin
    UPDATE public.users
    SET user_type = 'admin'
    WHERE id = user_uuid;

    -- Insert or update admin_users entry
    INSERT INTO public.admin_users (user_id, role, permissions)
    VALUES (
        user_uuid,
        admin_role,
        jsonb_build_object(
            'manage_customers', true,
            'manage_partners', true,
            'manage_bookings', true,
            'manage_services', true,
            'view_analytics', true
        )
    )
    ON CONFLICT (user_id) DO UPDATE
    SET role = admin_role;

    RAISE NOTICE '✅ User % promoted to % successfully', user_phone, admin_role;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.promote_user_to_admin IS 'Promotes an existing user to admin role. Usage: SELECT public.promote_user_to_admin(''+917777777777'', ''super_admin'');';
