-- Migration: Admin RLS Policies
-- Description: Create RLS policies for admin access and helper functions
-- Date: 2024-10-14

-- Step 1: Create helper function to check if user is admin
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.users u
        JOIN public.admin_users au ON u.id = au.user_id
        WHERE u.id = auth.uid()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 2: Create helper function to get admin permissions
CREATE OR REPLACE FUNCTION public.get_admin_permissions()
RETURNS JSONB AS $$
BEGIN
    RETURN (
        SELECT permissions FROM public.admin_users
        WHERE user_id = auth.uid()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 3: Admin policies for admin_users table
CREATE POLICY "Admins can view all admin users" ON public.admin_users
    FOR SELECT USING (public.is_admin());

CREATE POLICY "Super admins can manage admin users" ON public.admin_users
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.admin_users
            WHERE user_id = auth.uid() AND role = 'super_admin'
        )
    );

-- Step 4: Admin policies for admin_actions_log
CREATE POLICY "Admins can view admin actions log" ON public.admin_actions_log
    FOR SELECT USING (public.is_admin());

CREATE POLICY "Admins can insert admin actions" ON public.admin_actions_log
    FOR INSERT WITH CHECK (public.is_admin());

-- Step 5: Admin policies for users table
CREATE POLICY "Admins can view all users" ON public.users
    FOR SELECT USING (public.is_admin());

CREATE POLICY "Admins can create users" ON public.users
    FOR INSERT WITH CHECK (public.is_admin());

CREATE POLICY "Admins can update users" ON public.users
    FOR UPDATE USING (public.is_admin());

-- Step 6: Admin policies for customer_profiles
CREATE POLICY "Admins can view all customer profiles" ON public.customer_profiles
    FOR SELECT USING (public.is_admin());

CREATE POLICY "Admins can create customer profiles" ON public.customer_profiles
    FOR INSERT WITH CHECK (public.is_admin());

CREATE POLICY "Admins can update customer profiles" ON public.customer_profiles
    FOR UPDATE USING (public.is_admin());

CREATE POLICY "Admins can delete customer profiles" ON public.customer_profiles
    FOR DELETE USING (public.is_admin());

-- Step 7: Admin policies for partner_profiles
CREATE POLICY "Admins can view all partner profiles" ON public.partner_profiles
    FOR SELECT USING (public.is_admin());

CREATE POLICY "Admins can create partner profiles" ON public.partner_profiles
    FOR INSERT WITH CHECK (public.is_admin());

CREATE POLICY "Admins can update partner profiles" ON public.partner_profiles
    FOR UPDATE USING (public.is_admin());

CREATE POLICY "Admins can delete partner profiles" ON public.partner_profiles
    FOR DELETE USING (public.is_admin());

-- Step 8: Admin policies for bookings
CREATE POLICY "Admins can view all bookings" ON public.bookings
    FOR SELECT USING (public.is_admin());

CREATE POLICY "Admins can create bookings" ON public.bookings
    FOR INSERT WITH CHECK (public.is_admin());

CREATE POLICY "Admins can update all bookings" ON public.bookings
    FOR UPDATE USING (public.is_admin());

CREATE POLICY "Admins can delete bookings" ON public.bookings
    FOR DELETE USING (public.is_admin());

-- Step 9: Admin policies for booking_timeline
CREATE POLICY "Admins can view all booking timelines" ON public.booking_timeline
    FOR SELECT USING (public.is_admin());

CREATE POLICY "Admins can insert booking timeline entries" ON public.booking_timeline
    FOR INSERT WITH CHECK (public.is_admin());

-- Step 10: Admin policies for ratings
CREATE POLICY "Admins can view all ratings" ON public.ratings
    FOR SELECT USING (public.is_admin());

-- Step 11: Admin policies for notifications
CREATE POLICY "Admins can view all notifications" ON public.notifications
    FOR SELECT USING (public.is_admin());

CREATE POLICY "Admins can create notifications" ON public.notifications
    FOR INSERT WITH CHECK (public.is_admin());

-- Step 12: Admin policies for file_uploads
CREATE POLICY "Admins can view all file uploads" ON public.file_uploads
    FOR SELECT USING (public.is_admin());

-- Step 13: Admin policies for services (if admins need to manage)
CREATE POLICY "Admins can manage services" ON public.services
    FOR ALL USING (public.is_admin());

-- Step 14: Grant execute permissions on helper functions
GRANT EXECUTE ON FUNCTION public.is_admin() TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_admin_permissions() TO authenticated;

-- Add comments for documentation
COMMENT ON FUNCTION public.is_admin() IS 'Helper function to check if the current user is an admin';
COMMENT ON FUNCTION public.get_admin_permissions() IS 'Helper function to get the current admin user permissions';
