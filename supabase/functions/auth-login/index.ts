import { corsHeaders, handleCORS, createResponse, createErrorResponse, validateRequestBody, createSupabaseClient, generateOTP, hashOTP, formatPhoneNumber } from '../_shared/utils.ts';
import { LoginRequestSchema, HTTP_STATUS, API_MESSAGES } from '../_shared/types.ts';

Deno.serve(async (req) => {
  // Handle CORS
  const corsResponse = handleCORS(req);
  if (corsResponse) return corsResponse;

  try {
    // Validate request method
    if (req.method !== 'POST') {
      return createErrorResponse('Method not allowed', HTTP_STATUS.NOT_FOUND);
    }

    // Validate request body
    const validation = await validateRequestBody(req, LoginRequestSchema);
    if (!validation.success) {
      return createErrorResponse(validation.error, HTTP_STATUS.BAD_REQUEST);
    }

    const { phone, userType } = validation.data;
    const formattedPhone = formatPhoneNumber(phone);

    // Generate OTP
    const otp = generateOTP();
    const otpHash = await hashOTP(otp);

    // Create session ID
    const sessionId = crypto.randomUUID();

    const supabase = createSupabaseClient();

    // Clean up old OTP sessions for this phone
    await supabase
      .from('otp_sessions')
      .delete()
      .eq('phone', formattedPhone);

    // Store OTP session
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes
    const { error: otpError } = await supabase
      .from('otp_sessions')
      .insert({
        id: sessionId,
        phone: formattedPhone,
        otp_hash: otpHash,
        user_type: userType,
        expires_at: expiresAt.toISOString(),
      });

    if (otpError) {
      console.error('Error storing OTP session:', otpError);
      return createErrorResponse('Failed to initiate login', HTTP_STATUS.INTERNAL_SERVER_ERROR);
    }

    // TODO: Send OTP via SMS service (Twilio, etc.)
    // For development, log the OTP
    console.log(`OTP for ${formattedPhone}: ${otp}`);

    // In development mode, return OTP in response (remove in production)
    const isDevelopment = Deno.env.get('ENVIRONMENT') === 'development';

    return createResponse(
      {
        sessionId,
        otpSent: true,
        // Only include OTP in development
        ...(isDevelopment && { otp }),
      },
      HTTP_STATUS.OK,
      API_MESSAGES.OTP_SENT
    );

  } catch (error) {
    console.error('Login error:', error);
    return createErrorResponse(
      API_MESSAGES.INTERNAL_ERROR,
      HTTP_STATUS.INTERNAL_SERVER_ERROR
    );
  }
});