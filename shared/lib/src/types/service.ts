import { z } from 'npm:zod';
import { UuidSchema, TimestampSchema } from './base.ts';

// Service categories
export const ServiceCategorySchema = z.enum([
  'cleaning',
  'plumbing',
  'electrical',
  'gardening',
  'handyman',
  'beauty',
  'appliance_repair',
  'painting',
  'pest_control',
  'home_security'
]);

// Service schema
export const ServiceSchema = z.object({
  id: UuidSchema,
  name: z.string().min(2).max(100),
  description: z.string().max(500),
  category: ServiceCategorySchema,
  basePrice: z.number().min(0),
  durationHours: z.number().min(0.5).max(24),
  isActive: z.boolean().default(true),
  requirements: z.array(z.string()).default([]),
  includes: z.array(z.string()).default([]),
  excludes: z.array(z.string()).default([]),
  imageUrl: z.string().url().optional(),
  createdAt: TimestampSchema,
  updatedAt: TimestampSchema,
});

// Service pricing tiers
export const PricingTierSchema = z.object({
  id: UuidSchema,
  serviceId: UuidSchema,
  name: z.string(), // e.g., "1 BHK", "2 BHK", "3 BHK"
  description: z.string().optional(),
  price: z.number().min(0),
  durationHours: z.number().min(0.5),
  isDefault: z.boolean().default(false),
});

export type ServiceCategory = z.infer<typeof ServiceCategorySchema>;
export type Service = z.infer<typeof ServiceSchema>;
export type PricingTier = z.infer<typeof PricingTierSchema>;