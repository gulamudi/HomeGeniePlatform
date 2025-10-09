# 🧪 Complete Testing Guide

## How to Test the Ranking & Notification System

---

## 1. Deploy All Changes

```bash
cd /Users/muditgulati/devel/HomeGenieApps

# Reset database with all migrations
supabase db reset

# Deploy updated functions
supabase functions deploy assign-booking-to-partner
supabase functions deploy check-notification-expiry
supabase functions deploy customer-bookings
```

---

## 2. Check Database Entries

### 2.1 Verify Service Areas Loaded
```sql
SELECT name, city, radius_km, is_active
FROM service_areas
ORDER BY display_order;
```
**Expected**: 10 Pune areas (Amanora, Magarpatta, etc.)

### 2.2 Verify Services Loaded
```sql
SELECT id, name, category, base_price, duration_hours
FROM services
WHERE is_active = true
ORDER BY category, base_price;
```
**Expected**: 14 services (4 cleaning, 2 plumbing, 2 electrical, 2 AC, 2 painting, 2 pest control)

### 2.3 Check App Settings
```sql
SELECT key, value, description
FROM app_settings
WHERE category = 'notifications'
ORDER BY key;
```
**Expected**:
- `notifications.batch_size` = "5"
- `notifications.expiry_seconds` = "30" ⏱️ (30 seconds for testing!)
- `notifications.max_batches` = "3"

---

## 3. Test Partner Ranking (Manual)

### 3.1 Create Test Users

**Create a customer:**
```sql
-- Use Supabase Auth UI or your app to create a customer account
-- Then verify:
SELECT id, email, phone, full_name, user_type
FROM users
WHERE user_type = 'customer';
```

**Create 2-3 partner accounts:**
```sql
-- Use partner app to create accounts, then set them as verified:
UPDATE partner_profiles
SET verification_status = 'verified',
    services = ARRAY['cleaning'],
    availability = jsonb_build_object(
      'isAvailable', true,
      'weekdays', ARRAY[1,2,3,4,5,6],
      'workingHours', jsonb_build_object('start', '08:00', 'end', '20:00')
    )
WHERE user_id IN (
  SELECT id FROM users WHERE user_type = 'partner'
);
```

### 3.2 Create a Test Booking

Use the customer app or insert directly:
```sql
INSERT INTO bookings (
  id,
  customer_id,
  service_id,
  scheduled_date,
  duration_hours,
  address,
  location,
  total_amount,
  payment_method,
  status
) VALUES (
  gen_random_uuid(),
  'YOUR_CUSTOMER_UUID',
  (SELECT id FROM services WHERE name = 'Basic House Cleaning'),
  NOW() + INTERVAL '1 day',
  2.0,
  jsonb_build_object(
    'flatHouseNo', '123',
    'area', 'Amanora',
    'city', 'Pune',
    'pinCode', '411028',
    'latitude', 18.5566,
    'longitude', 73.9393
  ),
  ST_MakePoint(73.9393, 18.5566)::geography,
  399.00,
  'cash',
  'pending'
) RETURNING id;
```

### 3.3 Test Ranking Function

```sql
-- Test the ranking (use booking ID from above)
SELECT
  partner_name,
  partner_rating,
  distance_km,
  rank_score,
  worked_with_customer,
  is_online,
  score_breakdown
FROM rank_partners_for_booking('YOUR_BOOKING_ID')
ORDER BY rank_score DESC;
```

**Expected Output**:
```
 partner_name | partner_rating | distance_km | rank_score | worked_with_customer | is_online | score_breakdown
--------------+----------------+-------------+------------+----------------------+-----------+-----------------
 Partner 1    |           4.80 |        2.50 |      65.00 | false                | false     | {"rating": 20, ...}
 Partner 2    |           4.50 |        5.00 |      60.00 | false                | false     | {"rating": 25, ...}
```

**Check Logs in Supabase Dashboard:**
- Go to Database → Logs
- Filter by "rank_partners"
- You should see:
  ```
  🔍 [rank_partners] Booking ID: xxx
     Service category: cleaning
     Customer ID: xxx
  ⚙️ [rank_partners] Ranking weights:
     Previous customer: 30 pts
     Distance: 25 pts
     Rating: 25 pts
     Availability: 20 pts
  ```

---

## 4. Test Notification System

### 4.1 Trigger Partner Assignment

After creating a booking, the `assign-booking-to-partner` function should be called automatically. You can also trigger manually:

```bash
curl -X POST https://YOUR_PROJECT.supabase.co/functions/v1/assign-booking-to-partner \
  -H "Authorization: Bearer YOUR_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{"bookingId": "YOUR_BOOKING_ID"}'
```

### 4.2 Check Logs (Real-time)

**In Supabase Dashboard → Functions → assign-booking-to-partner → Logs:**

