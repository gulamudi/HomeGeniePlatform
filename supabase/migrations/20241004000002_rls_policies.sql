-- Enable Row Level Security on all tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customer_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.partner_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.service_pricing_tiers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.booking_timeline ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ratings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.file_uploads ENABLE ROW LEVEL SECURITY;

-- Users policies
CREATE POLICY "Users can view their own profile" ON public.users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON public.users
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile" ON public.users
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Customer profiles policies
CREATE POLICY "Customers can view their own profile" ON public.customer_profiles
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Customers can update their own profile" ON public.customer_profiles
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Customers can insert their own profile" ON public.customer_profiles
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Partner profiles policies
CREATE POLICY "Partners can view their own profile" ON public.partner_profiles
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Partners can update their own profile" ON public.partner_profiles
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Partners can insert their own profile" ON public.partner_profiles
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Customers can view partner profiles for bookings" ON public.partner_profiles
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.bookings b
            WHERE b.partner_id = user_id
            AND b.customer_id = auth.uid()
        )
    );

-- Services policies (public read)
CREATE POLICY "Anyone can view active services" ON public.services
    FOR SELECT USING (is_active = true);

-- Service pricing tiers policies
CREATE POLICY "Anyone can view pricing tiers for active services" ON public.service_pricing_tiers
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.services s
            WHERE s.id = service_id AND s.is_active = true
        )
    );

-- Bookings policies
CREATE POLICY "Customers can view their own bookings" ON public.bookings
    FOR SELECT USING (customer_id = auth.uid());

CREATE POLICY "Partners can view their assigned bookings" ON public.bookings
    FOR SELECT USING (partner_id = auth.uid());

CREATE POLICY "Customers can create bookings" ON public.bookings
    FOR INSERT WITH CHECK (customer_id = auth.uid());

CREATE POLICY "Customers can update their bookings" ON public.bookings
    FOR UPDATE USING (
        customer_id = auth.uid()
        AND status IN ('pending', 'confirmed')
    );

CREATE POLICY "Partners can update assigned bookings" ON public.bookings
    FOR UPDATE USING (partner_id = auth.uid());

-- Booking timeline policies
CREATE POLICY "Users can view timeline for their bookings" ON public.booking_timeline
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.bookings b
            WHERE b.id = booking_id
            AND (b.customer_id = auth.uid() OR b.partner_id = auth.uid())
        )
    );

CREATE POLICY "Users can insert timeline for their bookings" ON public.booking_timeline
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.bookings b
            WHERE b.id = booking_id
            AND (b.customer_id = auth.uid() OR b.partner_id = auth.uid())
        )
    );

-- Ratings policies
CREATE POLICY "Customers can view ratings for their bookings" ON public.ratings
    FOR SELECT USING (customer_id = auth.uid());

CREATE POLICY "Partners can view their ratings" ON public.ratings
    FOR SELECT USING (partner_id = auth.uid());

CREATE POLICY "Customers can create ratings for their completed bookings" ON public.ratings
    FOR INSERT WITH CHECK (
        customer_id = auth.uid()
        AND EXISTS (
            SELECT 1 FROM public.bookings b
            WHERE b.id = booking_id
            AND b.customer_id = auth.uid()
            AND b.status = 'completed'
        )
    );

-- Notifications policies
CREATE POLICY "Users can view their own notifications" ON public.notifications
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users can update their own notifications" ON public.notifications
    FOR UPDATE USING (user_id = auth.uid());

-- File uploads policies
CREATE POLICY "Users can view their own uploads" ON public.file_uploads
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users can upload files" ON public.file_uploads
    FOR INSERT WITH CHECK (user_id = auth.uid());

-- Helper functions for RLS
CREATE OR REPLACE FUNCTION public.is_customer()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.users
        WHERE id = auth.uid() AND user_type = 'customer'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.is_partner()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.users
        WHERE id = auth.uid() AND user_type = 'partner'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.get_user_type()
RETURNS user_type AS $$
BEGIN
    RETURN (
        SELECT user_type FROM public.users
        WHERE id = auth.uid()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;