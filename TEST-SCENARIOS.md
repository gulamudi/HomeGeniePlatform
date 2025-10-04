# HomeGenie Platform - Test Scenarios

## End-to-End Testing Guide

### Prerequisites
- ✅ Supabase local instance running
- ✅ Postman collection imported
- ✅ Flutter apps configured

## Test Scenario 1: Customer Journey

### Step 1: Customer Authentication
**Using Postman:**
1. **Request OTP**
   - POST `/auth-login`
   - Body: `{"phone": "+919876543210", "userType": "customer"}`
   - Expected: `success: true, sessionId: "uuid"`

2. **Verify OTP**
   - POST `/auth-verify-otp`
   - Body: `{"phone": "+919876543210", "otp": "123456", "sessionId": "{{sessionId}}"}`
   - Expected: `accessToken` and `refreshToken`

### Step 2: Profile Setup
1. **Get Profile**
   - GET `/auth-profile`
   - Expected: User profile with customer type

2. **Update Profile**
   - PUT `/auth-profile`
   - Body: `{"fullName": "John Doe", "email": "john@example.com"}`

3. **Add Address**
   - POST `/customer-addresses`
   - Body: Complete address object
   - Expected: Address saved successfully

### Step 3: Service Discovery
1. **Browse Services**
   - GET `/customer-services?page=1&limit=20`
   - Expected: List of available services with pagination

2. **Search Services**
   - GET `/customer-services?search=cleaning&category=cleaning`
   - Expected: Filtered results

3. **Get Service Details**
   - GET `/customer-services/{serviceId}`
   - Expected: Complete service info with pricing tiers

### Step 4: Booking Flow
1. **Create Booking**
   - POST `/customer-bookings`
   - Body: Service ID, date, address, payment method
   - Expected: Booking created with pending status

2. **View Bookings**
   - GET `/customer-bookings`
   - Expected: List of customer's bookings

3. **Get Booking Details**
   - GET `/customer-bookings/{bookingId}`
   - Expected: Complete booking information

### Step 5: Booking Management
1. **Cancel Booking**
   - PUT `/customer-bookings/{bookingId}/cancel`
   - Body: `{"reason": "Change of plans"}`
   - Expected: Booking status changed to cancelled

2. **Reschedule Booking**
   - PUT `/customer-bookings/{bookingId}/reschedule`
   - Body: `{"newScheduledDate": "2024-10-20T10:00:00Z"}`
   - Expected: Booking date updated

---

## Test Scenario 2: Partner Journey

### Step 1: Partner Authentication
**Using Postman:**
1. **Request OTP**
   - POST `/auth-login`
   - Body: `{"phone": "+919876543211", "userType": "partner"}`

2. **Verify OTP**
   - POST `/auth-verify-otp`
   - Expected: Partner profile created

### Step 2: Verification Process
1. **Get Verification Status**
   - GET `/partner-profile/verification`
   - Expected: Pending status with required documents

2. **Upload Documents**
   - POST `/partner-profile/documents`
   - Body: `{"type": "aadhar", "fileUrl": "https://example.com/doc.pdf"}`
   - Repeat for: PAN, police verification, profile photo

3. **Update Profile**
   - PUT `/partner-profile`
   - Body: Services offered, availability settings

### Step 3: Job Management
1. **Get Available Jobs**
   - GET `/partner-jobs/available?page=1&limit=20`
   - Expected: List of pending bookings matching partner's services

2. **Accept Job**
   - POST `/partner-jobs/{jobId}/accept`
   - Body: `{"estimatedArrival": "2024-10-15T10:30:00Z"}`
   - Expected: Job assigned to partner

3. **Get Assigned Jobs**
   - GET `/partner-jobs/assigned`
   - Expected: List of partner's accepted jobs

### Step 4: Job Execution
1. **Start Job**
   - PUT `/partner-jobs/{jobId}/status`
   - Body: `{"status": "in_progress", "notes": "Work started"}`

2. **Complete Job**
   - PUT `/partner-jobs/{jobId}/status`
   - Body: `{"status": "completed", "notes": "Work finished"}`

### Step 5: Earnings
1. **View Earnings**
   - GET `/partner-earnings?fromDate=2024-01-01&groupBy=day`
   - Expected: Earnings breakdown

2. **Request Payout**
   - POST `/partner-earnings`
   - Body: `{"amount": 1000, "bankAccountId": "account-id"}`

