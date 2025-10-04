import { corsHeaders, handleCORS, createResponse, createErrorResponse, validateRequestBody, createSupabaseClient } from '../_shared/utils.ts';
import { LogoutRequestSchema, HTTP_STATUS, API_MESSAGES } from '../_shared/types.ts';

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
    const validation = await validateRequestBody(req, LogoutRequestSchema);
    if (!validation.success) {
      return createErrorResponse(validation.error, HTTP_STATUS.BAD_REQUEST);
    }

    const { refreshToken } = validation.data;

    const supabase = createSupabaseClient();

    // Sign out the user
    const { error } = await supabase.auth.admin.signOut(refreshToken);

    if (error) {
      console.error('Logout error:', error);
      // Don't fail if token is already invalid
    }

    return createResponse(
      {},
      HTTP_STATUS.OK,
      'Logged out successfully'
    );

  } catch (error) {
    console.error('Logout error:', error);
    return createErrorResponse(
      API_MESSAGES.INTERNAL_ERROR,
      HTTP_STATUS.INTERNAL_SERVER_ERROR
    );
  }
});