Expected logs:
```
📋 [assignBooking] Processing booking assignment: xxx
⚙️ [assignBooking] Settings - Batch size: 5, Expiry: 30 seconds
✅ [assignBooking] Found 3 ranked partners
🏆 [assignBooking] Top 3 partners:
   1. Partner A (Score: 65.00, Rating: 4.8, Distance: 2.5 km)
   2. Partner B (Score: 60.00, Rating: 4.5, Distance: 5.0 km)
   3. Partner C (Score: 55.00, Rating: 4.0, Distance: 8.0 km)
📤 [sendBatch] Sending batch 1 (5 partners)
⏰ [sendBatch] Expiry: 30 seconds
⏰ [sendBatch] Will expire at: 2024-10-09T...
📧 [notifyPartner] Creating notification for partner: xxx
✅ [sendBatch] Sent 3 notifications for batch 1
```

### 4.3 Check Database Entries

**Check notifications table:**
```sql
SELECT
  n.id,
  n.user_id,
  n.type,
  n.title,
  n.body,
  n.data->>'booking_id' as booking_id,
  n.created_at
FROM notifications n
WHERE n.type = 'new_job_offer'
ORDER BY n.created_at DESC
LIMIT 5;
```

**Check job_notifications table:**
```sql
SELECT
  jn.booking_id,
  u.full_name as partner_name,
  jn.batch_number,
  jn.rank_score,
  jn.status,
  jn.sent_at,
  jn.expires_at,
  EXTRACT(EPOCH FROM (jn.expires_at - NOW())) as seconds_remaining
FROM job_notifications jn
JOIN users u ON u.id = jn.partner_id
ORDER BY jn.booking_id, jn.batch_number, jn.rank_score DESC;
```

**Expected Output**:
```
 booking_id | partner_name | batch_number | rank_score | status  | sent_at             | expires_at          | seconds_remaining
------------+--------------+--------------+------------+---------+---------------------+---------------------+-------------------
 xxx        | Partner A    |            1 |      65.00 | pending | 2024-10-09 10:00:00 | 2024-10-09 10:00:30 | 25
 xxx        | Partner B    |            1 |      60.00 | pending | 2024-10-09 10:00:00 | 2024-10-09 10:00:30 | 25
```

---

## 5. Test Partner App Reception

### 5.1 Partner Sees Notification

In the partner Flutter app, the partner should see:
- Full-screen job offer card
- Service name and amount
- Customer area (not full address)
- 30-second countdown timer
- Accept / Decline buttons

### 5.2 Test Accept Flow

When partner clicks "Accept":

**Check logs:**
```
🔵 [SupabaseService] Accepting job...
🔵 [SupabaseService] Calling accept_job function...
✅ [SupabaseService] Job accepted successfully!
```

**Check database - Booking updated:**
```sql
SELECT id, status, partner_id, updated_at
FROM bookings
WHERE id = 'YOUR_BOOKING_ID';
```
**Expected**: `status = 'confirmed'`, `partner_id = ACCEPTING_PARTNER_UUID`

**Check database - Other notifications cancelled:**
```sql
SELECT partner_id, status, updated_at
FROM job_notifications
WHERE booking_id = 'YOUR_BOOKING_ID';
```
**Expected**:
```
 partner_id  | status    | updated_at
-------------+-----------+-------------------
 PARTNER_A   | accepted  | 2024-10-09 10:00:15
 PARTNER_B   | cancelled | 2024-10-09 10:00:15
 PARTNER_C   | cancelled | 2024-10-09 10:00:15
```

**Check notifications table - deleted:**
```sql
SELECT COUNT(*)
FROM notifications
WHERE data->>'booking_id' = 'YOUR_BOOKING_ID'
AND type = 'new_job_offer';
```
**Expected**: `0` (all deleted)

---

## 6. Test Expiry & Next Batch

### 6.1 Wait 30 Seconds (Without Accepting)

Don't accept any notification, just wait 30+ seconds.

### 6.2 Manually Trigger Expiry Check

```bash
curl -X POST https://YOUR_PROJECT.supabase.co/functions/v1/check-notification-expiry \
  -H "Authorization: Bearer YOUR_ANON_KEY"
```

### 6.3 Check Logs

**In Functions → check-notification-expiry → Logs:**

```
🕐 [checkExpiry] Checking for expired job notifications...
⏰ [checkExpiry] Marked 3 notifications as expired
📋 [checkExpiry] Found 1 bookings needing next batch
⚙️ [checkExpiry] Settings - Batch: 5, Expiry: 30s, Max batches: 3
📬 [checkExpiry] Processing booking xxx - moving from batch 1 to 2
⏰ [checkExpiry] Batch 2 will expire at: 2024-10-09 10:01:30
✅ [checkExpiry] Sent batch 2 (2 partners) for booking xxx
```

