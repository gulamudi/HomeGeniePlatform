/**
 * Global configuration for Supabase Edge Functions
 *
 * ⚠️  IMPORTANT: This should be kept in sync with shared/lib/config/app_config.dart
 *
 * To enable/disable TEST_MODE, update both:
 * 1. This file (config.ts)
 * 2. shared/lib/config/app_config.dart
 */

export const AppConfig = {
  /**
   * TEST MODE for partner assignment and notifications
   * When true, disables smart ranking logic and shows all available partners
   *
   * Currently used for:
   * - assign-booking-to-partner function: Fetches ALL verified partners instead of ranked partners
   * - preferred-partners function: Returns max 3 partners for UI testing
   * - Partner notifications: Sends to all partners regardless of ranking
   *
   * Set to false for production to enable intelligent partner matching
   */
  TEST_MODE: true, // Set to false for production

  /**
   * Maximum number of preferred partners to show in TEST_MODE
   */
  MAX_PREFERRED_PARTNERS_TEST_MODE: 3,

  /**
   * OTP Configuration
   */
  ENABLE_OTP_VERIFICATION: false, // Set to true for production
  TEST_OTP: '123456',

  /**
   * Timeouts and limits
   */
  API_TIMEOUT_SECONDS: 30,
  JOB_ACCEPTANCE_TIMEOUT_MINUTES: 15,

  /**
   * Partner Configuration
   */
  PARTNER_COMMISSION_RATE: 0.20, // 20%
  MIN_PAYOUT_AMOUNT: 100.0,

  /**
   * Notification Configuration
   */
  DEFAULT_BATCH_SIZE: 5,
  DEFAULT_EXPIRY_SECONDS: 30,
} as const

/**
 * Type-safe getter for app settings with fallback to config defaults
 */
export function getConfigValue<T>(key: string, defaultValue: T): T {
  // In the future, this could read from app_settings table
  // For now, use the config constants
  return defaultValue
}
