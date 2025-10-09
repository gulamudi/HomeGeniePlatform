import { corsHeaders, handleCORS, createResponse, createErrorResponse, createSupabaseClient } from '../_shared/utils.ts';
import { HTTP_STATUS, API_MESSAGES } from '../_shared/types.ts';

/**
 * Service Areas API
 * GET: Retrieve all active service areas
 * Public endpoint - no authentication required for viewing
 */
Deno.serve(async (req) => {
  // Handle CORS
  const corsResponse = handleCORS(req);
  if (corsResponse) return corsResponse;

  try {
    const supabase = createSupabaseClient();

    if (req.method === 'GET') {
      console.log('🔍 [serviceAreas] Fetching active service areas');

      const url = new URL(req.url);
      const city = url.searchParams.get('city');

      let query = supabase
        .from('service_areas')
        .select('*')
        .eq('is_active', true)
        .order('display_order', { ascending: true })
        .order('name', { ascending: true });

      // Filter by city if provided
      if (city) {
        query = query.eq('city', city);
        console.log('   Filtering by city:', city);
      }

      const { data: serviceAreas, error } = await query;

      if (error) {
        console.error('❌ [serviceAreas] Error:', error);
        return createErrorResponse(
          'Failed to fetch service areas',
          HTTP_STATUS.INTERNAL_SERVER_ERROR
        );
      }

      console.log(`✅ [serviceAreas] Found ${serviceAreas?.length || 0} service areas`);

      // Transform the data for easier use in UI
      const transformedAreas = (serviceAreas || []).map((area: any) => ({
        id: area.id,
        name: area.name,
        city: area.city,
        state: area.state,
        radiusKm: area.radius_km,
        isActive: area.is_active,
        displayOrder: area.display_order
      }));

      // Group by city for easier selection
      const groupedByCity: Record<string, any[]> = {};
      transformedAreas.forEach((area: any) => {
        if (!groupedByCity[area.city]) {
          groupedByCity[area.city] = [];
        }
        groupedByCity[area.city].push(area);
      });

      return createResponse(
        {
          areas: transformedAreas,
          groupedByCity,
          count: transformedAreas.length
        },
        HTTP_STATUS.OK
      );

    } else {
      return createErrorResponse('Method not allowed', HTTP_STATUS.METHOD_NOT_ALLOWED);
    }

  } catch (error) {
    console.error('❌ [serviceAreas] Error:', error);
    return createErrorResponse(
      API_MESSAGES.INTERNAL_ERROR,
      HTTP_STATUS.INTERNAL_SERVER_ERROR
    );
  }
});
