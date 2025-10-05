import { corsHeaders, handleCORS, createResponse, createErrorResponse, createSupabaseClient, getAuthUser } from '../_shared/utils.ts';
import { HTTP_STATUS, API_MESSAGES } from '../_shared/types.ts';

Deno.serve(async (req) => {
  // Handle CORS
  const corsResponse = handleCORS(req);
  if (corsResponse) return corsResponse;

  try {
    // Only allow POST method
    if (req.method !== 'POST') {
      return createErrorResponse('Method not allowed', HTTP_STATUS.NOT_FOUND);
    }

    // Get authenticated user
    const user = await getAuthUser(req);
    if (!user) {
      return createErrorResponse(
        API_MESSAGES.UNAUTHORIZED,
        HTTP_STATUS.UNAUTHORIZED
      );
    }

    const supabase = createSupabaseClient();

    // Check if user already has a user type set
    const { data: existingUser, error: fetchError } = await supabase
      .from('users')
      .select('user_type')
      .eq('id', user.id)
      .single();

    if (fetchError) {
      console.error('Error fetching user:', fetchError);
      return createErrorResponse(
        'Failed to fetch user profile',
        HTTP_STATUS.INTERNAL_SERVER_ERROR
      );
    }

    // If user is already a partner, return success
    if (existingUser?.user_type === 'partner') {
      const { data: partnerProfile } = await supabase
        .from('partner_profiles')
        .select('*')
        .eq('user_id', user.id)
        .single();

      return createResponse(
        {
          message: 'User is already set up as a partner',
          profile: partnerProfile
        },
        HTTP_STATUS.OK
      );
    }

    // Update user type to partner
    const { error: updateUserError } = await supabase
      .from('users')
      .update({ user_type: 'partner' })
      .eq('id', user.id);

    if (updateUserError) {
      console.error('Error updating user type:', updateUserError);
      return createErrorResponse(
        'Failed to update user type',
        HTTP_STATUS.INTERNAL_SERVER_ERROR
      );
    }

    // Create partner profile
    const { data: partnerProfile, error: createProfileError } = await supabase
      .from('partner_profiles')
      .insert({
        user_id: user.id,
        services: [],
        availability: {
          isAvailable: true,
          weekdays: [1, 2, 3, 4, 5], // Monday to Friday
          workingHours: {
            start: '09:00',
            end: '18:00'
          }
        },
        verification_status: 'pending',
        documents: []
      })
      .select('*')
      .single();

    if (createProfileError) {
      console.error('Error creating partner profile:', createProfileError);
      return createErrorResponse(
        'Failed to create partner profile',
        HTTP_STATUS.INTERNAL_SERVER_ERROR
      );
    }

    return createResponse(
      {
        message: 'Partner account set up successfully',
        profile: partnerProfile
      },
      HTTP_STATUS.CREATED,
      'Partner account created successfully'
    );

  } catch (error) {
    console.error('Setup partner operation error:', error);
    return createErrorResponse(
      API_MESSAGES.INTERNAL_ERROR,
      HTTP_STATUS.INTERNAL_SERVER_ERROR
    );
  }
});
