import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { z } from 'https://esm.sh/zod@3.22.0';
import { ApiResponse, HTTP_STATUS } from './types.ts';

// Database client
export const createSupabaseClient = () => {
  const supabaseUrl = Deno.env.get('SUPABASE_URL');
  const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');

  // Log environment configuration status
  if (!supabaseUrl || !serviceRoleKey) {
    console.error('❌ CRITICAL: Supabase environment variables missing!');
    console.error(`  SUPABASE_URL: ${supabaseUrl ? '✓ Set' : '✗ MISSING'}`);
    console.error(`  SUPABASE_SERVICE_ROLE_KEY: ${serviceRoleKey ? '✓ Set' : '✗ MISSING'}`);
    console.error('  Fix: Ensure Supabase is running locally or env vars are configured');
  } else {
    console.log('✓ Supabase client initialized successfully');
    console.log(`  URL: ${supabaseUrl}`);
  }

  return createClient(
    supabaseUrl ?? '',
    serviceRoleKey ?? '',
    {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
      },
    }
  );
};

// Response helpers
export const createResponse = <T>(
  data: T,
  status: number,
  message?: string
): Response => {
  const response: ApiResponse<T> = {
    success: status < 400,
    data,
    message,
  };

  return new Response(JSON.stringify(response), {
    headers: { 'Content-Type': 'application/json' },
    status,
  });
};

export const createErrorResponse = (
  error: string,
  status: number,
  message?: string
): Response => {
  const response: ApiResponse<null> = {
    success: false,
    error,
    message,
  };

  return new Response(JSON.stringify(response), {
    headers: { 'Content-Type': 'application/json' },
    status,
  });
};

// Validation helpers
export const validateRequestBody = async <T>(
  request: Request,
  schema: z.ZodSchema<T>
): Promise<{ success: true; data: T } | { success: false; error: string }> => {
  try {
    const body = await request.json();
    const result = schema.safeParse(body);

    if (!result.success) {
      return {
        success: false,
        error: `Validation failed: ${result.error.errors.map((e: any) => e.message).join(', ')}`,
      };
    }

    return { success: true, data: result.data };
  } catch (error) {
    return {
      success: false,
      error: 'Invalid JSON in request body',
    };
  }
};

// JWT helpers
export const getAuthUser = async (request: Request) => {
  const authHeader = request.headers.get('Authorization');
  if (!authHeader?.startsWith('Bearer ')) {
    console.warn('⚠️  Authentication failed: No Bearer token provided');
    console.warn('  Fix: Ensure the client app is sending Authorization header');
    return null;
  }

  const token = authHeader.substring(7);
  const supabase = createSupabaseClient();

  const { data: { user }, error } = await supabase.auth.getUser(token);
  if (error || !user) {
    console.error('❌ Authentication failed: Invalid or expired token');
    console.error(`  Error: ${error?.message || 'User not found'}`);
    console.error('  Fix: User may need to re-authenticate');
    return null;
  }

  console.log(`✓ User authenticated: ${user.id}`);
  return user;
};

// OTP helpers
export const generateOTP = (): string => {
  return Math.floor(100000 + Math.random() * 900000).toString();
};

export const hashOTP = async (otp: string): Promise<string> => {
  const encoder = new TextEncoder();
  const data = encoder.encode(otp);
  const hashBuffer = await crypto.subtle.digest('SHA-256', data);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  return hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
};

export const verifyOTP = async (otp: string, hash: string): Promise<boolean> => {
  const otpHash = await hashOTP(otp);
  return otpHash === hash;
};

// CORS helpers
export const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
};

export const handleCORS = (request: Request): Response | null => {
  if (request.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }
  return null;
};

// Database helpers
export const createUserProfile = async (
  userId: string,
  userData: {
    email?: string;
    phone: string;
    fullName: string;
    userType: 'customer' | 'partner';
  }
) => {
  const supabase = createSupabaseClient();

  // Insert user
  const { error: userError } = await supabase
    .from('users')
    .insert({
      id: userId,
      email: userData.email,
      phone: userData.phone,
      full_name: userData.fullName,
      user_type: userData.userType,
    });

  if (userError) throw userError;

  // Insert profile based on user type
  if (userData.userType === 'customer') {
    const { error: profileError } = await supabase
      .from('customer_profiles')
      .insert({ user_id: userId });

    if (profileError) throw profileError;
  } else {
    const { error: profileError } = await supabase
      .from('partner_profiles')
      .insert({ user_id: userId });

    if (profileError) throw profileError;
  }
};

// Phone number formatting
export const formatPhoneNumber = (phone: string): string => {
  // Remove all non-digit characters
  let cleaned = phone.replace(/\D/g, '');

  // Add country code if not present
  if (cleaned.length === 10) {
    cleaned = '91' + cleaned; // Default to India
  }

  // Ensure it starts with +
  if (!cleaned.startsWith('+')) {
    cleaned = '+' + cleaned;
  }

  return cleaned;
};

// Data transformation helpers
export const transformAddressToDb = (address: any) => {
  if (!address) return null;
  return {
    id: address.id,
    flat_house_no: address.flatHouseNo,
    building_apartment_name: address.buildingApartmentName,
    street_name: address.streetName,
    landmark: address.landmark,
    area: address.area,
    city: address.city,
    state: address.state,
    pin_code: address.pinCode,
    type: address.type,
    is_default: address.isDefault,
  };
};

export const transformAddressFromDb = (address: any) => {
  if (!address) return null;
  return {
    id: address.id,
    flatHouseNo: address.flat_house_no,
    buildingApartmentName: address.building_apartment_name,
    streetName: address.street_name,
    landmark: address.landmark,
    area: address.area,
    city: address.city,
    state: address.state,
    pinCode: address.pin_code,
    type: address.type,
    isDefault: address.is_default,
  };
};

export const transformBookingFromDb = (booking: any) => {
  if (!booking) return null;
  return {
    id: booking.id,
    customerId: booking.customer_id,
    partnerId: booking.partner_id,
    serviceId: booking.service_id,
    status: booking.status,
    scheduledDate: booking.scheduled_date,
    durationHours: booking.duration_hours,
    address: transformAddressFromDb(booking.address),
    totalAmount: booking.total_amount,
    paymentMethod: booking.payment_method,
    paymentStatus: booking.payment_status,
    specialInstructions: booking.special_instructions,
    preferredPartnerId: booking.preferred_partner_id,
    createdAt: booking.created_at,
    updatedAt: booking.updated_at,
    service: booking.service,
    customer: booking.customer,
    partner: booking.partner,
    booking_timeline: booking.booking_timeline,
    ratings: booking.ratings,
  };
};

export const transformServiceFromDb = (service: any) => {
  if (!service) return null;
  return {
    id: service.id,
    name: service.name,
    description: service.description,
    category: service.category,
    basePrice: service.base_price,
    durationHours: service.duration_hours,
    isActive: service.is_active,
    requirements: service.requirements || [],
    includes: service.includes || [],
    excludes: service.excludes || [],
    imageUrl: service.image_url,
    createdAt: service.created_at,
    updatedAt: service.updated_at,
    servicePricingTiers: service.service_pricing_tiers?.map((tier: any) => ({
      id: tier.id,
      serviceId: tier.service_id,
      name: tier.name,
      description: tier.description,
      price: tier.price,
      durationHours: tier.duration_hours,
      isDefault: tier.is_default,
      createdAt: tier.created_at,
      updatedAt: tier.updated_at,
    })) || [],
  };
};
