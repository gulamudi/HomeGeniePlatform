-- Seed sample service areas for Mumbai and Pune
-- This provides test data for partner preference selection

-- Mumbai Areas
INSERT INTO public.service_areas (name, city, state, center_location, radius_km, is_active, display_order) VALUES
('Andheri', 'Mumbai', 'Maharashtra', ST_SetSRID(ST_MakePoint(72.8697, 19.1136), 4326)::geography, 5.0, true, 1),
('Bandra', 'Mumbai', 'Maharashtra', ST_SetSRID(ST_MakePoint(72.8397, 19.0596), 4326)::geography, 4.0, true, 2),
('Powai', 'Mumbai', 'Maharashtra', ST_SetSRID(ST_MakePoint(72.9050, 19.1176), 4326)::geography, 5.0, true, 3),
('Borivali', 'Mumbai', 'Maharashtra', ST_SetSRID(ST_MakePoint(72.8567, 19.2304), 4326)::geography, 6.0, true, 4),
('Thane', 'Mumbai', 'Maharashtra', ST_SetSRID(ST_MakePoint(72.9781, 19.2183), 4326)::geography, 7.0, true, 5),
('Navi Mumbai', 'Mumbai', 'Maharashtra', ST_SetSRID(ST_MakePoint(73.0297, 19.0330), 4326)::geography, 8.0, true, 6),
('Malad', 'Mumbai', 'Maharashtra', ST_SetSRID(ST_MakePoint(72.8484, 19.1864), 4326)::geography, 5.0, true, 7),
('Goregaon', 'Mumbai', 'Maharashtra', ST_SetSRID(ST_MakePoint(72.8490, 19.1550), 4326)::geography, 4.5, true, 8),
('Dadar', 'Mumbai', 'Maharashtra', ST_SetSRID(ST_MakePoint(72.8432, 19.0176), 4326)::geography, 3.5, true, 9),
('Worli', 'Mumbai', 'Maharashtra', ST_SetSRID(ST_MakePoint(72.8161, 19.0133), 4326)::geography, 3.0, true, 10);

-- Pune Areas
INSERT INTO public.service_areas (name, city, state, center_location, radius_km, is_active, display_order) VALUES
('Koregaon Park', 'Pune', 'Maharashtra', ST_SetSRID(ST_MakePoint(73.8938, 18.5406), 4326)::geography, 4.0, true, 11),
('Hinjewadi', 'Pune', 'Maharashtra', ST_SetSRID(ST_MakePoint(73.7244, 18.5912), 4326)::geography, 6.0, true, 12),
('Kharadi', 'Pune', 'Maharashtra', ST_SetSRID(ST_MakePoint(73.9476, 18.5517), 4326)::geography, 5.0, true, 13),
('Baner', 'Pune', 'Maharashtra', ST_SetSRID(ST_MakePoint(73.7877, 18.5590), 4326)::geography, 5.0, true, 14),
('Wakad', 'Pune', 'Maharashtra', ST_SetSRID(ST_MakePoint(73.7623, 18.5985), 4326)::geography, 4.5, true, 15),
('Viman Nagar', 'Pune', 'Maharashtra', ST_SetSRID(ST_MakePoint(73.9183, 18.5679), 4326)::geography, 4.0, true, 16),
('Hadapsar', 'Pune', 'Maharashtra', ST_SetSRID(ST_MakePoint(73.9262, 18.5018), 4326)::geography, 5.5, true, 17),
('Pimpri-Chinchwad', 'Pune', 'Maharashtra', ST_SetSRID(ST_MakePoint(73.8012, 18.6298), 4326)::geography, 7.0, true, 18);

-- Log the seeding
DO $$
BEGIN
  RAISE NOTICE '✅ Seeded service_areas table with 18 sample areas (10 Mumbai, 8 Pune)';
END $$;
