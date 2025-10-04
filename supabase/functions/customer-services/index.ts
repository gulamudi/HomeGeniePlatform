import { corsHeaders, handleCORS, createResponse, createErrorResponse, validateRequestBody, createSupabaseClient, getAuthUser } from '../_shared/utils.ts';
import { GetServicesRequestSchema, GetServiceDetailsRequestSchema, HTTP_STATUS, API_MESSAGES } from '../_shared/types.ts';

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

    if (req.method === 'GET') {
      const serviceId = url.pathname.split('/').pop();

      if (serviceId && serviceId !== 'customer-services') {
        // Get specific service details
        const { data: service, error } = await supabase
          .from('services')
          .select(`
            *,
            service_pricing_tiers(*)
          `)
          .eq('id', serviceId)
          .eq('is_active', true)
          .single();

        if (error || !service) {
          return createErrorResponse(
            'Service not found',
            HTTP_STATUS.NOT_FOUND
          );
        }

        return createResponse(service, HTTP_STATUS.OK);

      } else {
        // Get all services with filters
        const category = url.searchParams.get('category');
        const search = url.searchParams.get('search');
        const page = parseInt(url.searchParams.get('page') || '1');
        const limit = parseInt(url.searchParams.get('limit') || '20');

        let query = supabase
          .from('services')
          .select(`
            *,
            service_pricing_tiers(*)
          `, { count: 'exact' })
          .eq('is_active', true);

        // Apply filters
        if (category) {
          query = query.eq('category', category);
        }

        if (search) {
          query = query.or(`name.ilike.%${search}%,description.ilike.%${search}%`);
        }

        // Apply pagination
        const from = (page - 1) * limit;
        const to = from + limit - 1;
        query = query.range(from, to);

        const { data: services, error, count } = await query;

        if (error) {
          console.error('Error fetching services:', error);
          return createErrorResponse(
            'Failed to fetch services',
            HTTP_STATUS.INTERNAL_SERVER_ERROR
          );
        }

        const totalPages = count ? Math.ceil(count / limit) : 0;

        return createResponse(
          {
            services: services || [],
            pagination: {
              page,
              limit,
              total: count || 0,
              totalPages,
            },
          },
          HTTP_STATUS.OK
        );
      }

    } else {
      return createErrorResponse('Method not allowed', HTTP_STATUS.NOT_FOUND);
    }

  } catch (error) {
    console.error('Services operation error:', error);
    return createErrorResponse(
      API_MESSAGES.INTERNAL_ERROR,
      HTTP_STATUS.INTERNAL_SERVER_ERROR
    );
  }
});