---

## Test Scenario 3: Complete Booking Lifecycle

### Prerequisites
- Customer authenticated and profile set up
- Partner authenticated and verified
- Service available in database

### Flow
1. **Customer creates booking** → Status: `pending`
2. **Partner views available jobs** → Sees the new booking
3. **Partner accepts job** → Status: `confirmed`
4. **Partner starts work** → Status: `in_progress`
5. **Partner completes work** → Status: `completed`
6. **Customer rates service** → Rating saved
7. **Partner earnings updated** → Total earnings increased

---

## Test Scenario 4: Error Handling

### Authentication Errors
1. **Invalid Phone Number**
   - POST `/auth-login` with invalid phone
   - Expected: 400 error with validation message

2. **Invalid OTP**
   - POST `/auth-verify-otp` with wrong OTP
   - Expected: 400 error, attempts incremented

3. **Expired Session**
   - Use expired sessionId
   - Expected: 400 error

### Authorization Errors
1. **No Token**
   - Call protected endpoint without token
   - Expected: 401 Unauthorized

2. **Wrong User Type**
   - Customer accessing partner endpoints
   - Expected: 403 Forbidden

### Resource Errors
1. **Booking Not Found**
   - GET `/customer-bookings/invalid-id`
   - Expected: 404 Not Found

2. **Cannot Cancel Completed Booking**
   - Try to cancel completed booking
   - Expected: 400 Bad Request

---

## Test Scenario 5: Flutter App Testing

### Customer App Flow
1. **Launch App** → Shows splash screen
2. **Authentication** → Phone input → OTP input → Home screen
3. **Browse Services** → Service grid → Service details
4. **Create Booking** → Select service → Date/time → Address → Payment → Confirm
5. **View Bookings** → Booking list → Booking details
6. **Profile** → Edit profile → Manage addresses

### Partner App Flow
1. **Launch App** → Onboarding screen
2. **Verification** → Document upload flow
3. **Profile Setup** → Services selection → Availability settings
4. **Job Dashboard** → Available jobs → Job details
5. **Accept Job** → Update status → Complete job
6. **Earnings** → View earnings → Request payout

---

## Performance Testing

### Load Testing (using Postman/Newman)
1. **Authentication Load**
   - 100 concurrent login requests
   - Expected: <2s response time

2. **Service Discovery Load**
   - 50 concurrent service list requests
   - Expected: <1s response time

3. **Database Performance**
   - Test with 1000+ bookings
   - Expected: Pagination works efficiently

### Mobile App Performance
1. **Cold Start Time** → <3 seconds
2. **Navigation Speed** → <300ms between screens
3. **API Response Handling** → Loading states work correctly
4. **Offline Capability** → Cached data available

---

## Security Testing

### Input Validation
1. **SQL Injection** → All inputs properly sanitized
2. **XSS Prevention** → No script execution in inputs
3. **Phone Number Format** → Only valid formats accepted
4. **File Upload** → Only allowed file types

### Authentication Security
1. **Token Expiry** → Access tokens expire appropriately
2. **Refresh Tokens** → Proper rotation implemented
3. **Session Management** → Multiple sessions handled correctly
4. **OTP Security** → Limited attempts, proper expiry

### Data Privacy
1. **RLS Policies** → Users can only access their data
2. **Sensitive Data** → No passwords/secrets in logs
3. **CORS** → Proper origin restrictions
4. **HTTPS** → All communication encrypted (in production)

---

## Success Criteria

### ✅ Backend APIs
- All endpoints return correct responses
- Error handling works consistently
- Authentication flow complete
- Database queries optimized

### ✅ Flutter Apps
- Both apps launch without errors
- UI matches design specifications
- Navigation works smoothly
- API integration functional

### ✅ End-to-End
- Complete customer journey works
- Complete partner journey works
- Real-time updates function
- Data consistency maintained

### ✅ Performance
- API response times <2s
- App startup times <3s
- Database queries optimized
- Memory usage within limits

---

## Next Steps

1. **Set up CI/CD** → Automated testing pipeline
2. **Add Monitoring** → Error tracking, performance monitoring
3. **Scale Testing** → Test with higher loads
4. **Security Audit** → Professional security review
5. **User Testing** → Beta testing with real users

The platform is ready for comprehensive testing! 🧪