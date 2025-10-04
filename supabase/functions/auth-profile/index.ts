import { corsHeaders, handleCORS, createResponse, createErrorResponse, validateRequestBody, createSupabaseClient, getAuthUser } from '../_shared/utils.ts';
import { UpdateProfileRequestSchema, HTTP_STATUS, API_MESSAGES } from '../_shared/types.ts';

Deno.serve(async (req) => {
  // Handle CORS
  const corsResponse = handleCORS(req);
  if (corsResponse) return corsResponse;

  try {
    // Get authenticated user
    const user = await getAuthUser(req);
    if (!user) {
      return createErrorResponse(
        API_MESSAGES.UNAUTHORIZED,
        HTTP_STATUS.UNAUTHORIZED
      );
    }

    const supabase = createSupabaseClient();

    if (req.method === 'GET') {
      // Get user profile
      const { data: userProfile, error } = await supabase
        .from('users')
        .select('*, customer_profiles(*), partner_profiles(*)')
        .eq('id', user.id)
        .single();

      if (error) {
        console.error('Error fetching user profile:', error);
        return createErrorResponse(
          'Failed to fetch profile',
          HTTP_STATUS.INTERNAL_SERVER_ERROR
        );
      }

      return createResponse(userProfile, HTTP_STATUS.OK);

    } else if (req.method === 'PUT') {
      // Update user profile
      const validation = await validateRequestBody(req, UpdateProfileRequestSchema);
      if (!validation.success) {
        return createErrorResponse(validation.error, HTTP_STATUS.BAD_REQUEST);
      }

      const updateData = validation.data;

      // Update user table
      const { data: updatedUser, error: updateError } = await supabase
        .from('users')
        .update({
          ...(updateData.fullName && { full_name: updateData.fullName }),
          ...(updateData.email && { email: updateData.email }),
          ...(updateData.avatarUrl && { avatar_url: updateData.avatarUrl }),
        })
        .eq('id', user.id)
        .select('*, customer_profiles(*), partner_profiles(*)')
        .single();

      if (updateError) {
        console.error('Error updating user profile:', updateError);
        return createErrorResponse(
          'Failed to update profile',
          HTTP_STATUS.INTERNAL_SERVER_ERROR
        );
      }

      return createResponse(
        updatedUser,
        HTTP_STATUS.OK,
        API_MESSAGES.PROFILE_UPDATED
      );

    } else {
      return createErrorResponse('Method not allowed', HTTP_STATUS.NOT_FOUND);
    }

  } catch (error) {
    console.error('Profile operation error:', error);
    return createErrorResponse(
      API_MESSAGES.INTERNAL_ERROR,
      HTTP_STATUS.INTERNAL_SERVER_ERROR
    );
  }
});