import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.38.4'

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

interface PartnerSelectionCriteria {
  bookingId: string
  serviceId: string
  bookingLocation?: { lat: number; lng: number }
  preferredPartnerId?: string
}

interface SelectedPartner {
  partnerId: string
  fullName: string
  rating: number
}

/**
 * Selects the best available partner for a booking
 * Selection criteria:
 * 1. Preferred partner if specified and available
 * 2. Verified partners who offer the service
 * 3. Currently available (isAvailable flag)
 * 4. Highest rated
 */
async function selectPartner(
  supabase: any,
  criteria: PartnerSelectionCriteria
): Promise<SelectedPartner | null> {
  const { serviceId, preferredPartnerId } = criteria

  // Get service category
  const { data: service } = await supabase
    .from('services')
    .select('category')
    .eq('id', serviceId)
    .single()

  if (!service) {
    console.error('Service not found:', serviceId)
    return null
  }

  // If preferred partner is specified, check if they're available
  if (preferredPartnerId) {
    const { data: preferredPartner } = await supabase
      .from('partner_profiles')
      .select(`
        user_id,
        services,
        verification_status,
        rating,
        availability,
        users!inner(full_name)
      `)
      .eq('user_id', preferredPartnerId)
      .eq('verification_status', 'verified')
      .contains('services', [service.category])
      .single()

    if (preferredPartner) {
      const availability = preferredPartner.availability || {}
      if (availability.isAvailable === true) {
        return {
          partnerId: preferredPartner.user_id,
          fullName: preferredPartner.users.full_name,
          rating: preferredPartner.rating || 0,
        }
      }
    }
  }

  // Find available partners - TESTING MODE: Just get first partner
  const { data: partners, error } = await supabase
    .from('partner_profiles')
    .select(`
      user_id,
      rating,
      availability,
      users!inner(full_name)
    `)
    // .eq('verification_status', 'verified')  // Commented for testing
    // .contains('services', [service.category])  // Commented for testing
    .limit(1)

  if (error || !partners || partners.length === 0) {
    console.error('No available partners found:', error)
    return null
  }

  // TESTING MODE: Skip availability check, just use first partner
  // Filter by availability
  // const availablePartners = partners.filter((p: any) => {
  //   const availability = p.availability || {}
  //   return availability.isAvailable === true
  // })

  // if (availablePartners.length === 0) {
  //   console.warn('No partners are currently available')
  //   return null
  // }

  // Select the highest-rated available partner
  // const selectedPartner = availablePartners.sort(
  //   (a: any, b: any) => (b.rating || 0) - (a.rating || 0)
  // )[0]

  const selectedPartner = partners[0]

  return {
    partnerId: selectedPartner.user_id,
    fullName: selectedPartner.users.full_name,
    rating: selectedPartner.rating || 0,
  }
}

/**
 * Creates a notification for the partner
 * Partner app will receive this via Supabase Realtime
 */
async function notifyPartner(
  supabase: any,
  partnerId: string,
  bookingData: any
): Promise<void> {
  console.log('📧 [notifyPartner] Creating notification for partner:', partnerId)
  console.log('   Booking ID:', bookingData.id)
  console.log('   Service:', bookingData.service?.name)

  const notificationPayload = {
    user_id: partnerId,
    type: 'new_job_offer',
    title: 'New Job Opportunity! 🔔',
    body: `${bookingData.service?.name || 'Service'} - $${bookingData.total_amount}`,
    data: {
      booking_id: bookingData.id,
      service_name: bookingData.service?.name,
      service_category: bookingData.service?.category,
      amount: bookingData.total_amount,
      address: bookingData.address?.formatted_address || bookingData.address?.line1,
      scheduled_date: bookingData.scheduled_date,
      customer_id: bookingData.customer_id,
      customer_name: bookingData.customer?.full_name,
      instructions: bookingData.special_instructions,
      action: 'SHOW_JOB_OFFER', // Trigger full-screen UI
    },
  }

  console.log('📧 [notifyPartner] Notification payload:', JSON.stringify(notificationPayload, null, 2))

  const { data, error } = await supabase.from('notifications').insert(notificationPayload).select()

  if (error) {
    console.error('❌ [notifyPartner] Failed to insert notification:', error)
    throw error
  }

  console.log('✅ [notifyPartner] Notification inserted successfully:', data)
}

/**
 * Main function - assigns booking to partner and creates notification
 * Partner receives notification via Supabase Realtime subscription
 */
Deno.serve(async (req) => {
  try {
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

    const { bookingId } = await req.json()

    if (!bookingId) {
      return new Response(
        JSON.stringify({ error: 'Booking ID is required' }),
        { status: 400, headers: { 'Content-Type': 'application/json' } }
      )
    }

    console.log('📋 Processing booking assignment:', bookingId)

    // Get booking details
    const { data: booking, error: bookingError } = await supabase
      .from('bookings')
      .select(`
        *,
        service:services(*),
        customer:users!customer_id(*)
      `)
      .eq('id', bookingId)
      .single()

    if (bookingError || !booking) {
      console.error('Booking not found:', bookingError)
      return new Response(
        JSON.stringify({ error: 'Booking not found' }),
        { status: 404, headers: { 'Content-Type': 'application/json' } }
      )
    }

    // Extract location from address if available
    let bookingLocation: { lat: number; lng: number } | undefined
    if (booking.address?.latitude && booking.address?.longitude) {
      bookingLocation = {
        lat: booking.address.latitude,
        lng: booking.address.longitude,
      }
    }

    // Select best partner
    const selectedPartner = await selectPartner(supabase, {
      bookingId: booking.id,
      serviceId: booking.service_id,
      preferredPartnerId: booking.preferred_partner_id,
      bookingLocation,
    })

    if (!selectedPartner) {
      console.warn('No available partner found for booking:', bookingId)

      // Notify customer that we're finding a provider
      await supabase.from('notifications').insert({
        user_id: booking.customer_id,
        type: 'booking_pending',
        title: 'Finding Service Provider',
        body: 'We are finding the best service provider for your booking. You will be notified soon.',
        data: { booking_id: bookingId },
      })

      return new Response(
        JSON.stringify({
          success: false,
          message: 'No available partners found',
        }),
        { status: 200, headers: { 'Content-Type': 'application/json' } }
      )
    }

    console.log('✅ Selected partner:', selectedPartner.partnerId, selectedPartner.fullName)

    // Send notification to partner (received via Realtime)
    await notifyPartner(supabase, selectedPartner.partnerId, booking)

    return new Response(
      JSON.stringify({
        success: true,
        partnerId: selectedPartner.partnerId,
        partnerName: selectedPartner.fullName,
        rating: selectedPartner.rating,
      }),
      { status: 200, headers: { 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('Error in assign-booking-to-partner:', error)
    return new Response(
      JSON.stringify({ error: 'Internal server error', details: error.message }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    )
  }
})
