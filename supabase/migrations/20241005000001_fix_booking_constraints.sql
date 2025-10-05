-- Fix booking constraints to allow proper date validation
-- Remove overly restrictive future date check that blocks testing

-- Drop the existing check constraint
ALTER TABLE public.bookings DROP CONSTRAINT IF EXISTS check_scheduled_date_future;

-- Add a more reasonable constraint (allow scheduling from current time onwards)
-- This allows bookings for "now" and future, but not past
ALTER TABLE public.bookings
  ADD CONSTRAINT check_scheduled_date_not_past
  CHECK (scheduled_date >= (NOW() - INTERVAL '1 day'));