### 6.4 Check Database

```sql
-- Batch 1 should be expired
SELECT batch_number, status, COUNT(*)
FROM job_notifications
WHERE booking_id = 'YOUR_BOOKING_ID'
GROUP BY batch_number, status
ORDER BY batch_number;
```

**Expected**:
```
 batch_number | status  | count
--------------+---------+-------
            1 | expired |     3
            2 | pending |     2
```

---

## 7. Setup Cron Job

### 7.1 In Supabase Dashboard

1. Go to **Edge Functions**
2. Click **Cron Jobs** tab
3. Click **Add Cron Job**
4. Fill in:
   - **Name**: Check Notification Expiry
   - **Function**: check-notification-expiry
   - **Schedule**: `*/1 * * * *` (every 1 minute for testing)
   - **Timezone**: Asia/Kolkata
5. Click **Save**

### 7.2 Verify Cron is Running

Wait 1 minute, then check logs:
```sql
SELECT * FROM cron.job_run_details
WHERE jobname = 'check-notification-expiry'
ORDER BY runid DESC
LIMIT 5;
```

Or check in Dashboard → Edge Functions → check-notification-expiry → Logs

---

## 8. Test Preferred Partners

### 8.1 Create Booking History

Create a completed booking between customer and partner:
```sql
-- First booking (completed)
INSERT INTO bookings (
  customer_id,
  partner_id,
  service_id,
  scheduled_date,
  duration_hours,
  address,
  total_amount,
  payment_method,
  status
) VALUES (
  'CUSTOMER_UUID',
  'PARTNER_A_UUID',
  (SELECT id FROM services WHERE name = 'Basic House Cleaning'),
  NOW() - INTERVAL '7 days',
  2.0,
  '{}',
  399.00,
  'cash',
  'completed'
);
```

### 8.2 Test Preferred Partners Function

```sql
SELECT
  partner_name,
  rating,
  total_jobs,
  last_service_date,
  services_count,
  last_service_name
FROM get_preferred_partners(
  'CUSTOMER_UUID',
  (SELECT id FROM services WHERE name = 'Basic House Cleaning'),
  NOW() + INTERVAL '1 day',
  2.0,
  3
);
```

**Expected**: Partner A should appear (worked with this customer before)

---

## 9. Common Issues & Fixes

### Issue: "operator does not exist: service_category = text"
**Fix**: Run migration `20241009000009_fix_ranking_type_error.sql`

### Issue: Notifications not expiring
**Check**:
1. Expiry time in app_settings
2. Cron job is running
3. Function logs for errors

### Issue: No partners ranked
**Check**:
1. Partners are verified: `UPDATE partner_profiles SET verification_status = 'verified'`
2. Partners have matching service: `services = ARRAY['cleaning']`
3. Partners are available: `availability->>'isAvailable' = true`

### Issue: Distance is NULL
**Check**:
1. Booking has location: `SELECT location FROM bookings WHERE id = '...'`
2. Partner has location: `SELECT current_location FROM partner_availability WHERE partner_id = '...'`
3. Insert partner location:
   ```sql
   INSERT INTO partner_availability (partner_id, current_location, is_online, is_accepting_jobs)
   VALUES ('PARTNER_UUID', ST_MakePoint(73.9393, 18.5566)::geography, true, true)
   ON CONFLICT (partner_id) DO UPDATE
   SET current_location = EXCLUDED.current_location;
   ```

---

## 10. Quick Test Checklist

- [ ] Database reset successful (10 areas, 14 services)
- [ ] Test partners created and verified
- [ ] Test booking created with location
- [ ] Ranking function returns partners sorted by score
- [ ] Logs show ranking details (scores, breakdown)
- [ ] Notifications sent to top 5 partners
- [ ] job_notifications table has entries with 30s expiry
- [ ] Partner app receives notification
- [ ] Accept cancels all other notifications
- [ ] Expiry check marks old notifications as expired
- [ ] Next batch sent after 30 seconds
- [ ] Cron job runs every minute
- [ ] Preferred partners shows previous partners
- [ ] All database queries return expected data

---

## 11. Performance Monitoring

### Monitor Function Execution Time
```sql
SELECT
  function_name,
  AVG(execution_time_ms) as avg_time,
  MAX(execution_time_ms) as max_time,
  COUNT(*) as calls
FROM function_logs
WHERE created_at > NOW() - INTERVAL '1 hour'
GROUP BY function_name;
```

### Monitor Notification Success Rate
```sql
SELECT
  status,
  COUNT(*) as count,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as percentage
FROM job_notifications
GROUP BY status;
```

---

Generated: October 9, 2024
Test Environment: Pune (30s expiry for testing)
