import { z } from 'npm:zod';

// Base types
export const UuidSchema = z.string().uuid();
export const TimestampSchema = z.string().datetime();
export const PhoneSchema = z.string().regex(/^\+?[1-9]\d{1,14}$/);
export const EmailSchema = z.string().email();

// Common response wrapper
export const ApiResponseSchema = <T extends z.ZodType>(dataSchema: T) =>
  z.object({
    success: z.boolean(),
    data: dataSchema.optional(),
    error: z.string().optional(),
    message: z.string().optional(),
  });

// Pagination
export const PaginationSchema = z.object({
  page: z.number().min(1).default(1),
  limit: z.number().min(1).max(100).default(20),
  total: z.number().optional(),
  totalPages: z.number().optional(),
});

// Address schema
export const AddressSchema = z.object({
  id: UuidSchema.optional(),
  flatHouseNo: z.string(),
  buildingApartmentName: z.string().optional(),
  streetName: z.string(),
  landmark: z.string().optional(),
  area: z.string(),
  city: z.string(),
  state: z.string(),
  pinCode: z.string().regex(/^\d{6}$/),
  type: z.enum(['home', 'office', 'other']).default('home'),
  isDefault: z.boolean().default(false),
});

export type Uuid = z.infer<typeof UuidSchema>;
export type Timestamp = z.infer<typeof TimestampSchema>;
export type Phone = z.infer<typeof PhoneSchema>;
export type Email = z.infer<typeof EmailSchema>;
export type ApiResponse<T> = {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
};
export type Pagination = z.infer<typeof PaginationSchema>;
export type Address = z.infer<typeof AddressSchema>;