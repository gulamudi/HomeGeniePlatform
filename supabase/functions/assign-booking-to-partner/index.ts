import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.38.4'

// TEST MODE: When true, sends notifications to ALL partners instead of using ranking logic
const TEST_MODE = true // Set to false for production

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

interface RankedPartner {
  partner_id: string
  partner_name: string
  partner_phone: string
  partner_rating: number
  total_jobs: number
  distance_km: number | null
  rank_score: number
  worked_with_customer: boolean
  is_online: boolean
}

/**
 * Creates a notification for the partner
 * Partner app will receive this via Supabase Realtime
 */
async function notifyPartner(
  supabase: any,
  partnerId: string,
  bookingData: any,
  batchNumber: number,
  rankScore: number
): Promise<string | null> {
  console.log('📧 [notifyPartner] Creating notification for partner:', partnerId)
  console.log('   Booking ID:', bookingData.id)
  console.log('   Service:', bookingData.service?.name)
  console.log('   Batch:', batchNumber)
  console.log('   Rank Score:', rankScore)

  const notificationPayload = {
    user_id: partnerId,
    type: 'new_job_offer',
    title: 'New Job Opportunity! 🔔',
    body: `${bookingData.service?.name || 'Service'} - ₹${bookingData.total_amount}`,
    data: {
      booking_id: bookingData.id,
      service_name: bookingData.service?.name,
      service_category: bookingData.service?.category,
      amount: bookingData.total_amount,
      address: bookingData.address?.area || bookingData.address?.city,
      scheduled_date: bookingData.scheduled_date,
      customer_id: bookingData.customer_id,
      customer_name: bookingData.customer?.full_name,
      instructions: bookingData.special_instructions,
      action: 'SHOW_JOB_OFFER', // Trigger full-screen UI
      batch_number: batchNumber,
    },
  }

  const { data, error } = await supabase
    .from('notifications')
    .insert(notificationPayload)
    .select()
    .single()

  if (error) {
    console.error('❌ [notifyPartner] Failed to insert notification:', error)
    return null
  }

  console.log('✅ [notifyPartner] Notification inserted successfully')
  return data.id
}

/**
 * Send notifications to a batch of ranked partners
 */
async function sendBatchNotifications(
  supabase: any,
  bookingId: string,
  bookingData: any,
  rankedPartners: RankedPartner[],
  batchNumber: number,
  batchSize: number,
  expirySeconds: number
): Promise<number> {
  console.log(`📤 [sendBatch] Sending batch ${batchNumber} (${batchSize} partners)`)
  console.log(`⏰ [sendBatch] Expiry: ${expirySeconds} seconds`)

  const startIndex = (batchNumber - 1) * batchSize
  const batchPartners = rankedPartners.slice(startIndex, startIndex + batchSize)

  if (batchPartners.length === 0) {
    console.log('⚠️ [sendBatch] No more partners available for batch', batchNumber)
    return 0
  }

  const expiresAt = new Date(Date.now() + expirySeconds * 1000).toISOString()
  console.log(`⏰ [sendBatch] Will expire at: ${expiresAt}`)
  let sentCount = 0

  for (const partner of batchPartners) {
    // Create notification
    const notificationId = await notifyPartner(
      supabase,
      partner.partner_id,
      bookingData,
      batchNumber,
      partner.rank_score
    )

    if (notificationId) {
      // Record in job_notifications table
      const { error } = await supabase.from('job_notifications').insert({
        booking_id: bookingId,
        partner_id: partner.partner_id,
        notification_id: notificationId,
        batch_number: batchNumber,
        rank_score: partner.rank_score,
        expires_at: expiresAt,
        status: 'pending',
      })

      if (error) {
        console.error('❌ [sendBatch] Failed to record job notification:', error)
      } else {
        sentCount++
      }
    }
  }

  console.log(`✅ [sendBatch] Sent ${sentCount} notifications for batch ${batchNumber}`)
  return sentCount
}

