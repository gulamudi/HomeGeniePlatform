import { corsHeaders, handleCORS, createResponse, createErrorResponse, validateRequestBody, createSupabaseClient, getAuthUser } from '../_shared/utils.ts';
import { UpdateCustomerProfileRequestSchema, HTTP_STATUS, API_MESSAGES } from '../_shared/types.ts';

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

    // Verify user is a customer
    const { data: userProfile } = await supabase
      .from('users')
      .select('user_type')
      .eq('id', user.id)
      .single();

    if (!userProfile || userProfile.user_type !== 'customer') {
      return createErrorResponse(
        'Access denied',
        HTTP_STATUS.FORBIDDEN
      );
    }

    if (req.method === 'GET') {
      // Get customer profile
      const { data: customerProfile, error } = await supabase
        .from('users')
        .select('*, customer_profiles(*)')
        .eq('id', user.id)
        .single();

      if (error) {
        console.error('Error fetching customer profile:', error);
        return createErrorResponse(
          'Failed to fetch profile',
          HTTP_STATUS.INTERNAL_SERVER_ERROR
        );
      }

      return createResponse(customerProfile, HTTP_STATUS.OK);

    } else if (req.method === 'PUT') {
      // Update customer profile
      const validation = await validateRequestBody(req, UpdateCustomerProfileRequestSchema);
      if (!validation.success) {
        return createErrorResponse(validation.error, HTTP_STATUS.BAD_REQUEST);
      }

      const updateData = validation.data;

      // Update customer profile
      const { data: updatedProfile, error: updateError } = await supabase
        .from('customer_profiles')
        .update(updateData)
        .eq('user_id', user.id)
        .select('*')
        .single();

      if (updateError) {
        console.error('Error updating customer profile:', updateError);
        return createErrorResponse(
          'Failed to update profile',
          HTTP_STATUS.INTERNAL_SERVER_ERROR
        );
      }

      return createResponse(
        updatedProfile,
        HTTP_STATUS.OK,
        API_MESSAGES.PROFILE_UPDATED
      );

    } else {
      return createErrorResponse('Method not allowed', HTTP_STATUS.NOT_FOUND);
    }

  } catch (error) {
    console.error('Customer profile operation error:', error);
    return createErrorResponse(
      API_MESSAGES.INTERNAL_ERROR,
      HTTP_STATUS.INTERNAL_SERVER_ERROR
    );
  }
});