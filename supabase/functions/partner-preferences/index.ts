import { corsHeaders, handleCORS, createResponse, createErrorResponse, createSupabaseClient, getAuthUser } from '../_shared/utils.ts';
import { HTTP_STATUS, API_MESSAGES } from '../_shared/types.ts';

/**
 * Partner Preferences API
 * GET: Retrieve partner's preferences (services, availability, job preferences)
 * PUT: Update partner's preferences
 */
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

    // Verify user is a partner
    const { data: userProfile } = await supabase
      .from('users')
      .select('user_type')
      .eq('id', user.id)
      .single();

    if (!userProfile || userProfile.user_type !== 'partner') {
      return createErrorResponse(
        'Access denied. Partner account required.',
        HTTP_STATUS.FORBIDDEN
      );
    }

    if (req.method === 'GET') {
      console.log('🔍 [partnerPreferences] Getting preferences for partner:', user.id);

      // Get partner profile with preferences
      const { data: partnerProfile, error } = await supabase
        .from('partner_profiles')
        .select(`
          services,
          availability,
          job_preferences
        `)
        .eq('user_id', user.id)
        .single();

      if (error) {
        console.error('❌ [partnerPreferences] Error:', error);
        return createErrorResponse(
          'Failed to fetch preferences',
          HTTP_STATUS.INTERNAL_SERVER_ERROR
        );
      }

      console.log('✅ [partnerPreferences] Preferences retrieved');

      // Ensure we always return valid objects even if fields are explicitly null
      const services = partnerProfile?.services || [];
      const availability = (partnerProfile?.availability !== null && partnerProfile?.availability !== undefined)
        ? partnerProfile.availability
        : {
            weekdays: [1, 2, 3, 4, 5, 6],
            workingHours: { start: '08:00', end: '18:00' },
            isAvailable: true
          };
      const jobPreferences = (partnerProfile?.job_preferences !== null && partnerProfile?.job_preferences !== undefined)
        ? partnerProfile.job_preferences
        : {
            maxDistance: 10,
            preferredAreas: [],
            preferredServices: [],
            minJobValue: 0,
            autoAccept: false
          };

      return createResponse(
        {
          services,
          availability,
          jobPreferences
        },
        HTTP_STATUS.OK
      );

    } else if (req.method === 'PUT') {
      console.log('📝 [partnerPreferences] Updating preferences for partner:', user.id);

      const body = await req.json();
      const { services, availability, jobPreferences } = body;

      // Build update object
      const updates: any = {};

      if (services !== undefined) {
        if (!Array.isArray(services)) {
          return createErrorResponse(
            'services must be an array',
            HTTP_STATUS.BAD_REQUEST
          );
        }
        updates.services = services;
        console.log('   Updating services:', services);
      }

      if (availability !== undefined) {
        // Validate availability structure
        if (typeof availability !== 'object') {
          return createErrorResponse(
            'availability must be an object',
            HTTP_STATUS.BAD_REQUEST
          );
        }
        updates.availability = availability;
        console.log('   Updating availability:', availability);
      }

      if (jobPreferences !== undefined) {
        // Validate job preferences structure
        if (typeof jobPreferences !== 'object') {
          return createErrorResponse(
            'jobPreferences must be an object',
            HTTP_STATUS.BAD_REQUEST
          );
        }
        updates.job_preferences = jobPreferences;
        console.log('   Updating job preferences:', jobPreferences);
      }

      if (Object.keys(updates).length === 0) {
        return createErrorResponse(
          'No valid fields to update',
          HTTP_STATUS.BAD_REQUEST
        );
      }

      // Update partner profile
      const { data, error } = await supabase
        .from('partner_profiles')
        .update(updates)
        .eq('user_id', user.id)
        .select()
        .single();

      if (error) {
        console.error('❌ [partnerPreferences] Update error:', error);
        return createErrorResponse(
          'Failed to update preferences',
          HTTP_STATUS.INTERNAL_SERVER_ERROR
        );
      }

      console.log('✅ [partnerPreferences] Preferences updated successfully');

      return createResponse(
        {
          message: 'Preferences updated successfully',
          services: data.services,
          availability: data.availability,
          jobPreferences: data.job_preferences
        },
        HTTP_STATUS.OK
      );

    } else {
      return createErrorResponse('Method not allowed', HTTP_STATUS.METHOD_NOT_ALLOWED);
    }

  } catch (error) {
    console.error('❌ [partnerPreferences] Error:', error);
    return createErrorResponse(
      API_MESSAGES.INTERNAL_ERROR,
      HTTP_STATUS.INTERNAL_SERVER_ERROR
    );
  }
});
