import { corsHeaders, handleCORS, createResponse, createErrorResponse, validateRequestBody, createSupabaseClient, getAuthUser, transformAddressToDb, transformBookingFromDb } from '../_shared/utils.ts';
import { CreateBookingRequestSchema, GetBookingsRequestSchema, CancelBookingRequestSchema, RescheduleBookingRequestSchema, RateServiceRequestSchema, HTTP_STATUS, API_MESSAGES } from '../_shared/types.ts';

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

    if (req.method === 'POST') {
      const path = url.pathname;

      if (path.endsWith('/ratings')) {
        // Rate service
        const validation = await validateRequestBody(req, RateServiceRequestSchema);
        if (!validation.success) {
          return createErrorResponse(validation.error, HTTP_STATUS.BAD_REQUEST);
        }

        const { bookingId, rating, comment, ratingCategories } = validation.data;

        // Verify booking belongs to customer and is completed
        const { data: booking, error: bookingError } = await supabase
          .from('bookings')
          .select('*, partner_id')
          .eq('id', bookingId)
          .eq('customer_id', user.id)
          .eq('status', 'completed')
          .single();

        if (bookingError || !booking) {
          return createErrorResponse(
            'Booking not found or not eligible for rating',
            HTTP_STATUS.NOT_FOUND
          );
        }

        // Check if already rated
        const { data: existingRating } = await supabase
          .from('ratings')
          .select('id')
          .eq('booking_id', bookingId)
          .single();

        if (existingRating) {
          return createErrorResponse(
            'Booking already rated',
            HTTP_STATUS.CONFLICT
          );
        }

        // Insert rating
        const { error: ratingError } = await supabase
          .from('ratings')
          .insert({
            booking_id: bookingId,
            customer_id: user.id,
            partner_id: booking.partner_id,
            rating,
            comment,
            rating_categories: ratingCategories || {},
          });

        if (ratingError) {
          console.error('Error creating rating:', ratingError);
          return createErrorResponse(
            'Failed to submit rating',
            HTTP_STATUS.INTERNAL_SERVER_ERROR
          );
        }

        // Update partner's average rating
        const { data: partnerRatings } = await supabase
          .from('ratings')
          .select('rating')
          .eq('partner_id', booking.partner_id);

        if (partnerRatings && partnerRatings.length > 0) {
          const avgRating = partnerRatings.reduce((sum, r) => sum + r.rating, 0) / partnerRatings.length;

          await supabase
            .from('partner_profiles')
            .update({ rating: Math.round(avgRating * 100) / 100 })
            .eq('user_id', booking.partner_id);
        }

        return createResponse(
          {},
          HTTP_STATUS.OK,
          'Rating submitted successfully'
        );

      } else {
        // Create booking
        console.log('📥 Received POST request to create booking');

        // Log raw request details for debugging
        const contentType = req.headers.get('content-type');
        console.log('Content-Type:', contentType);

        let rawBody;
        try {
          rawBody = await req.text();
          console.log('Raw body:', rawBody);
          console.log('Raw body length:', rawBody.length);

          // Try to parse it manually
          const parsedBody = JSON.parse(rawBody);
          console.log('Parsed body:', JSON.stringify(parsedBody, null, 2));

          // Now validate with schema
          const result = CreateBookingRequestSchema.safeParse(parsedBody);
          if (!result.success) {
            console.error('Validation failed:', JSON.stringify(result.error, null, 2));
            const errorMessages = result.error.errors?.map((e: any) => `${e.path.join('.')}: ${e.message}`).join(', ') || 'Validation error';
            return createErrorResponse(
              `Validation failed: ${errorMessages}`,
              HTTP_STATUS.BAD_REQUEST
            );
          }

          const bookingData = result.data;
          console.log('Validated booking data:', bookingData);
        } catch (error) {
          console.error('❌ JSON parsing error:', error);
          console.error('Raw body that failed:', rawBody);
          return createErrorResponse(
            'Invalid JSON in request body',
            HTTP_STATUS.BAD_REQUEST
          );
        }

        const bookingData = CreateBookingRequestSchema.parse(JSON.parse(rawBody));

        // Verify service exists
        const { data: service, error: serviceError } = await supabase
          .from('services')
          .select('id, base_price')
          .eq('id', bookingData.serviceId)
          .eq('is_active', true)
          .single();

        if (serviceError || !service) {
          return createErrorResponse(
            'Service not found',
            HTTP_STATUS.NOT_FOUND
          );
        }

        // Calculate total amount (simplified - could include pricing tiers)
        const totalAmount = service.base_price * bookingData.durationHours;

        // Create booking
        const { data: booking, error: bookingError } = await supabase
          .from('bookings')
          .insert({
            customer_id: user.id,
            service_id: bookingData.serviceId,
            scheduled_date: bookingData.scheduledDate,
            duration_hours: bookingData.durationHours,
            address: transformAddressToDb(bookingData.address),
            total_amount: totalAmount,
            payment_method: bookingData.paymentMethod,
            special_instructions: bookingData.specialInstructions,
            preferred_partner_id: bookingData.preferredPartnerId,
          })
          .select(`
            *,
            service:services(*),
            customer:users!customer_id(*)
          `)
          .single();

        if (bookingError) {
          console.error('❌ Database insert failed: Unable to create booking');
          console.error(`  Error Code: ${bookingError.code || 'UNKNOWN'}`);
          console.error(`  Error Message: ${bookingError.message}`);
          console.error(`  Error Details: ${JSON.stringify(bookingError.details || {})}`);
          console.error('  Possible causes:');
          console.error('    1. Supabase is not running (run: supabase start)');
          console.error('    2. Table "bookings" does not exist or migration pending');
          console.error('    3. Foreign key constraint violation (invalid service_id)');
          console.error('    4. Required field missing in request');
          console.error('    5. Date validation failed (scheduled_date constraint)');
          return createErrorResponse(
            `Failed to create booking: ${bookingError.message}`,
            HTTP_STATUS.INTERNAL_SERVER_ERROR
          );
        }

        // Transform booking response from snake_case to camelCase
        const responseBooking = transformBookingFromDb(booking);

        // Create booking timeline entry
        await supabase
          .from('booking_timeline')
          .insert({
            booking_id: booking.id,
            status: 'pending',
            notes: 'Booking created',
            updated_by: user.id,
            updated_by_type: 'customer',
          });

        // Trigger partner assignment (async - don't wait)
        try {
          const assignUrl = `${Deno.env.get('SUPABASE_URL')}/functions/v1/assign-booking-to-partner`;
          fetch(assignUrl, {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              'Authorization': `Bearer ${Deno.env.get('SUPABASE_ANON_KEY')}`,
            },
            body: JSON.stringify({ bookingId: booking.id }),
          }).catch(err => console.error('Failed to trigger partner assignment:', err));
        } catch (err) {
          console.error('Error triggering partner assignment:', err);
        }

        return createResponse(
          responseBooking,
          HTTP_STATUS.CREATED,
          API_MESSAGES.BOOKING_CREATED
        );
      }

    } else if (req.method === 'GET') {
      const bookingId = url.pathname.split('/').pop();

      if (bookingId && bookingId !== 'customer-bookings') {
        // Get specific booking
        const { data: booking, error } = await supabase
          .from('bookings')
          .select(`
            *,
            service:services(*),
            partner:users!partner_id(*),
            booking_timeline(*),
            ratings(*)
          `)
          .eq('id', bookingId)
          .eq('customer_id', user.id)
          .single();

        if (error || !booking) {
          return createErrorResponse(
            'Booking not found',
            HTTP_STATUS.NOT_FOUND
          );
        }

        return createResponse(transformBookingFromDb(booking), HTTP_STATUS.OK);

      } else {
        // Get all bookings with filters
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
            partner:users!partner_id(*)
          `, { count: 'exact' })
          .eq('customer_id', user.id);

        // Apply filters
        if (status) {
          query = query.eq('status', status);
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
          .order('created_at', { ascending: false })
          .range(from, to);

        const { data: bookings, error, count } = await query;

        if (error) {
          console.error('❌ Database query failed: Unable to fetch bookings');
          console.error(`  Error Code: ${error.code || 'UNKNOWN'}`);
          console.error(`  Error Message: ${error.message}`);
          console.error(`  Error Details: ${JSON.stringify(error.details || {})}`);
          console.error('  Possible causes:');
          console.error('    1. Supabase is not running (run: supabase start)');
          console.error('    2. Database migration not applied');
          console.error('    3. Table "bookings" does not exist');
          console.error('    4. Invalid query parameters or filters');
          return createErrorResponse(
            'Failed to fetch bookings',
            HTTP_STATUS.INTERNAL_SERVER_ERROR
          );
        }

        const totalPages = count ? Math.ceil(count / limit) : 0;

        return createResponse(
          {
            bookings: (bookings || []).map(transformBookingFromDb),
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

    } else if (req.method === 'PUT') {
      const path = url.pathname;

      if (path.includes('/cancel')) {
        // Cancel booking
        const bookingId = path.split('/').slice(-2)[0]; // Get booking ID before '/cancel'

        const validation = await validateRequestBody(req, CancelBookingRequestSchema);
        if (!validation.success) {
          return createErrorResponse(validation.error, HTTP_STATUS.BAD_REQUEST);
        }

        const { reason } = validation.data;

        // Verify booking belongs to customer and can be cancelled
        const { data: booking, error: bookingError } = await supabase
          .from('bookings')
          .select('*')
          .eq('id', bookingId)
          .eq('customer_id', user.id)
          .in('status', ['pending', 'confirmed'])
          .single();

        if (bookingError || !booking) {
          return createErrorResponse(
            'Booking not found or cannot be cancelled',
            HTTP_STATUS.NOT_FOUND
          );
        }

        // Update booking status
        const { data: updatedBooking, error: updateError } = await supabase
          .from('bookings')
          .update({ status: 'cancelled' })
          .eq('id', bookingId)
          .select(`
            *,
            service:services(*),
            partner:users!partner_id(*)
          `)
          .single();

        if (updateError) {
          console.error('Error cancelling booking:', updateError);
          return createErrorResponse(
            'Failed to cancel booking',
            HTTP_STATUS.INTERNAL_SERVER_ERROR
          );
        }

        // Create timeline entry
        await supabase
          .from('booking_timeline')
          .insert({
            booking_id: bookingId,
            status: 'cancelled',
            notes: reason || 'Cancelled by customer',
            updated_by: user.id,
            updated_by_type: 'customer',
          });

        return createResponse(
          transformBookingFromDb(updatedBooking),
          HTTP_STATUS.OK,
          API_MESSAGES.BOOKING_CANCELLED
        );

      } else if (path.includes('/reschedule')) {
        // Reschedule booking
        const bookingId = path.split('/').slice(-2)[0]; // Get booking ID before '/reschedule'

        const validation = await validateRequestBody(req, RescheduleBookingRequestSchema);
        if (!validation.success) {
          return createErrorResponse(validation.error, HTTP_STATUS.BAD_REQUEST);
        }

        const { newScheduledDate } = validation.data;

        // Verify booking belongs to customer and can be rescheduled
        const { data: booking, error: bookingError } = await supabase
          .from('bookings')
          .select('*')
          .eq('id', bookingId)
          .eq('customer_id', user.id)
          .in('status', ['pending', 'confirmed'])
          .single();

        if (bookingError || !booking) {
          return createErrorResponse(
            'Booking not found or cannot be rescheduled',
            HTTP_STATUS.NOT_FOUND
          );
        }

        // Update booking date
        const { data: updatedBooking, error: updateError } = await supabase
          .from('bookings')
          .update({
            scheduled_date: newScheduledDate,
            status: 'pending' // Reset to pending for partner re-acceptance
          })
          .eq('id', bookingId)
          .select(`
            *,
            service:services(*),
            partner:users!partner_id(*)
          `)
          .single();

        if (updateError) {
          console.error('Error rescheduling booking:', updateError);
          return createErrorResponse(
            'Failed to reschedule booking',
            HTTP_STATUS.INTERNAL_SERVER_ERROR
          );
        }

        // Create timeline entry
        await supabase
          .from('booking_timeline')
          .insert({
            booking_id: bookingId,
            status: 'pending',
            notes: `Rescheduled from ${booking.scheduled_date} to ${newScheduledDate}`,
            updated_by: user.id,
            updated_by_type: 'customer',
          });

        return createResponse(
          transformBookingFromDb(updatedBooking),
          HTTP_STATUS.OK,
          'Booking rescheduled successfully'
        );
      }

    } else {
      return createErrorResponse('Method not allowed', HTTP_STATUS.NOT_FOUND);
    }

    return createErrorResponse('Invalid request', HTTP_STATUS.BAD_REQUEST);

  } catch (error) {
    console.error('Bookings operation error:', error);
    return createErrorResponse(
      API_MESSAGES.INTERNAL_ERROR,
      HTTP_STATUS.INTERNAL_SERVER_ERROR
    );
  }
});