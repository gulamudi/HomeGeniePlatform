import { corsHeaders, handleCORS, createResponse, createErrorResponse, validateRequestBody, createSupabaseClient, verifyOTP, createUserProfile } from '../_shared/utils.ts';
import { VerifyOtpRequestSchema, HTTP_STATUS, API_MESSAGES, ERROR_CODES } from '../_shared/types.ts';

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
    const validation = await validateRequestBody(req, VerifyOtpRequestSchema);
    if (!validation.success) {
      return createErrorResponse(validation.error, HTTP_STATUS.BAD_REQUEST);
    }

    const { phone, otp, sessionId } = validation.data;

    const supabase = createSupabaseClient();

    // Get OTP session
    const { data: otpSession, error: sessionError } = await supabase
      .from('otp_sessions')
      .select('*')
      .eq('id', sessionId)
      .eq('phone', phone)
      .eq('verified', false)
      .single();

    if (sessionError || !otpSession) {
      return createErrorResponse(ERROR_CODES.INVALID_OTP, HTTP_STATUS.BAD_REQUEST);
    }

    // Check if OTP is expired
    if (new Date() > new Date(otpSession.expires_at)) {
      await supabase.from('otp_sessions').delete().eq('id', sessionId);
      return createErrorResponse(ERROR_CODES.OTP_EXPIRED, HTTP_STATUS.BAD_REQUEST);
    }

    // Check attempts limit
    if (otpSession.attempts >= 5) {
      await supabase.from('otp_sessions').delete().eq('id', sessionId);
      return createErrorResponse('Too many attempts', HTTP_STATUS.BAD_REQUEST);
    }

    // Verify OTP
    const isValidOTP = await verifyOTP(otp, otpSession.otp_hash);
    if (!isValidOTP) {
      // Increment attempts
      await supabase
        .from('otp_sessions')
        .update({ attempts: otpSession.attempts + 1 })
        .eq('id', sessionId);

      return createErrorResponse(ERROR_CODES.INVALID_OTP, HTTP_STATUS.BAD_REQUEST);
    }

    // Mark session as verified
    await supabase
      .from('otp_sessions')
      .update({ verified: true })
      .eq('id', sessionId);

    // Check if user exists
    const { data: existingUser } = await supabase
      .from('users')
      .select('*, customer_profiles(*), partner_profiles(*)')
      .eq('phone', phone)
      .single();

    let user = existingUser;
    let isNewUser = false;

    if (!existingUser) {
      // Create new user
      isNewUser = true;

      // Create auth user
      const { data: authUser, error: authError } = await supabase.auth.admin.createUser({
        phone,
        phone_confirm: true,
        user_metadata: {
          phone,
          user_type: otpSession.user_type,
        },
      });

      if (authError || !authUser.user) {
        console.error('Error creating auth user:', authError);
        return createErrorResponse('Failed to create user', HTTP_STATUS.INTERNAL_SERVER_ERROR);
      }

      // Create user profile
      try {
        await createUserProfile(authUser.user.id, {
          phone,
          fullName: `User ${phone.slice(-4)}`, // Temporary name
          userType: otpSession.user_type,
        });

        // Fetch the created user
        const { data: newUser } = await supabase
          .from('users')
          .select('*, customer_profiles(*), partner_profiles(*)')
          .eq('id', authUser.user.id)
          .single();

        user = newUser;
      } catch (error) {
        console.error('Error creating user profile:', error);
        return createErrorResponse('Failed to create user profile', HTTP_STATUS.INTERNAL_SERVER_ERROR);
      }
    }

    if (!user) {
      return createErrorResponse(ERROR_CODES.USER_NOT_FOUND, HTTP_STATUS.NOT_FOUND);
    }

    // Generate JWT tokens
    const { data: tokenData, error: tokenError } = await supabase.auth.admin.generateLink({
      type: 'magiclink',
      phone,
    });

    if (tokenError || !tokenData) {
      console.error('Error generating tokens:', tokenError);
      return createErrorResponse('Failed to generate tokens', HTTP_STATUS.INTERNAL_SERVER_ERROR);
    }

    // Clean up OTP session
    await supabase.from('otp_sessions').delete().eq('id', sessionId);

    return createResponse(
      {
        user,
        accessToken: tokenData.properties?.access_token || '',
        refreshToken: tokenData.properties?.refresh_token || '',
        isNewUser,
      },
      HTTP_STATUS.OK,
      API_MESSAGES.OTP_VERIFIED
    );

  } catch (error) {
    console.error('OTP verification error:', error);
    return createErrorResponse(
      API_MESSAGES.INTERNAL_ERROR,
      HTTP_STATUS.INTERNAL_SERVER_ERROR
    );
  }
});