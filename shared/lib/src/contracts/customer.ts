import { z } from 'npm:zod';
import { UuidSchema, ApiResponseSchema, PaginationSchema, AddressSchema } from '../types/base.ts';
import { CustomerProfileSchema, CustomerUserSchema } from '../types/user.ts';
import { ServiceSchema } from '../types/service.ts';
import { BookingSchema, PaymentMethodSchema } from '../types/booking.ts';

// Get customer profile
export const GetCustomerProfileResponseSchema = ApiResponseSchema(CustomerUserSchema);

// Update customer profile
export const UpdateCustomerProfileRequestSchema = CustomerProfileSchema.partial().omit({ userId: true });
export const UpdateCustomerProfileResponseSchema = ApiResponseSchema(CustomerProfileSchema);

// Address management
export const AddAddressRequestSchema = AddressSchema.omit({ id: true });
export const AddAddressResponseSchema = ApiResponseSchema(AddressSchema);

export const UpdateAddressRequestSchema = AddressSchema.partial().required({ id: true });
export const UpdateAddressResponseSchema = ApiResponseSchema(AddressSchema);

export const DeleteAddressRequestSchema = z.object({
  addressId: UuidSchema,
});
export const DeleteAddressResponseSchema = ApiResponseSchema(z.object({}));

export const GetAddressesResponseSchema = ApiResponseSchema(z.array(AddressSchema));

// Service discovery
export const GetServicesRequestSchema = z.object({
  category: z.string().optional(),
  search: z.string().optional(),
  location: z.object({
    lat: z.number(),
    lng: z.number(),
  }).optional(),
}).merge(PaginationSchema);

export const GetServicesResponseSchema = ApiResponseSchema(
  z.object({
    services: z.array(ServiceSchema),
    pagination: PaginationSchema,
  })
);

export const GetServiceDetailsRequestSchema = z.object({
  serviceId: UuidSchema,
});

export const GetServiceDetailsResponseSchema = ApiResponseSchema(ServiceSchema);

// Booking creation
export const CreateBookingRequestSchema = z.object({
  serviceId: UuidSchema,
  scheduledDate: z.string().datetime(),
  durationHours: z.number().min(0.5),
  address: AddressSchema,
  paymentMethod: PaymentMethodSchema,
  specialInstructions: z.string().max(500).optional(),
  preferredPartnerId: UuidSchema.optional(),
});

export const CreateBookingResponseSchema = ApiResponseSchema(BookingSchema);

// Booking management
export const GetBookingsRequestSchema = z.object({
  status: z.string().optional(),
  fromDate: z.string().datetime().optional(),
  toDate: z.string().datetime().optional(),
}).merge(PaginationSchema);

export const GetBookingsResponseSchema = ApiResponseSchema(
  z.object({
    bookings: z.array(BookingSchema),
    pagination: PaginationSchema,
  })
);

export const GetBookingDetailsRequestSchema = z.object({
  bookingId: UuidSchema,
});

export const GetBookingDetailsResponseSchema = ApiResponseSchema(BookingSchema);

// Booking actions
export const CancelBookingRequestSchema = z.object({
  bookingId: UuidSchema,
  reason: z.string().max(500).optional(),
});

export const CancelBookingResponseSchema = ApiResponseSchema(BookingSchema);

export const RescheduleBookingRequestSchema = z.object({
  bookingId: UuidSchema,
  newScheduledDate: z.string().datetime(),
});

export const RescheduleBookingResponseSchema = ApiResponseSchema(BookingSchema);

// Rating and feedback
export const RateServiceRequestSchema = z.object({
  bookingId: UuidSchema,
  rating: z.number().min(1).max(5),
  comment: z.string().max(500).optional(),
  ratingCategories: z.object({
    punctuality: z.number().min(1).max(5).optional(),
    quality: z.number().min(1).max(5).optional(),
    cleanliness: z.number().min(1).max(5).optional(),
    professionalism: z.number().min(1).max(5).optional(),
  }).optional(),
});

export const RateServiceResponseSchema = ApiResponseSchema(z.object({}));

export type GetCustomerProfileResponse = z.infer<typeof GetCustomerProfileResponseSchema>;
export type UpdateCustomerProfileRequest = z.infer<typeof UpdateCustomerProfileRequestSchema>;
export type UpdateCustomerProfileResponse = z.infer<typeof UpdateCustomerProfileResponseSchema>;
export type AddAddressRequest = z.infer<typeof AddAddressRequestSchema>;
export type AddAddressResponse = z.infer<typeof AddAddressResponseSchema>;
export type UpdateAddressRequest = z.infer<typeof UpdateAddressRequestSchema>;
export type UpdateAddressResponse = z.infer<typeof UpdateAddressResponseSchema>;
export type DeleteAddressRequest = z.infer<typeof DeleteAddressRequestSchema>;
export type DeleteAddressResponse = z.infer<typeof DeleteAddressResponseSchema>;
export type GetAddressesResponse = z.infer<typeof GetAddressesResponseSchema>;
export type GetServicesRequest = z.infer<typeof GetServicesRequestSchema>;
export type GetServicesResponse = z.infer<typeof GetServicesResponseSchema>;
export type GetServiceDetailsRequest = z.infer<typeof GetServiceDetailsRequestSchema>;
export type GetServiceDetailsResponse = z.infer<typeof GetServiceDetailsResponseSchema>;
export type CreateBookingRequest = z.infer<typeof CreateBookingRequestSchema>;
export type CreateBookingResponse = z.infer<typeof CreateBookingResponseSchema>;
export type GetBookingsRequest = z.infer<typeof GetBookingsRequestSchema>;
export type GetBookingsResponse = z.infer<typeof GetBookingsResponseSchema>;
export type GetBookingDetailsRequest = z.infer<typeof GetBookingDetailsRequestSchema>;
export type GetBookingDetailsResponse = z.infer<typeof GetBookingDetailsResponseSchema>;
export type CancelBookingRequest = z.infer<typeof CancelBookingRequestSchema>;
export type CancelBookingResponse = z.infer<typeof CancelBookingResponseSchema>;
export type RescheduleBookingRequest = z.infer<typeof RescheduleBookingRequestSchema>;
export type RescheduleBookingResponse = z.infer<typeof RescheduleBookingResponseSchema>;
export type RateServiceRequest = z.infer<typeof RateServiceRequestSchema>;
export type RateServiceResponse = z.infer<typeof RateServiceResponseSchema>;