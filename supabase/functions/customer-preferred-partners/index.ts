import { corsHeaders, handleCORS, createResponse, createErrorResponse, createSupabaseClient, getAuthUser } from '../_shared/utils.ts';
import { HTTP_STATUS, API_MESSAGES } from '../_shared/types.ts';

/**
 * Get preferred partners for a customer
 * Returns partners who have worked with this customer before
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
    const url = new URL(req.url);

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
      // Get query parameters
      const serviceId = url.searchParams.get('serviceId');
      const scheduledDate = url.searchParams.get('scheduledDate');
      const durationHours = parseFloat(url.searchParams.get('durationHours') || '2');
      const limit = parseInt(url.searchParams.get('limit') || '3');

      if (!serviceId || !scheduledDate) {
        return createErrorResponse(
          'serviceId and scheduledDate are required',
          HTTP_STATUS.BAD_REQUEST
        );
      }

      console.log('🔍 [preferredPartners] Getting preferred partners for customer:', user.id);
      console.log('   Service ID:', serviceId);
      console.log('   Scheduled Date:', scheduledDate);
      console.log('   Duration:', durationHours, 'hours');
      console.log('   Limit:', limit);

      // Call database function to get preferred partners
      const { data: preferredPartners, error } = await supabase.rpc('get_preferred_partners', {
        p_customer_id: user.id,
        p_service_id: serviceId,
        p_scheduled_date: scheduledDate,
        p_duration_hours: durationHours,
        p_limit: limit
      });

      if (error) {
        console.error('❌ [preferredPartners] Error:', error);
        return createErrorResponse(
          'Failed to fetch preferred partners',
          HTTP_STATUS.INTERNAL_SERVER_ERROR
        );
      }

      console.log(`✅ [preferredPartners] Found ${preferredPartners?.length || 0} preferred partners`);

      // Transform to match expected format
      const transformedPartners = (preferredPartners || []).map((p: any) => ({
        id: p.partner_id,
        name: p.partner_name,
        phone: p.partner_phone,
        avatarUrl: p.avatar_url,
        rating: parseFloat(p.rating || '0'),
        totalJobs: p.total_jobs,
        lastServiceDate: p.last_service_date,
        servicesCount: p.services_count,
        lastServiceName: p.last_service_name,
        worked_with_you: true, // All preferred partners have worked with customer
      }));

      return createResponse(
        {
          partners: transformedPartners,
          count: transformedPartners.length,
        },
        HTTP_STATUS.OK
      );

    } else {
      return createErrorResponse('Method not allowed', HTTP_STATUS.METHOD_NOT_ALLOWED);
    }

  } catch (error) {
    console.error('❌ [preferredPartners] Error:', error);
    return createErrorResponse(
      API_MESSAGES.INTERNAL_ERROR,
      HTTP_STATUS.INTERNAL_SERVER_ERROR
    );
  }
});
