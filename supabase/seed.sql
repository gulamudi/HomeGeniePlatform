-- Insert sample services
INSERT INTO public.services (id, name, description, category, base_price, duration_hours, requirements, includes, excludes, image_url) VALUES
-- Cleaning services
('550e8400-e29b-41d4-a716-446655440001', 'House Cleaning', 'Professional house cleaning service including all rooms', 'cleaning', 500.00, 2.0,
 ARRAY['Access to all rooms', 'Power and water supply'],
 ARRAY['Sweeping', 'Mopping', 'Dusting', 'Bathroom cleaning', 'Kitchen cleaning'],
 ARRAY['Washing dishes', 'Laundry', 'Interior of appliances'],
 'https://example.com/house-cleaning.jpg'),

('550e8400-e29b-41d4-a716-446655440002', 'Deep House Cleaning', 'Comprehensive deep cleaning service', 'cleaning', 800.00, 4.0,
 ARRAY['Full day access', 'Power and water supply'],
 ARRAY['Detailed cleaning of all surfaces', 'Bathroom deep clean', 'Kitchen deep clean', 'Floor scrubbing', 'Window cleaning'],
 ARRAY['Carpet cleaning', 'Appliance repair'],
 'https://example.com/deep-cleaning.jpg'),

-- Plumbing services
('550e8400-e29b-41d4-a716-446655440003', 'Plumbing Repair', 'Fix leaks, unclog drains, and basic plumbing issues', 'plumbing', 300.00, 1.5,
 ARRAY['Access to affected areas', 'Water supply'],
 ARRAY['Leak fixing', 'Drain unclogging', 'Basic pipe repair'],
 ARRAY['Major pipe replacement', 'Bathroom renovation'],
 'https://example.com/plumbing.jpg'),

-- Electrical services
('550e8400-e29b-41d4-a716-446655440004', 'Electrical Wiring', 'Electrical repairs and new wiring installation', 'electrical', 400.00, 2.0,
 ARRAY['Power access', 'Safety clearance'],
 ARRAY['Wiring repair', 'Switch/outlet installation', 'Basic electrical troubleshooting'],
 ARRAY['Major rewiring', 'Electrical panel upgrade'],
 'https://example.com/electrical.jpg');

-- Insert service pricing tiers
INSERT INTO public.service_pricing_tiers (service_id, name, description, price, duration_hours, is_default) VALUES
-- House cleaning tiers
('550e8400-e29b-41d4-a716-446655440001', '1 BHK', 'Cleaning for 1 bedroom apartment', 400.00, 1.5, true),
('550e8400-e29b-41d4-a716-446655440001', '2 BHK', 'Cleaning for 2 bedroom apartment', 600.00, 2.5, false),
('550e8400-e29b-41d4-a716-446655440001', '3 BHK', 'Cleaning for 3 bedroom apartment', 800.00, 3.5, false),

-- Deep cleaning tiers
('550e8400-e29b-41d4-a716-446655440002', '1 BHK', 'Deep cleaning for 1 bedroom apartment', 600.00, 3.0, true),
('550e8400-e29b-41d4-a716-446655440002', '2 BHK', 'Deep cleaning for 2 bedroom apartment', 900.00, 4.5, false),
('550e8400-e29b-41d4-a716-446655440002', '3 BHK', 'Deep cleaning for 3 bedroom apartment', 1200.00, 6.0, false);

-- Note: We don't insert user data as that will be created through the authentication flow
-- This seed data provides the basic services that will be available in the app

-- Insert some test data for development (commented out for production)
/*
-- Test customer user (for development only)
INSERT INTO auth.users (id, email, phone, created_at, updated_at) VALUES
('11111111-1111-1111-1111-111111111111', 'customer@test.com', '+919876543210', NOW(), NOW());

INSERT INTO public.users (id, email, phone, full_name, user_type) VALUES
('11111111-1111-1111-1111-111111111111', 'customer@test.com', '+919876543210', 'Test Customer', 'customer');

INSERT INTO public.customer_profiles (user_id, addresses) VALUES
('11111111-1111-1111-1111-111111111111', '[
  {
    "id": "addr1",
    "flatHouseNo": "123",
    "buildingApartmentName": "Green Valley",
    "streetName": "MG Road",
    "landmark": "Near City Mall",
    "area": "Sector 15",
    "city": "Mumbai",
    "state": "Maharashtra",
    "pinCode": "400001",
    "type": "home",
    "isDefault": true
  }
]'::jsonb);

-- Test partner user (for development only)
INSERT INTO auth.users (id, email, phone, created_at, updated_at) VALUES
('22222222-2222-2222-2222-222222222222', 'partner@test.com', '+919876543211', NOW(), NOW());

INSERT INTO public.users (id, email, phone, full_name, user_type) VALUES
('22222222-2222-2222-2222-222222222222', 'partner@test.com', '+919876543211', 'Test Partner', 'partner');

INSERT INTO public.partner_profiles (user_id, services, verification_status) VALUES
('22222222-2222-2222-2222-222222222222', ARRAY['cleaning', 'plumbing'], 'verified');
*/