-- Migration: Admin Infrastructure
-- Description: Create admin users table, action logs, update user_type enum, and add admin columns to profiles
-- Date: 2024-10-14

-- Step 1: Add 'admin' to user_type enum
ALTER TYPE user_type ADD VALUE IF NOT EXISTS 'admin';

-- Step 2: Create admin_users table
CREATE TABLE IF NOT EXISTS public.admin_users (
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE PRIMARY KEY,
    role TEXT NOT NULL DEFAULT 'admin' CHECK (role IN ('super_admin', 'admin', 'support')),
    permissions JSONB DEFAULT '{
        "manage_customers": true,
        "manage_partners": true,
        "manage_bookings": true,
        "manage_services": false,
        "view_analytics": true
    }'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Step 3: Create admin_actions_log table
CREATE TABLE IF NOT EXISTS public.admin_actions_log (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    admin_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
    action_type TEXT NOT NULL,
    target_type TEXT NOT NULL CHECK (target_type IN ('customer', 'partner', 'booking', 'service', 'user')),
    target_id UUID,
    description TEXT,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Step 4: Add indexes for admin_actions_log
CREATE INDEX IF NOT EXISTS idx_admin_actions_admin_id ON public.admin_actions_log(admin_id);
CREATE INDEX IF NOT EXISTS idx_admin_actions_target ON public.admin_actions_log(target_type, target_id);
CREATE INDEX IF NOT EXISTS idx_admin_actions_created_at ON public.admin_actions_log(created_at DESC);

-- Step 5: Add created_by_admin and phone_linked_at columns to customer_profiles
ALTER TABLE public.customer_profiles
ADD COLUMN IF NOT EXISTS created_by_admin UUID REFERENCES public.users(id) ON DELETE SET NULL,
ADD COLUMN IF NOT EXISTS phone_linked_at TIMESTAMPTZ NULL,
ADD COLUMN IF NOT EXISTS pending_phone TEXT NULL;

-- Step 6: Add created_by_admin and phone_linked_at columns to partner_profiles
ALTER TABLE public.partner_profiles
ADD COLUMN IF NOT EXISTS created_by_admin UUID REFERENCES public.users(id) ON DELETE SET NULL,
ADD COLUMN IF NOT EXISTS phone_linked_at TIMESTAMPTZ NULL,
ADD COLUMN IF NOT EXISTS pending_phone TEXT NULL;

-- Step 7: Add index on pending_phone for faster lookups
CREATE INDEX IF NOT EXISTS idx_customer_profiles_pending_phone ON public.customer_profiles(pending_phone) WHERE pending_phone IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_partner_profiles_pending_phone ON public.partner_profiles(pending_phone) WHERE pending_phone IS NOT NULL;

-- Step 8: Add updated_at trigger for admin_users
DROP TRIGGER IF EXISTS update_admin_users_updated_at ON public.admin_users;
CREATE TRIGGER update_admin_users_updated_at
    BEFORE UPDATE ON public.admin_users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Step 9: Enable RLS on new tables
ALTER TABLE public.admin_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_actions_log ENABLE ROW LEVEL SECURITY;

-- Step 10: Comment tables for documentation
COMMENT ON TABLE public.admin_users IS 'Stores admin user roles and permissions';
COMMENT ON TABLE public.admin_actions_log IS 'Audit log of all admin actions for compliance and tracking';
COMMENT ON COLUMN public.customer_profiles.created_by_admin IS 'Admin who created this profile before user signup';
COMMENT ON COLUMN public.customer_profiles.phone_linked_at IS 'Timestamp when user signed up and linked to this pre-created profile';
COMMENT ON COLUMN public.customer_profiles.pending_phone IS 'Phone number for profile created by admin before user signup';
COMMENT ON COLUMN public.partner_profiles.created_by_admin IS 'Admin who created this profile before user signup';
COMMENT ON COLUMN public.partner_profiles.phone_linked_at IS 'Timestamp when user signed up and linked to this pre-created profile';
COMMENT ON COLUMN public.partner_profiles.pending_phone IS 'Phone number for profile created by admin before user signup';