/**
 * Main function - assigns booking to partner using smart ranking
 * Sends notifications in batches with expiry
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

    console.log('📋 [assignBooking] Processing booking assignment:', bookingId)

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
      console.error('❌ [assignBooking] Booking not found:', bookingError)
      return new Response(
        JSON.stringify({ error: 'Booking not found' }),
        { status: 404, headers: { 'Content-Type': 'application/json' } }
      )
    }

    // Get settings
    const { data: settingsBatchSize } = await supabase.rpc('get_setting', {
      p_key: 'notifications.batch_size',
      p_default: '5'
    })
    const { data: settingsExpiry } = await supabase.rpc('get_setting', {
      p_key: 'notifications.expiry_seconds',
      p_default: '30'
    })

    const batchSize = parseInt(settingsBatchSize || '5')
    const expirySeconds = parseInt(settingsExpiry || '30')

    console.log(`⚙️ [assignBooking] Settings - Batch size: ${batchSize}, Expiry: ${expirySeconds} seconds`)
    console.log(`🧪 [assignBooking] TEST_MODE: ${TEST_MODE}`)

    // Rank partners for this booking (or get all partners in test mode)
    let rankedPartners: RankedPartner[]
    let rankError: any = null

    if (TEST_MODE) {
      // TEST MODE: Get ALL partners who can provide this service category
      console.log('🧪 [TEST_MODE] Fetching ALL partners for testing...')
      console.log('🧪 [TEST_MODE] Service category:', booking.service?.category)

      const { data: allPartners, error } = await supabase
        .from('partner_profiles')
        .select(`
          user_id,
          rating,
          total_jobs,
          verification_status,
          services,
          partner:users!user_id(
            id,
            full_name,
            phone
          )
        `)
        // .eq('verification_status', 'verified')
        // .contains('services', [booking.service?.category])

      rankError = error

      console.log('🧪 [TEST_MODE] Found partners:', allPartners?.length || 0)

      if (allPartners && allPartners.length > 0) {
        rankedPartners = allPartners.map((ps: any, index: number) => ({
          partner_id: ps.partner.id,
          partner_name: ps.partner.full_name,
          partner_phone: ps.partner.phone,
          partner_rating: ps.rating || 5.0,
          total_jobs: ps.total_jobs || 0,
          distance_km: null,
          rank_score: 100 - index, // Simple descending score
          worked_with_customer: false,
          is_online: false, // We could join partner_availability if needed
        }))
      } else {
        rankedPartners = []
      }
    } else {
      // PRODUCTION MODE: Use smart ranking logic
      const { data, error } = await supabase
        .rpc('rank_partners_for_booking', { p_booking_id: bookingId })
      rankedPartners = data || []
      rankError = error
    }

    if (rankError) {
      console.error('❌ [assignBooking] Failed to rank partners:', rankError)
      return new Response(
        JSON.stringify({ error: 'Failed to rank partners', details: rankError.message }),
        { status: 500, headers: { 'Content-Type': 'application/json' } }
      )
    }

    if (!rankedPartners || rankedPartners.length === 0) {
      console.warn('⚠️ [assignBooking] No available partners found for booking:', bookingId)

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

    console.log(`✅ [assignBooking] Found ${rankedPartners.length} ranked partners`)
    console.log('🏆 [assignBooking] Top 3 partners:')
    rankedPartners.slice(0, 3).forEach((p: RankedPartner, i: number) => {
      console.log(`   ${i + 1}. ${p.partner_name} (Score: ${p.rank_score}, Rating: ${p.partner_rating}, Distance: ${p.distance_km || 'N/A'} km)`)
    })

    // Send first batch of notifications
    const sentCount = await sendBatchNotifications(
      supabase,
      bookingId,
      booking,
      rankedPartners,
      1, // First batch
      batchSize,
      expirySeconds
    )

    if (sentCount === 0) {
      return new Response(
        JSON.stringify({
          success: false,
          message: 'Failed to send notifications',
        }),
        { status: 500, headers: { 'Content-Type': 'application/json' } }
      )
    }

    return new Response(
      JSON.stringify({
        success: true,
        notifiedPartners: sentCount,
        totalAvailablePartners: rankedPartners.length,
        batch: 1,
        expiresInSeconds: expirySeconds,
        topPartners: rankedPartners.slice(0, sentCount).map((p: RankedPartner) => ({
          partnerId: p.partner_id,
          partnerName: p.partner_name,
          rating: p.partner_rating,
          rankScore: p.rank_score,
          distanceKm: p.distance_km,
          workedBefore: p.worked_with_customer,
        })),
      }),
      { status: 200, headers: { 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('❌ [assignBooking] Error in assign-booking-to-partner:', error)
    return new Response(
      JSON.stringify({ error: 'Internal server error', details: error.message }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    )
  }
})
