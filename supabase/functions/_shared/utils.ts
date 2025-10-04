import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { z } from 'https://esm.sh/zod@3.22.0';
import { ApiResponse, HTTP_STATUS } from './types.ts';

// Database client
export const createSupabaseClient = () => {
  return createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
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
  status = HTTP_STATUS.OK,
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
  status = HTTP_STATUS.BAD_REQUEST,
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
        error: `Validation failed: ${result.error.errors.map(e => e.message).join(', ')}`,
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
    return null;
  }

  const token = authHeader.substring(7);
  const supabase = createSupabaseClient();

  const { data: { user }, error } = await supabase.auth.getUser(token);
  if (error || !user) {
    return null;
  }

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