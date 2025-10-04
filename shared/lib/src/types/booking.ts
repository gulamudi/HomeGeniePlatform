import { z } from 'zod';
import { UuidSchema, TimestampSchema, AddressSchema } from './base';

// Booking status
export const BookingStatusSchema = z.enum([
  'pending',           // Waiting for partner acceptance
  'confirmed',         // Partner accepted
  'in_progress',       // Service started
  'completed',         // Service completed
  'cancelled',         // Cancelled by customer/partner
  'no_show',          // Partner didn't show up
  'disputed'          // There's a dispute
]);

// Payment methods
export const PaymentMethodSchema = z.enum([
  'cash',
  'card',
  'upi',
  'wallet',
  'net_banking'
]);

// Payment status
export const PaymentStatusSchema = z.enum([
  'pending',
  'processing',
  'completed',
  'failed',
  'refunded'
]);

// Booking schema
export const BookingSchema = z.object({
  id: UuidSchema,
  customerId: UuidSchema,
  partnerId: UuidSchema.optional(),
  serviceId: UuidSchema,
  status: BookingStatusSchema.default('pending'),
  scheduledDate: TimestampSchema,
  durationHours: z.number().min(0.5),
  address: AddressSchema,
  totalAmount: z.number().min(0),
  paymentMethod: PaymentMethodSchema,
  paymentStatus: PaymentStatusSchema.default('pending'),
  specialInstructions: z.string().max(500).optional(),
  preferredPartnerId: UuidSchema.optional(),
  createdAt: TimestampSchema,
  updatedAt: TimestampSchema,

  // Navigation fields (populated in queries)
  customer: z.any().optional(),
  partner: z.any().optional(),
  service: z.any().optional(),
});

// Booking timeline/history
export const BookingTimelineSchema = z.object({
  id: UuidSchema,
  bookingId: UuidSchema,
  status: BookingStatusSchema,
  timestamp: TimestampSchema,
  notes: z.string().max(500).optional(),
  updatedBy: UuidSchema, // User who made this update
  updatedByType: z.enum(['customer', 'partner', 'system']),
});

// Rating schema
export const RatingSchema = z.object({
  id: UuidSchema,
  bookingId: UuidSchema,
  customerId: UuidSchema,
  partnerId: UuidSchema,
  rating: z.number().min(1).max(5),
  comment: z.string().max(500).optional(),
  ratingCategories: z.object({
    punctuality: z.number().min(1).max(5).optional(),
    quality: z.number().min(1).max(5).optional(),
    cleanliness: z.number().min(1).max(5).optional(),
    professionalism: z.number().min(1).max(5).optional(),
  }).optional(),
  createdAt: TimestampSchema,
});

// Job preferences for partners
export const JobPreferencesSchema = z.object({
  maxDistance: z.number().min(1).max(50).default(10), // km
  preferredAreas: z.array(z.string()).default([]),
  preferredServices: z.array(UuidSchema).default([]),
  minJobValue: z.number().min(0).default(0),
  autoAccept: z.boolean().default(false),
});

export type BookingStatus = z.infer<typeof BookingStatusSchema>;
export type PaymentMethod = z.infer<typeof PaymentMethodSchema>;
export type PaymentStatus = z.infer<typeof PaymentStatusSchema>;
export type Booking = z.infer<typeof BookingSchema>;
export type BookingTimeline = z.infer<typeof BookingTimelineSchema>;
export type Rating = z.infer<typeof RatingSchema>;
export type JobPreferences = z.infer<typeof JobPreferencesSchema>;