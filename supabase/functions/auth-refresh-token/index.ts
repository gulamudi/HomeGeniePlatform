import { corsHeaders, handleCORS, createResponse, createErrorResponse, validateRequestBody, createSupabaseClient } from '../_shared/utils.ts';
import { RefreshTokenRequestSchema, HTTP_STATUS, API_MESSAGES } from '../_shared/types.ts';

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
    const validation = await validateRequestBody(req, RefreshTokenRequestSchema);
    if (!validation.success) {
      return createErrorResponse(validation.error, HTTP_STATUS.BAD_REQUEST);
    }

    const { refreshToken } = validation.data;

    const supabase = createSupabaseClient();

    // Refresh the session
    const { data, error } = await supabase.auth.refreshSession({
      refresh_token: refreshToken,
    });

    if (error || !data.session) {
      return createErrorResponse(
        'Invalid refresh token',
        HTTP_STATUS.UNAUTHORIZED
      );
    }

    return createResponse(
      {
        accessToken: data.session.access_token,
        refreshToken: data.session.refresh_token,
      },
      HTTP_STATUS.OK,
      'Token refreshed successfully'
    );

  } catch (error) {
    console.error('Token refresh error:', error);
    return createErrorResponse(
      API_MESSAGES.INTERNAL_ERROR,
      HTTP_STATUS.INTERNAL_SERVER_ERROR
    );
  }
});