// App configuration
export const APP_CONFIG = {
  NAME: 'HomeGenie',
  VERSION: '1.0.0',
  PACKAGE_NAME: {
    CUSTOMER: 'com.homegenie.customer',
    PARTNER: 'com.homegenie.partner',
  },
  DEEP_LINK_SCHEME: 'homegenie',
} as const;

// Validation constants
export const VALIDATION = {
  OTP_LENGTH: 6,
  MIN_PASSWORD_LENGTH: 8,
  MAX_NAME_LENGTH: 100,
  MAX_DESCRIPTION_LENGTH: 500,
  MIN_PHONE_LENGTH: 10,
  MAX_PHONE_LENGTH: 15,
  MIN_RATING: 1,
  MAX_RATING: 5,
  MIN_SERVICE_DURATION: 0.5, // hours
  MAX_SERVICE_DURATION: 24, // hours
  MIN_PAYOUT_AMOUNT: 100, // minimum payout amount
  MAX_DISTANCE: 50, // km
  PIN_CODE_LENGTH: 6,
} as const;

// Pagination defaults
export const PAGINATION = {
  DEFAULT_PAGE: 1,
  DEFAULT_LIMIT: 20,
  MAX_LIMIT: 100,
} as const;

// Time constants
export const TIME = {
  OTP_EXPIRY_MINUTES: 10,
  JWT_ACCESS_EXPIRY: '15m',
  JWT_REFRESH_EXPIRY: '7d',
  BOOKING_CANCEL_HOURS: 24, // hours before booking to allow cancellation
  JOB_ACCEPT_TIMEOUT_MINUTES: 15, // timeout for partner to accept job
} as const;

// Service categories with display names
export const SERVICE_CATEGORIES = {
  cleaning: 'House Cleaning',
  plumbing: 'Plumbing',
  electrical: 'Electrical',
  gardening: 'Gardening',
  handyman: 'Handyman',
  beauty: 'Beauty & Wellness',
  appliance_repair: 'Appliance Repair',
  painting: 'Painting',
  pest_control: 'Pest Control',
  home_security: 'Home Security',
} as const;

// Payment methods with display names
export const PAYMENT_METHODS = {
  cash: 'Cash',
  card: 'Credit/Debit Card',
  upi: 'UPI',
  wallet: 'Digital Wallet',
  net_banking: 'Net Banking',
} as const;

// Booking status with display names
export const BOOKING_STATUSES = {
  pending: 'Pending',
  confirmed: 'Confirmed',
  in_progress: 'In Progress',
  completed: 'Completed',
  cancelled: 'Cancelled',
  no_show: 'No Show',
  disputed: 'Disputed',
} as const;

// Document types for partner verification
export const DOCUMENT_TYPES = {
  aadhar: 'Aadhar Card',
  pan: 'PAN Card',
  police_verification: 'Police Verification',
  profile_photo: 'Profile Photo',
} as const;

// Notification types
export const NOTIFICATION_TYPES = {
  BOOKING_CREATED: 'booking_created',
  BOOKING_CONFIRMED: 'booking_confirmed',
  BOOKING_CANCELLED: 'booking_cancelled',
  JOB_AVAILABLE: 'job_available',
  JOB_ACCEPTED: 'job_accepted',
  JOB_STARTED: 'job_started',
  JOB_COMPLETED: 'job_completed',
  PAYMENT_RECEIVED: 'payment_received',
  VERIFICATION_STATUS: 'verification_status',
} as const;

// Error codes
export const ERROR_CODES = {
  INVALID_OTP: 'INVALID_OTP',
  OTP_EXPIRED: 'OTP_EXPIRED',
  USER_NOT_FOUND: 'USER_NOT_FOUND',
  BOOKING_NOT_FOUND: 'BOOKING_NOT_FOUND',
  UNAUTHORIZED_ACCESS: 'UNAUTHORIZED_ACCESS',
  VALIDATION_FAILED: 'VALIDATION_FAILED',
  INSUFFICIENT_BALANCE: 'INSUFFICIENT_BALANCE',
  BOOKING_ALREADY_ACCEPTED: 'BOOKING_ALREADY_ACCEPTED',
  PARTNER_NOT_AVAILABLE: 'PARTNER_NOT_AVAILABLE',
  VERIFICATION_PENDING: 'VERIFICATION_PENDING',
} as const;