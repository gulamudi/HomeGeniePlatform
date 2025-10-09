-- ========================================
-- SEED DATA FOR HOMEGENIE - PUNE OPERATIONS
-- ========================================
-- Service areas, services, and initial configuration
-- All data is specific to Pune (Amanora, Magarpatta, etc.)

-- ========================================
-- SERVICE AREAS (Pune Specific)
-- ========================================
INSERT INTO public.service_areas (id, name, city, state, center_location, radius_km, is_active, display_order) VALUES
-- Major residential areas in Pune
('550e8400-e29b-41d4-a716-446655440101', 'Amanora Town Centre', 'Pune', 'Maharashtra', ST_MakePoint(73.9393, 18.5566)::geography, 5.0, true, 1),
('550e8400-e29b-41d4-a716-446655440102', 'Magarpatta City', 'Pune', 'Maharashtra', ST_MakePoint(73.9344, 18.5196)::geography, 5.0, true, 2),
('550e8400-e29b-41d4-a716-446655440103', 'Koregaon Park', 'Pune', 'Maharashtra', ST_MakePoint(73.8929, 18.5435)::geography, 3.0, true, 3),
('550e8400-e29b-41d4-a716-446655440104', 'Viman Nagar', 'Pune', 'Maharashtra', ST_MakePoint(73.9187, 18.5679)::geography, 4.0, true, 4),
('550e8400-e29b-41d4-a716-446655440105', 'Kharadi', 'Pune', 'Maharashtra', ST_MakePoint(73.9482, 18.5511)::geography, 4.0, true, 5),
('550e8400-e29b-41d4-a716-446655440106', 'Hadapsar', 'Pune', 'Maharashtra', ST_MakePoint(73.9333, 18.5089)::geography, 4.0, true, 6),
('550e8400-e29b-41d4-a716-446655440107', 'Baner', 'Pune', 'Maharashtra', ST_MakePoint(73.7789, 18.5593)::geography, 4.0, true, 7),
('550e8400-e29b-41d4-a716-446655440108', 'Wakad', 'Pune', 'Maharashtra', ST_MakePoint(73.7539, 18.5984)::geography, 4.0, true, 8),
('550e8400-e29b-41d4-a716-446655440109', 'Hinjewadi', 'Pune', 'Maharashtra', ST_MakePoint(73.7294, 18.5989)::geography, 5.0, true, 9),
('550e8400-e29b-41d4-a716-446655440110', 'Pimple Saudagar', 'Pune', 'Maharashtra', ST_MakePoint(73.8050, 18.5937)::geography, 3.0, true, 10);

-- ========================================
-- SERVICES (Real Pune Services)
-- ========================================

-- CLEANING SERVICES
INSERT INTO public.services (id, name, description, category, base_price, duration_hours, requirements, includes, excludes, image_url, is_active) VALUES
-- Basic Cleaning
('550e8400-e29b-41d4-a716-446655440001', 'Basic House Cleaning', 'Standard cleaning service including sweeping, mopping, and dusting', 'cleaning', 399.00, 2.0,
 ARRAY['Access to all rooms', 'Water and power supply'],
 ARRAY['Sweeping all rooms', 'Mopping floors', 'Dusting surfaces', 'Bathroom cleaning', 'Kitchen counter cleaning'],
 ARRAY['Utensil washing', 'Laundry', 'Deep cleaning', 'Appliance interior cleaning'],
 NULL, true),

('550e8400-e29b-41d4-a716-446655440002', 'Deep House Cleaning', 'Comprehensive deep cleaning of entire house', 'cleaning', 799.00, 4.0,
 ARRAY['Full day access', 'Water and power supply'],
 ARRAY['Detailed cleaning of all surfaces', 'Bathroom deep clean with scrubbing', 'Kitchen deep clean including cabinets', 'Floor scrubbing', 'Window cleaning', 'Balcony cleaning'],
 ARRAY['Carpet shampooing', 'Furniture polish', 'Pest control'],
 NULL, true),

('550e8400-e29b-41d4-a716-446655440003', 'Bathroom Deep Cleaning', 'Complete bathroom cleaning and sanitization', 'cleaning', 299.00, 1.5,
 ARRAY['Access to bathroom', 'Water supply'],
 ARRAY['Tile and grout scrubbing', 'Sink and fixture cleaning', 'Toilet deep clean', 'Mirror cleaning', 'Floor scrubbing', 'Drain cleaning'],
 ARRAY['Plumbing repairs', 'Tile replacement'],
 NULL, true),

('550e8400-e29b-41d4-a716-446655440004', 'Kitchen Deep Cleaning', 'Thorough kitchen cleaning and degreasing', 'cleaning', 449.00, 2.5,
 ARRAY['Access to kitchen', 'Water and power supply'],
 ARRAY['Cabinet cleaning inside and out', 'Countertop degreasing', 'Sink and drain cleaning', 'Appliance exterior cleaning', 'Floor mopping', 'Chimney exterior cleaning'],
 ARRAY['Utensil washing', 'Appliance interior', 'Chimney deep service'],
 NULL, true),

-- PLUMBING SERVICES
('550e8400-e29b-41d4-a716-446655440005', 'Plumbing Repair - Basic', 'Fix leaks, unclog drains, and minor plumbing issues', 'plumbing', 349.00, 1.5,
 ARRAY['Access to affected areas', 'Water supply control'],
 ARRAY['Leak detection and repair', 'Drain unclogging', 'Tap repair/replacement', 'Pipe joint repair'],
 ARRAY['Major pipe replacement', 'Bathroom renovation', 'Tank installation'],
 NULL, true),

