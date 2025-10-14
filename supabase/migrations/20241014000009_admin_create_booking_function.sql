-- Function for admin to create booking
CREATE OR REPLACE FUNCTION admin_create_booking(
  p_customer_id UUID,
  p_service_id UUID,
  p_scheduled_date TIMESTAMP WITH TIME ZONE,
  p_address TEXT,
  p_notes TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_booking_id UUID;
BEGIN
  -- Insert booking
  INSERT INTO bookings (
    customer_id,
    service_id,
    scheduled_date,
    address,
    notes,
    status
  )
  VALUES (
    p_customer_id,
    p_service_id,
    p_scheduled_date,
    p_address,
    p_notes,
    'pending'
  )
  RETURNING id INTO v_booking_id;

  RETURN v_booking_id;
END;
$$;
