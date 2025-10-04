import { corsHeaders, handleCORS, createResponse, createErrorResponse, validateRequestBody, createSupabaseClient, getAuthUser } from '../_shared/utils.ts';
import { GetEarningsRequestSchema, RequestPayoutRequestSchema, HTTP_STATUS, API_MESSAGES } from '../_shared/types.ts';

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

    if (req.method === 'GET') {
      // Get earnings
      const fromDate = url.searchParams.get('fromDate');
      const toDate = url.searchParams.get('toDate');
      const groupBy = url.searchParams.get('groupBy') || 'day';
      const page = parseInt(url.searchParams.get('page') || '1');
      const limit = parseInt(url.searchParams.get('limit') || '20');

      // Get completed bookings for earnings calculation
      let bookingsQuery = supabase
        .from('bookings')
        .select('total_amount, scheduled_date, created_at')
        .eq('partner_id', user.id)
        .eq('status', 'completed');

      if (fromDate) {
        bookingsQuery = bookingsQuery.gte('scheduled_date', fromDate);
      }

      if (toDate) {
        bookingsQuery = bookingsQuery.lte('scheduled_date', toDate);
      }

      const { data: completedBookings, error: bookingsError } = await bookingsQuery;

      if (bookingsError) {
        console.error('Error fetching earnings data:', bookingsError);
        return createErrorResponse(
          'Failed to fetch earnings data',
          HTTP_STATUS.INTERNAL_SERVER_ERROR
        );
      }

      // Calculate total earnings and jobs
      const totalEarnings = completedBookings?.reduce((sum, booking) => sum + booking.total_amount, 0) || 0;
      const totalJobs = completedBookings?.length || 0;

      // Get partner's average rating
      const { data: ratings } = await supabase
        .from('ratings')
        .select('rating')
        .eq('partner_id', user.id);

      const averageRating = ratings && ratings.length > 0
        ? ratings.reduce((sum, r) => sum + r.rating, 0) / ratings.length
        : 0;

      // Group earnings by date
      const earningsMap = new Map<string, { amount: number; jobsCompleted: number }>();

      completedBookings?.forEach(booking => {
        let dateKey: string;
        const bookingDate = new Date(booking.scheduled_date);

        switch (groupBy) {
          case 'week':
            // Get start of week (Monday)
            const startOfWeek = new Date(bookingDate);
            startOfWeek.setDate(bookingDate.getDate() - bookingDate.getDay() + 1);
            dateKey = startOfWeek.toISOString().split('T')[0];
            break;
          case 'month':
            dateKey = `${bookingDate.getFullYear()}-${String(bookingDate.getMonth() + 1).padStart(2, '0')}-01`;
            break;
          default: // day
            dateKey = bookingDate.toISOString().split('T')[0];
        }

        const existing = earningsMap.get(dateKey) || { amount: 0, jobsCompleted: 0 };
        earningsMap.set(dateKey, {
          amount: existing.amount + booking.total_amount,
          jobsCompleted: existing.jobsCompleted + 1,
        });
      });

      // Convert to array and sort
      const earnings = Array.from(earningsMap.entries())
        .map(([date, data]) => ({
          date: new Date(date).toISOString(),
          amount: data.amount,
          jobsCompleted: data.jobsCompleted,
        }))
        .sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime());

      // Apply pagination to earnings
      const from = (page - 1) * limit;
      const to = from + limit - 1;
      const paginatedEarnings = earnings.slice(from, to + 1);
      const totalPages = Math.ceil(earnings.length / limit);

      return createResponse(
        {
          totalEarnings,
          totalJobs,
          averageRating: Math.round(averageRating * 100) / 100,
          earnings: paginatedEarnings,
          pagination: {
            page,
            limit,
            total: earnings.length,
            totalPages,
          },
        },
        HTTP_STATUS.OK
      );

    } else if (req.method === 'POST') {
      // Request payout
      const validation = await validateRequestBody(req, RequestPayoutRequestSchema);
      if (!validation.success) {
        return createErrorResponse(validation.error, HTTP_STATUS.BAD_REQUEST);
      }

      const { amount, bankAccountId } = validation.data;

      // Get partner's total available earnings
      const { data: partnerProfile } = await supabase
        .from('partner_profiles')
        .select('total_earnings')
        .eq('user_id', user.id)
        .single();

      const availableEarnings = partnerProfile?.total_earnings || 0;

      if (amount > availableEarnings) {
        return createErrorResponse(
          'Insufficient balance',
          HTTP_STATUS.BAD_REQUEST
        );
      }

      // Create payout request (this would integrate with payment processor)
      const payoutId = crypto.randomUUID();
      const estimatedDate = new Date();
      estimatedDate.setDate(estimatedDate.getDate() + 3); // 3 days processing time

      // In a real implementation, you would:
      // 1. Integrate with payment processor (Razorpay, Stripe, etc.)
      // 2. Store payout request in database
      // 3. Handle payout status updates

      // For now, we'll just return a mock response
      return createResponse(
        {
          payoutId,
          status: 'pending',
          estimatedDate: estimatedDate.toISOString(),
        },
        HTTP_STATUS.OK,
        'Payout request submitted successfully'
      );

    } else {
      return createErrorResponse('Method not allowed', HTTP_STATUS.NOT_FOUND);
    }

  } catch (error) {
    console.error('Earnings operation error:', error);
    return createErrorResponse(
      API_MESSAGES.INTERNAL_ERROR,
      HTTP_STATUS.INTERNAL_SERVER_ERROR
    );
  }
});