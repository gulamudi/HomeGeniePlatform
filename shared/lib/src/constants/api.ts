// API endpoints
export const API_ENDPOINTS = {
  // Authentication
  AUTH: {
    LOGIN: '/auth/login',
    VERIFY_OTP: '/auth/verify-otp',
    REFRESH_TOKEN: '/auth/refresh-token',
    LOGOUT: '/auth/logout',
    UPDATE_PROFILE: '/auth/profile',
  },

  // Customer endpoints
  CUSTOMER: {
    PROFILE: '/customer/profile',
    ADDRESSES: '/customer/addresses',
    SERVICES: '/customer/services',
    SERVICE_DETAILS: (serviceId: string) => `/customer/services/${serviceId}`,
    BOOKINGS: '/customer/bookings',
    BOOKING_DETAILS: (bookingId: string) => `/customer/bookings/${bookingId}`,
    CANCEL_BOOKING: (bookingId: string) => `/customer/bookings/${bookingId}/cancel`,
    RESCHEDULE_BOOKING: (bookingId: string) => `/customer/bookings/${bookingId}/reschedule`,
    RATE_SERVICE: '/customer/ratings',
  },

  // Partner endpoints
  PARTNER: {
    PROFILE: '/partner/profile',
    VERIFICATION: '/partner/verification',
    DOCUMENTS: '/partner/documents',
    JOB_PREFERENCES: '/partner/job-preferences',
    AVAILABLE_JOBS: '/partner/jobs/available',
    ASSIGNED_JOBS: '/partner/jobs/assigned',
    ACCEPT_JOB: (bookingId: string) => `/partner/jobs/${bookingId}/accept`,
    REJECT_JOB: (bookingId: string) => `/partner/jobs/${bookingId}/reject`,
    UPDATE_JOB_STATUS: (bookingId: string) => `/partner/jobs/${bookingId}/status`,
    EARNINGS: '/partner/earnings',
    PAYOUT: '/partner/payout',
    AVAILABILITY: '/partner/availability',
  },

  // Shared endpoints
  SHARED: {
    BOOKING_DETAILS: (bookingId: string) => `/bookings/${bookingId}`,
    SUPPORT: '/support/contact',
    UPLOAD: '/upload',
  },
} as const;

// HTTP status codes
export const HTTP_STATUS = {
  OK: 200,
  CREATED: 201,
  BAD_REQUEST: 400,
  UNAUTHORIZED: 401,
  FORBIDDEN: 403,
  NOT_FOUND: 404,
  CONFLICT: 409,
  UNPROCESSABLE_ENTITY: 422,
  INTERNAL_SERVER_ERROR: 500,
} as const;

// API response messages
export const API_MESSAGES = {
  SUCCESS: 'Operation completed successfully',
  UNAUTHORIZED: 'Invalid credentials or session expired',
  VALIDATION_ERROR: 'Validation failed',
  NOT_FOUND: 'Resource not found',
  INTERNAL_ERROR: 'Internal server error',
  OTP_SENT: 'OTP sent successfully',
  OTP_VERIFIED: 'OTP verified successfully',
  BOOKING_CREATED: 'Booking created successfully',
  BOOKING_CANCELLED: 'Booking cancelled successfully',
  PROFILE_UPDATED: 'Profile updated successfully',
} as const;