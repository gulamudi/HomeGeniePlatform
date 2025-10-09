-- Remove otp_sessions table
-- This table is not used as OTP management is handled by Supabase Auth

-- Drop indexes
DROP INDEX IF EXISTS public.idx_otp_sessions_phone;

-- Drop RLS policies (if any exist)
DROP POLICY IF EXISTS "Users can view their own OTP sessions" ON public.otp_sessions;
DROP POLICY IF EXISTS "Users can create OTP sessions" ON public.otp_sessions;

-- Drop triggers (if any exist)
DROP TRIGGER IF EXISTS update_otp_sessions_updated_at ON public.otp_sessions;

-- Drop the table
DROP TABLE IF EXISTS public.otp_sessions CASCADE;

-- Log the change
DO $$
BEGIN
  RAISE NOTICE '✅ Removed otp_sessions table - OTP is handled by Supabase Auth';
END $$;
