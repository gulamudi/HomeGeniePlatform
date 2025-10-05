import { corsHeaders, handleCORS, createResponse, createErrorResponse, validateRequestBody, createSupabaseClient, getAuthUser } from '../_shared/utils.ts';
import { GetAvailableJobsRequestSchema, AcceptJobRequestSchema, RejectJobRequestSchema, UpdateJobStatusRequestSchema, GetAssignedJobsRequestSchema, UpdateJobPreferencesRequestSchema, HTTP_STATUS, API_MESSAGES } from '../_shared/types.ts';

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

    // Verify user is a partner
    const { data: userProfile } = await supabase
      .from('users')
      .select('user_type')
      .eq('id', user.id)
      .single();

    if (!userProfile || userProfile.user_type !== 'partner') {
      return createErrorResponse(
        'Access denied',
        HTTP_STATUS.FORBIDDEN
      );
    }

    const path = url.pathname;

    if (req.method === 'GET') {
      // Check if requesting a specific job by ID (e.g., /partner-jobs/123)
      const jobIdMatch = path.match(/\/partner-jobs\/([^\/]+)$/);
      if (jobIdMatch && jobIdMatch[1] && !path.includes('/available') && !path.includes('/assigned') && !path.includes('/preferences')) {
        const jobId = jobIdMatch[1];

        // Get specific job details
        const { data: job, error } = await supabase
          .from('bookings')
          .select(`
            *,
            service:services(*),
            customer:users!customer_id(full_name, phone, avatar_url),
            booking_timeline(*),
            ratings(*)
          `)
          .eq('id', jobId)
          .eq('partner_id', user.id)
          .single();

        if (error || !job) {
          return createErrorResponse(
            'Job not found or access denied',
            HTTP_STATUS.NOT_FOUND
          );
        }

        return createResponse(job, HTTP_STATUS.OK);
      } else if (path.includes('/available')) {
        // Get available jobs
        const radius = parseInt(url.searchParams.get('radius') || '10');
        const serviceCategory = url.searchParams.get('serviceCategory');
        const minAmount = parseFloat(url.searchParams.get('minAmount') || '0');
        const maxAmount = url.searchParams.get('maxAmount') ? parseFloat(url.searchParams.get('maxAmount')!) : null;
        const page = parseInt(url.searchParams.get('page') || '1');
        const limit = parseInt(url.searchParams.get('limit') || '20');

        // Get partner profile for preferences
        const { data: partnerProfile } = await supabase
          .from('partner_profiles')
          .select('services, job_preferences')
          .eq('user_id', user.id)
          .single();

        const partnerServices = partnerProfile?.services || [];
        const jobPreferences = partnerProfile?.job_preferences || {};

        let query = supabase
          .from('bookings')
          .select(`
            *,
            service:services(*),
            customer:users!customer_id(full_name, phone, avatar_url)
          `, { count: 'exact' })
          .eq('status', 'pending');

        // Filter by partner's services
        if (partnerServices.length > 0) {
          const { data: serviceIds } = await supabase
            .from('services')
            .select('id')
            .in('category', partnerServices);

          if (serviceIds && serviceIds.length > 0) {
            query = query.in('service_id', serviceIds.map(s => s.id));
          }
        }

        // Apply filters
        if (serviceCategory) {
          const { data: categoryServiceIds } = await supabase
            .from('services')
            .select('id')
            .eq('category', serviceCategory);

          if (categoryServiceIds && categoryServiceIds.length > 0) {
            query = query.in('service_id', categoryServiceIds.map(s => s.id));
          }
        }

        if (minAmount > 0) {
          query = query.gte('total_amount', minAmount);
        }

        if (maxAmount) {
          query = query.lte('total_amount', maxAmount);
        }

        // Apply minimum job value from preferences
        const minJobValue = jobPreferences.minJobValue || 0;
        if (minJobValue > 0) {
          query = query.gte('total_amount', minJobValue);
        }

        // Apply pagination and ordering
        const from = (page - 1) * limit;
        const to = from + limit - 1;
        query = query
          .order('created_at', { ascending: false })
          .range(from, to);

        const { data: jobs, error, count } = await query;

        if (error) {
          console.error('Error fetching available jobs:', error);
          return createErrorResponse(
            'Failed to fetch available jobs',
            HTTP_STATUS.INTERNAL_SERVER_ERROR
          );
        }

        const totalPages = count ? Math.ceil(count / limit) : 0;

        return createResponse(
          {
            jobs: jobs || [],
            pagination: {
              page,
              limit,
              total: count || 0,
              totalPages,
            },
          },
          HTTP_STATUS.OK
        );

      } else if (path.includes('/assigned')) {
        // Get assigned jobs
        const status = url.searchParams.get('status');
        const fromDate = url.searchParams.get('fromDate');
        const toDate = url.searchParams.get('toDate');
        const page = parseInt(url.searchParams.get('page') || '1');
        const limit = parseInt(url.searchParams.get('limit') || '20');

        let query = supabase
          .from('bookings')
          .select(`
            *,
            service:services(*),
            customer:users!customer_id(full_name, phone, avatar_url),
            booking_timeline(*),
            ratings(*)
          `, { count: 'exact' })
          .eq('partner_id', user.id);

        // Apply filters
        if (status) {
          // Handle multiple status values (comma-separated)
          const statusValues = status.split(',').map(s => s.trim());
          if (statusValues.length > 1) {
            query = query.in('status', statusValues);
          } else {
            query = query.eq('status', status);
          }
        }

        if (fromDate) {
          query = query.gte('scheduled_date', fromDate);
        }

        if (toDate) {
          query = query.lte('scheduled_date', toDate);
        }

        // Apply pagination and ordering
        const from = (page - 1) * limit;
        const to = from + limit - 1;
        query = query
          .order('scheduled_date', { ascending: true })
          .range(from, to);

        const { data: jobs, error, count } = await query;

        if (error) {
          console.error('Error fetching assigned jobs:', error);
          return createErrorResponse(
            'Failed to fetch assigned jobs',
            HTTP_STATUS.INTERNAL_SERVER_ERROR
          );
        }

        const totalPages = count ? Math.ceil(count / limit) : 0;

        return createResponse(
          {
            jobs: jobs || [],
            pagination: {
              page,
              limit,
              total: count || 0,
              totalPages,
            },
          },
          HTTP_STATUS.OK
        );

      } else if (path.includes('/preferences')) {
        // Get job preferences
        const { data: partnerProfile, error } = await supabase
          .from('partner_profiles')
          .select('job_preferences')
          .eq('user_id', user.id)
          .single();

        if (error) {
          console.error('Error fetching job preferences:', error);
          return createErrorResponse(
            'Failed to fetch job preferences',
            HTTP_STATUS.INTERNAL_SERVER_ERROR
          );
        }

        return createResponse(
          partnerProfile?.job_preferences || {},
          HTTP_STATUS.OK
        );
      }

    } else if (req.method === 'POST') {
      const jobId = path.split('/').slice(-2)[0]; // Get job ID before action

      if (path.includes('/accept')) {
        // Accept job
        const validation = await validateRequestBody(req, AcceptJobRequestSchema);
        if (!validation.success) {
          return createErrorResponse(validation.error, HTTP_STATUS.BAD_REQUEST);
        }

        const { estimatedArrival } = validation.data;

        // Verify job is available and can be accepted
        const { data: booking, error: bookingError } = await supabase
          .from('bookings')
          .select('*')
          .eq('id', jobId)
          .eq('status', 'pending')
          .is('partner_id', null)
          .single();

        if (bookingError || !booking) {
          return createErrorResponse(
            'Job not found or already assigned',
            HTTP_STATUS.NOT_FOUND
          );
        }

        // Accept the job
        const { data: updatedBooking, error: updateError } = await supabase
          .from('bookings')
          .update({
            partner_id: user.id,
            status: 'confirmed',
          })
          .eq('id', jobId)
          .select(`
            *,
            service:services(*),
            customer:users!customer_id(*)
          `)
          .single();

        if (updateError) {
          console.error('Error accepting job:', updateError);
          return createErrorResponse(
            'Failed to accept job',
            HTTP_STATUS.INTERNAL_SERVER_ERROR
          );
        }

        // Create timeline entry
        await supabase
          .from('booking_timeline')
          .insert({
            booking_id: jobId,
            status: 'confirmed',
            notes: estimatedArrival ? `Estimated arrival: ${estimatedArrival}` : 'Job accepted by partner',
            updated_by: user.id,
            updated_by_type: 'partner',
          });

        return createResponse(
          updatedBooking,
          HTTP_STATUS.OK,
          'Job accepted successfully'
        );

      } else if (path.includes('/reject')) {
        // Reject job
        const validation = await validateRequestBody(req, RejectJobRequestSchema);
        if (!validation.success) {
          return createErrorResponse(validation.error, HTTP_STATUS.BAD_REQUEST);
        }

        const { reason } = validation.data;

        // Verify job exists and is pending
        const { data: booking, error: bookingError } = await supabase
          .from('bookings')
          .select('*')
          .eq('id', jobId)
          .eq('status', 'pending')
          .single();

        if (bookingError || !booking) {
          return createErrorResponse(
            'Job not found',
            HTTP_STATUS.NOT_FOUND
          );
        }

        // Create timeline entry for rejection
        await supabase
          .from('booking_timeline')
          .insert({
            booking_id: jobId,
            status: 'pending',
            notes: `Rejected by partner: ${reason || 'No reason provided'}`,
            updated_by: user.id,
            updated_by_type: 'partner',
          });

        return createResponse(
          {},
          HTTP_STATUS.OK,
          'Job rejected successfully'
        );
      }

    } else if (req.method === 'PUT') {
      if (path.includes('/status')) {
        // Update job status
        const jobId = path.split('/').slice(-2)[0];

        const validation = await validateRequestBody(req, UpdateJobStatusRequestSchema);
        if (!validation.success) {
          return createErrorResponse(validation.error, HTTP_STATUS.BAD_REQUEST);
        }

        const { status, notes, location } = validation.data;

        // Verify job belongs to partner
        const { data: booking, error: bookingError } = await supabase
          .from('bookings')
          .select('*')
          .eq('id', jobId)
          .eq('partner_id', user.id)
          .single();

        if (bookingError || !booking) {
          return createErrorResponse(
            'Job not found or access denied',
            HTTP_STATUS.NOT_FOUND
          );
        }

        // Update booking status
        const { data: updatedBooking, error: updateError } = await supabase
          .from('bookings')
          .update({ status })
          .eq('id', jobId)
          .select(`
            *,
            service:services(*),
            customer:users!customer_id(*)
          `)
          .single();

        if (updateError) {
          console.error('Error updating job status:', updateError);
          return createErrorResponse(
            'Failed to update job status',
            HTTP_STATUS.INTERNAL_SERVER_ERROR
          );
        }

        // Create timeline entry
        await supabase
          .from('booking_timeline')
          .insert({
            booking_id: jobId,
            status,
            notes,
            updated_by: user.id,
            updated_by_type: 'partner',
            ...(location && { location: `POINT(${location.lng} ${location.lat})` }),
          });

        // If job is completed, update partner's total jobs and earnings
        if (status === 'completed') {
          const { data: partnerProfile } = await supabase
            .from('partner_profiles')
            .select('total_jobs, total_earnings')
            .eq('user_id', user.id)
            .single();

          if (partnerProfile) {
            await supabase
              .from('partner_profiles')
              .update({
                total_jobs: (partnerProfile.total_jobs || 0) + 1,
                total_earnings: (partnerProfile.total_earnings || 0) + booking.total_amount,
              })
              .eq('user_id', user.id);
          }
        }

        return createResponse(
          updatedBooking,
          HTTP_STATUS.OK,
          'Job status updated successfully'
        );

      } else if (path.includes('/preferences')) {
        // Update job preferences
        const validation = await validateRequestBody(req, UpdateJobPreferencesRequestSchema);
        if (!validation.success) {
          return createErrorResponse(validation.error, HTTP_STATUS.BAD_REQUEST);
        }

        const updateData = validation.data;

        // Get current preferences
        const { data: currentProfile } = await supabase
          .from('partner_profiles')
          .select('job_preferences')
          .eq('user_id', user.id)
          .single();

        const currentPreferences = currentProfile?.job_preferences || {};
        const updatedPreferences = { ...currentPreferences, ...updateData };

        // Update preferences
        const { error: updateError } = await supabase
          .from('partner_profiles')
          .update({ job_preferences: updatedPreferences })
          .eq('user_id', user.id);

        if (updateError) {
          console.error('Error updating job preferences:', updateError);
          return createErrorResponse(
            'Failed to update job preferences',
            HTTP_STATUS.INTERNAL_SERVER_ERROR
          );
        }

        return createResponse(
          updatedPreferences,
          HTTP_STATUS.OK,
          'Job preferences updated successfully'
        );
      }
    }

    return createErrorResponse('Invalid request', HTTP_STATUS.BAD_REQUEST);

  } catch (error) {
    console.error('Partner jobs operation error:', error);
    return createErrorResponse(
      API_MESSAGES.INTERNAL_ERROR,
      HTTP_STATUS.INTERNAL_SERVER_ERROR
    );
  }
});