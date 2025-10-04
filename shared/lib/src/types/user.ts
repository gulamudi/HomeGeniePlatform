import { z } from 'zod';
import { UuidSchema, TimestampSchema, PhoneSchema, EmailSchema, AddressSchema } from './base';

// User types
export const UserTypeSchema = z.enum(['customer', 'partner']);
export const VerificationStatusSchema = z.enum(['pending', 'in_progress', 'verified', 'rejected']);

// Base user schema
export const UserSchema = z.object({
  id: UuidSchema,
  email: EmailSchema.optional(),
  phone: PhoneSchema,
  fullName: z.string().min(2).max(100),
  avatarUrl: z.string().url().optional(),
  userType: UserTypeSchema,
  createdAt: TimestampSchema,
  updatedAt: TimestampSchema,
});

// Customer profile
export const CustomerProfileSchema = z.object({
  userId: UuidSchema,
  addresses: z.array(AddressSchema).default([]),
  preferences: z.object({
    preferredLanguage: z.string().default('en'),
    notifications: z.object({
      email: z.boolean().default(true),
      sms: z.boolean().default(true),
      push: z.boolean().default(true),
    }).default({}),
  }).default({}),
});

// Partner profile
export const PartnerProfileSchema = z.object({
  userId: UuidSchema,
  verificationStatus: VerificationStatusSchema.default('pending'),
  services: z.array(z.string()).default([]),
  availability: z.object({
    weekdays: z.array(z.number().min(0).max(6)).default([1, 2, 3, 4, 5, 6]), // 0=Sunday, 6=Saturday
    workingHours: z.object({
      start: z.string().regex(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/), // HH:MM format
      end: z.string().regex(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/),
    }),
    isAvailable: z.boolean().default(true),
  }).optional(),
  documents: z.array(z.object({
    type: z.enum(['aadhar', 'pan', 'police_verification', 'profile_photo']),
    url: z.string().url(),
    status: VerificationStatusSchema.default('pending'),
    uploadedAt: TimestampSchema,
  })).default([]),
  rating: z.number().min(0).max(5).default(0),
  totalJobs: z.number().min(0).default(0),
  totalEarnings: z.number().min(0).default(0),
});

// Complete user profiles
export const CustomerUserSchema = UserSchema.extend({
  userType: z.literal('customer'),
  profile: CustomerProfileSchema.optional(),
});

export const PartnerUserSchema = UserSchema.extend({
  userType: z.literal('partner'),
  profile: PartnerProfileSchema.optional(),
});

export type UserType = z.infer<typeof UserTypeSchema>;
export type VerificationStatus = z.infer<typeof VerificationStatusSchema>;
export type User = z.infer<typeof UserSchema>;
export type CustomerProfile = z.infer<typeof CustomerProfileSchema>;
export type PartnerProfile = z.infer<typeof PartnerProfileSchema>;
export type CustomerUser = z.infer<typeof CustomerUserSchema>;
export type PartnerUser = z.infer<typeof PartnerUserSchema>;