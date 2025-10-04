-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- Custom types
CREATE TYPE user_type AS ENUM ('customer', 'partner');
CREATE TYPE verification_status AS ENUM ('pending', 'in_progress', 'verified', 'rejected');
CREATE TYPE booking_status AS ENUM ('pending', 'confirmed', 'in_progress', 'completed', 'cancelled', 'no_show', 'disputed');
CREATE TYPE payment_method AS ENUM ('cash', 'card', 'upi', 'wallet', 'net_banking');
CREATE TYPE payment_status AS ENUM ('pending', 'processing', 'completed', 'failed', 'refunded');
CREATE TYPE document_type AS ENUM ('aadhar', 'pan', 'police_verification', 'profile_photo');
CREATE TYPE service_category AS ENUM ('cleaning', 'plumbing', 'electrical', 'gardening', 'handyman', 'beauty', 'appliance_repair', 'painting', 'pest_control', 'home_security');

-- Users table (extends Supabase auth.users)
CREATE TABLE public.users (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    email TEXT UNIQUE,
    phone TEXT UNIQUE NOT NULL,
    full_name TEXT NOT NULL CHECK (length(full_name) >= 2),
    avatar_url TEXT,
    user_type user_type NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Customer profiles
CREATE TABLE public.customer_profiles (
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE PRIMARY KEY,
    addresses JSONB DEFAULT '[]'::jsonb,
    preferences JSONB DEFAULT '{
        "preferredLanguage": "en",
        "notifications": {
            "email": true,
            "sms": true,
            "push": true
        }
    }'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Partner profiles
CREATE TABLE public.partner_profiles (
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE PRIMARY KEY,
    verification_status verification_status DEFAULT 'pending',
    services TEXT[] DEFAULT '{}',
    availability JSONB DEFAULT '{
        "weekdays": [1,2,3,4,5,6],
        "workingHours": {"start": "08:00", "end": "18:00"},
        "isAvailable": true
    }'::jsonb,
    documents JSONB DEFAULT '[]'::jsonb,
    rating DECIMAL(3,2) DEFAULT 0.00 CHECK (rating >= 0 AND rating <= 5),
    total_jobs INTEGER DEFAULT 0 CHECK (total_jobs >= 0),
    total_earnings DECIMAL(10,2) DEFAULT 0.00 CHECK (total_earnings >= 0),
    job_preferences JSONB DEFAULT '{
        "maxDistance": 10,
        "preferredAreas": [],
        "preferredServices": [],
        "minJobValue": 0,
        "autoAccept": false
    }'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Services