('550e8400-e29b-41d4-a716-446655440006', 'Bathroom Fitting Installation', 'Installation of taps, showers, and bathroom fixtures', 'plumbing', 499.00, 2.0,
 ARRAY['Access to bathroom', 'Fixtures provided by customer'],
 ARRAY['Tap installation', 'Shower installation', 'Health faucet installation', 'Connection testing'],
 ARRAY['Tile work', 'Electrical work', 'Fixtures cost'],
 NULL, true),

-- ELECTRICAL SERVICES
('550e8400-e29b-41d4-a716-446655440007', 'Electrical Repair - Basic', 'Switch, socket, and wiring repairs', 'electrical', 399.00, 1.5,
 ARRAY['Power access', 'Safety clearance'],
 ARRAY['Switch/socket replacement', 'Fan regulator repair', 'Light fixture repair', 'MCB replacement', 'Wiring checks'],
 ARRAY['Complete rewiring', 'Panel upgrades', 'New connection'],
 NULL, true),

('550e8400-e29b-41d4-a716-446655440008', 'Light and Fan Installation', 'Installation of lights, fans, and fixtures', 'electrical', 299.00, 1.0,
 ARRAY['Power access', 'Fixtures provided by customer'],
 ARRAY['Ceiling fan installation', 'Light fixture installation', 'Wall light installation', 'Connection and testing'],
 ARRAY['Wiring extension', 'New point creation', 'Fixture cost'],
 NULL, true),

-- AC SERVICES
('550e8400-e29b-41d4-a716-446655440009', 'AC Service (Split/Window)', 'Complete AC cleaning and servicing', 'appliance_repair', 499.00, 1.5,
 ARRAY['AC access', 'Power and water supply'],
 ARRAY['Filter cleaning', 'Coil cleaning', 'Gas check', 'Drain cleaning', 'Overall inspection'],
 ARRAY['Gas refilling', 'Part replacement', 'Major repairs'],
 NULL, true),

('550e8400-e29b-41d4-a716-446655440010', 'AC Installation (Split)', 'Professional split AC installation', 'appliance_repair', 899.00, 3.0,
 ARRAY['AC unit provided', 'Wall mounting space', 'Power point available'],
 ARRAY['Indoor and outdoor unit mounting', 'Pipe connections', 'Gas charging', 'Testing'],
 ARRAY['Electrical point creation', 'Additional piping beyond 3 meters', 'AC unit cost'],
 NULL, true),

-- PAINTING SERVICES
('550e8400-e29b-41d4-a716-446655440011', 'Room Painting', 'Professional room painting service', 'painting', 4999.00, 8.0,
 ARRAY['Empty room preferred', 'Multiple day access'],
 ARRAY['Surface preparation', 'Primer application', '2 coats of paint', 'Ceiling painting', 'Minor putty work'],
 ARRAY['Furniture moving', 'Major wall repairs', 'Paint cost'],
 NULL, true),

('550e8400-e29b-41d4-a716-446655440012', 'Exterior Painting', 'Building exterior and balcony painting', 'painting', 2999.00, 6.0,
 ARRAY['Exterior access', 'Weather conditions suitable'],
 ARRAY['Surface cleaning', 'Waterproof paint application', '2 coats', 'Railing painting'],
 ARRAY['Major wall repairs', 'Height work beyond 2 floors', 'Paint cost'],
 NULL, true),

-- PEST CONTROL
('550e8400-e29b-41d4-a716-446655440013', 'General Pest Control', 'Comprehensive pest control treatment', 'pest_control', 799.00, 2.0,
 ARRAY['Empty space during treatment', '3-4 hours drying time'],
 ARRAY['Cockroach treatment', 'Ant treatment', 'Spider treatment', 'All rooms coverage', '30-day warranty'],
 ARRAY['Termite treatment', 'Bedbug treatment', 'Furniture treatment'],
 NULL, true),

('550e8400-e29b-41d4-a716-446655440014', 'Termite Control', 'Advanced termite treatment and prevention', 'pest_control', 1499.00, 3.0,
 ARRAY['Access to affected areas', 'Furniture movable'],
 ARRAY['Pre-treatment inspection', 'Chemical treatment', 'Wood treatment', 'Soil treatment', '90-day warranty'],
 ARRAY['Major structural repairs', 'Furniture replacement'],
 NULL, true);

-- ========================================
-- APP SETTINGS (Already created by migration, but adding more)
-- ========================================
-- Add Pune-specific settings
INSERT INTO public.app_settings (key, value, category, description) VALUES
('location.default_city', '"Pune"', 'location', 'Default city for operations'),
('location.default_state', '"Maharashtra"', 'location', 'Default state'),
('services.cleaning.popular_times', '["09:00", "10:00", "14:00", "15:00"]', 'general', 'Popular booking times for cleaning services'),
('booking.advance_booking_days', '14', 'booking', 'Maximum days in advance a booking can be made'),
('booking.min_booking_hours', '4', 'booking', 'Minimum hours before service time to book')
ON CONFLICT (key) DO NOTHING;

-- ========================================
-- NOTES
-- ========================================
-- 1. No test user data included - users will be created through auth flow
-- 2. All coordinates are real Pune locations
-- 3. Prices are in INR (Rupees)
-- 4. Services are based on real home service offerings in Pune
-- 5. Service categories match the enum in database schema
-- 6. All services include realistic requirements, includes, and excludes

-- Log completion
DO $$
BEGIN
  RAISE NOTICE '✅ Seed data loaded successfully';
  RAISE NOTICE '   - Service Areas: 10 (Pune)';
  RAISE NOTICE '   - Services: 14 (Cleaning, Plumbing, Electrical, AC, Painting, Pest Control)';
  RAISE NOTICE '   - App Settings: 15+';
END $$;
