import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.38.4'

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

interface RankedPartner {
  partner_id: string
  partner_name: string
  rank_score: number
}

/**
 * Cron function to check for expired job notifications
 * Sends next batch if current batch has expired
 * Runs every 5 minutes
 */
Deno.serve(async (req) => {
  try {
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

    console.log('🕐 [checkExpiry] Checking for expired job notifications...')

    // Mark all expired notifications
    const { data: expiredCount } = await supabase.rpc('mark_expired_notifications')
    console.log(`⏰ [checkExpiry] Marked ${expiredCount || 0} notifications as expired`)

    if (!expiredCount || expiredCount === 0) {
      return new Response(
        JSON.stringify({
          success: true,
          message: 'No expired notifications',
          expiredCount: 0,
        }),
        { status: 200, headers: { 'Content-Type': 'application/json' } }
      )
    }

    // Get bookings that need next batch
    const { data: expiredNotifications } = await supabase.rpc('get_expired_job_notifications')

    if (!expiredNotifications || expiredNotifications.length === 0) {
      console.log('✅ [checkExpiry] All expired notifications processed')
      return new Response(
        JSON.stringify({
          success: true,
          message: 'All expired notifications processed',
          expiredCount,
        }),
        { status: 200, headers: { 'Content-Type': 'application/json' } }
      )
    }

    console.log(`📋 [checkExpiry] Found ${expiredNotifications.length} bookings needing next batch`)

    // Get settings
    const { data: settingsBatchSize } = await supabase.rpc('get_setting', {
      p_key: 'notifications.batch_size',
      p_default: '5'
    })
    const { data: settingsExpiry } = await supabase.rpc('get_setting', {
      p_key: 'notifications.expiry_seconds',
      p_default: '30'
    })
    const { data: settingsMaxBatches } = await supabase.rpc('get_setting', {
      p_key: 'notifications.max_batches',
      p_default: '3'
    })

    const batchSize = parseInt(settingsBatchSize || '5')
    const expirySeconds = parseInt(settingsExpiry || '30')
    const maxBatches = parseInt(settingsMaxBatches || '3')

    console.log(`⚙️ [checkExpiry] Settings - Batch: ${batchSize}, Expiry: ${expirySeconds}s, Max batches: ${maxBatches}`)

    let processedBookings = 0
    let sentNotifications = 0

    // Process each booking
    for (const notification of expiredNotifications) {
      const bookingId = notification.booking_id
      const currentBatch = notification.current_batch
      const nextBatch = currentBatch + 1

      console.log(`📬 [checkExpiry] Processing booking ${bookingId} - moving from batch ${currentBatch} to ${nextBatch}`)

      // Check if we've reached max batches
      if (nextBatch > maxBatches) {
        console.warn(`⚠️ [checkExpiry] Booking ${bookingId} reached max batches (${maxBatches}). Notifying admin.`)

        // Get booking details
        const { data: booking } = await supabase
          .from('bookings')
          .select('customer_id, service_id')
          .eq('id', bookingId)
          .single()

        if (booking) {
          // Notify customer that we're still finding a provider
          await supabase.from('notifications').insert({
            user_id: booking.customer_id,
            type: 'booking_delayed',
            title: 'Finding Service Provider',
            body: 'We are still working on finding the best service provider for you. We will update you shortly.',
            data: { booking_id: bookingId },
          })
        }

        continue
      }

      // Get ranked partners for this booking
      const { data: rankedPartners, error: rankError } = await supabase
        .rpc('rank_partners_for_booking', { p_booking_id: bookingId })

      if (rankError || !rankedPartners || rankedPartners.length === 0) {
        console.error(`❌ [checkExpiry] No partners found for booking ${bookingId}`)
        continue
      }

      // Get booking details for notification
      const { data: booking } = await supabase
        .from('bookings')
        .select(`
          *,
          service:services(*),
          customer:users!customer_id(*)
        `)
        .eq('id', bookingId)
        .single()

      if (!booking) {
        console.error(`❌ [checkExpiry] Booking ${bookingId} not found`)
        continue
      }

      // Send next batch
      const startIndex = (nextBatch - 1) * batchSize
      const batchPartners = rankedPartners.slice(startIndex, startIndex + batchSize)

      if (batchPartners.length === 0) {
        console.warn(`⚠️ [checkExpiry] No more partners available for batch ${nextBatch} of booking ${bookingId}`)
        continue
      }

      const expiresAt = new Date(Date.now() + expirySeconds * 1000).toISOString()
      console.log(`⏰ [checkExpiry] Batch ${nextBatch} will expire at: ${expiresAt}`)

      // Send notifications to next batch
      for (const partner of batchPartners) {
        // Create notification
        const notificationPayload = {
          user_id: partner.partner_id,
          type: 'new_job_offer',
          title: 'New Job Opportunity! 🔔',
          body: `${booking.service?.name || 'Service'} - ₹${booking.total_amount}`,
          data: {
            booking_id: booking.id,
            service_name: booking.service?.name,
            service_category: booking.service?.category,
            amount: booking.total_amount,
            address: booking.address?.area || booking.address?.city,
            scheduled_date: booking.scheduled_date,
            customer_id: booking.customer_id,
            customer_name: booking.customer?.full_name,
            instructions: booking.special_instructions,
            action: 'SHOW_JOB_OFFER',
            batch_number: nextBatch,
          },
        }

        const { data: notification, error: notifError } = await supabase
          .from('notifications')
          .insert(notificationPayload)
          .select()
          .single()

        if (!notifError && notification) {
          // Record in job_notifications
          await supabase.from('job_notifications').insert({
            booking_id: bookingId,
            partner_id: partner.partner_id,
            notification_id: notification.id,
            batch_number: nextBatch,
            rank_score: partner.rank_score,
            expires_at: expiresAt,
            status: 'pending',
          })

          sentNotifications++
        }
      }

      processedBookings++
      console.log(`✅ [checkExpiry] Sent batch ${nextBatch} (${batchPartners.length} partners) for booking ${bookingId}`)
    }

    return new Response(
      JSON.stringify({
        success: true,
        expiredCount,
        processedBookings,
        sentNotifications,
        message: `Processed ${processedBookings} bookings, sent ${sentNotifications} notifications`,
      }),
      { status: 200, headers: { 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('❌ [checkExpiry] Error in check-notification-expiry:', error)
    return new Response(
      JSON.stringify({ error: 'Internal server error', details: error.message }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    )
  }
})