CREATE TABLE public.services (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL CHECK (length(name) >= 2),
    description TEXT CHECK (length(description) <= 500),
    category service_category NOT NULL,
    base_price DECIMAL(10,2) NOT NULL CHECK (base_price >= 0),
    duration_hours DECIMAL(4,2) NOT NULL CHECK (duration_hours >= 0.5 AND duration_hours <= 24),
    is_active BOOLEAN DEFAULT true,
    requirements TEXT[] DEFAULT '{}',
    includes TEXT[] DEFAULT '{}',
    excludes TEXT[] DEFAULT '{}',
    image_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Service pricing tiers
CREATE TABLE public.service_pricing_tiers (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    service_id UUID REFERENCES public.services(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    duration_hours DECIMAL(4,2) NOT NULL CHECK (duration_hours >= 0.5),
    is_default BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Bookings
CREATE TABLE public.bookings (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    customer_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    partner_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
    service_id UUID REFERENCES public.services(id) ON DELETE RESTRICT NOT NULL,
    status booking_status DEFAULT 'pending',
    scheduled_date TIMESTAMPTZ NOT NULL,
    duration_hours DECIMAL(4,2) NOT NULL CHECK (duration_hours >= 0.5),
    address JSONB NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL CHECK (total_amount >= 0),
    payment_method payment_method NOT NULL,
    payment_status payment_status DEFAULT 'pending',
    special_instructions TEXT CHECK (length(special_instructions) <= 500),
    preferred_partner_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
    location GEOGRAPHY(POINT, 4326), -- For spatial queries
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    CONSTRAINT check_scheduled_date_future CHECK (scheduled_date > NOW()),
    CONSTRAINT check_duration_positive CHECK (duration_hours > 0),
    CONSTRAINT check_total_amount_positive CHECK (total_amount >= 0)
);

-- Booking timeline
CREATE TABLE public.booking_timeline (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    booking_id UUID REFERENCES public.bookings(id) ON DELETE CASCADE NOT NULL,
    status booking_status NOT NULL,
    timestamp TIMESTAMPTZ DEFAULT NOW(),
    notes TEXT CHECK (length(notes) <= 500),
    updated_by UUID REFERENCES public.users(id) ON DELETE SET NULL,
    updated_by_type TEXT CHECK (updated_by_type IN ('customer', 'partner', 'system')),
    location GEOGRAPHY(POINT, 4326),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Ratings
CREATE TABLE public.ratings (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    booking_id UUID REFERENCES public.bookings(id) ON DELETE CASCADE UNIQUE NOT NULL,
    customer_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    partner_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT CHECK (length(comment) <= 500),
    rating_categories JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    CONSTRAINT unique_booking_rating UNIQUE (booking_id)
);

-- OTP sessions (for temporary storage during auth)
CREATE TABLE public.otp_sessions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    phone TEXT NOT NULL,
    otp_hash TEXT NOT NULL,
    user_type user_type NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    attempts INTEGER DEFAULT 0 CHECK (attempts <= 5),
    verified BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Notifications
CREATE TABLE public.notifications (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    type TEXT NOT NULL,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    data JSONB DEFAULT '{}'::jsonb,
    read BOOLEAN DEFAULT false,
    sent_at TIMESTAMPTZ DEFAULT NOW(),
    read_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- File uploads
CREATE TABLE public.file_uploads (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    file_name TEXT NOT NULL,
    file_path TEXT NOT NULL,
    file_size INTEGER,
    mime_type TEXT,
    purpose TEXT, -- 'profile_photo', 'document', 'service_image', etc.
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX idx_users_phone ON public.users(phone);
CREATE INDEX idx_users_user_type ON public.users(user_type);
CREATE INDEX idx_bookings_customer_id ON public.bookings(customer_id);
CREATE INDEX idx_bookings_partner_id ON public.bookings(partner_id);
CREATE INDEX idx_bookings_status ON public.bookings(status);
CREATE INDEX idx_bookings_scheduled_date ON public.bookings(scheduled_date);
CREATE INDEX idx_booking_timeline_booking_id ON public.booking_timeline(booking_id);
CREATE INDEX idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX idx_notifications_read ON public.notifications(read);
CREATE INDEX idx_otp_sessions_phone ON public.otp_sessions(phone);
CREATE INDEX idx_services_category ON public.services(category);
CREATE INDEX idx_services_active ON public.services(is_active);

-- Spatial index for location-based queries
CREATE INDEX idx_bookings_location ON public.bookings USING GIST(location);

-- Add updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language plpgsql;

-- Add triggers for updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_customer_profiles_updated_at BEFORE UPDATE ON public.customer_profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_partner_profiles_updated_at BEFORE UPDATE ON public.partner_profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_services_updated_at BEFORE UPDATE ON public.services FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_service_pricing_tiers_updated_at BEFORE UPDATE ON public.service_pricing_tiers FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_bookings_updated_at BEFORE UPDATE ON public.bookings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_ratings_updated_at BEFORE UPDATE ON public.ratings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_otp_sessions_updated_at BEFORE UPDATE ON public.otp_sessions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_notifications_updated_at BEFORE UPDATE ON public.notifications FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_file_uploads_updated_at BEFORE UPDATE ON public.file_uploads FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Trigger function to validate user types for bookings
CREATE OR REPLACE FUNCTION validate_booking_user_types()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if customer_id refers to a customer user
    IF (SELECT user_type FROM public.users WHERE id = NEW.customer_id) != 'customer' THEN
        RAISE EXCEPTION 'Customer ID must reference a customer user';
    END IF;
    
    -- Check if partner_id (if not null) refers to a partner user
    IF NEW.partner_id IS NOT NULL AND 
       (SELECT user_type FROM public.users WHERE id = NEW.partner_id) != 'partner' THEN
        RAISE EXCEPTION 'Partner ID must reference a partner user';
    END IF;
    
    -- Check if preferred_partner_id (if not null) refers to a partner user
    IF NEW.preferred_partner_id IS NOT NULL AND 
       (SELECT user_type FROM public.users WHERE id = NEW.preferred_partner_id) != 'partner' THEN
        RAISE EXCEPTION 'Preferred Partner ID must reference a partner user';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for booking validation
CREATE TRIGGER validate_booking_user_types_trigger
    BEFORE INSERT OR UPDATE ON public.bookings
    FOR EACH ROW EXECUTE FUNCTION validate_booking_user_types();
