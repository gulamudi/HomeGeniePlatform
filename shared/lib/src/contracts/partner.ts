import { z } from 'zod';
import { UuidSchema, ApiResponseSchema, PaginationSchema } from '../types/base';
import { PartnerProfileSchema, PartnerUserSchema, VerificationStatusSchema } from '../types/user';
import { BookingSchema, BookingStatusSchema, JobPreferencesSchema } from '../types/booking';

// Get partner profile
export const GetPartnerProfileResponseSchema = ApiResponseSchema(PartnerUserSchema);

// Update partner profile
export const UpdatePartnerProfileRequestSchema = PartnerProfileSchema.partial().omit({ userId: true });
export const UpdatePartnerProfileResponseSchema = ApiResponseSchema(PartnerProfileSchema);

// Document upload for verification
export const UploadDocumentRequestSchema = z.object({
  type: z.enum(['aadhar', 'pan', 'police_verification', 'profile_photo']),
  fileUrl: z.string().url(),
});

export const UploadDocumentResponseSchema = ApiResponseSchema(z.object({
  documentId: UuidSchema,
  status: VerificationStatusSchema,
}));

// Get verification status
export const GetVerificationStatusResponseSchema = ApiResponseSchema(
  z.object({
    overallStatus: VerificationStatusSchema,
    documents: z.array(z.object({
      type: z.enum(['aadhar', 'pan', 'police_verification', 'profile_photo']),
      status: VerificationStatusSchema,
      url: z.string().url(),
      rejectionReason: z.string().optional(),
      uploadedAt: z.string().datetime(),
    })),
  })
);

// Job preferences
export const UpdateJobPreferencesRequestSchema = JobPreferencesSchema.partial();
export const UpdateJobPreferencesResponseSchema = ApiResponseSchema(JobPreferencesSchema);
export const GetJobPreferencesResponseSchema = ApiResponseSchema(JobPreferencesSchema);

// Available jobs
export const GetAvailableJobsRequestSchema = z.object({
  radius: z.number().min(1).max(50).optional(),
  serviceCategory: z.string().optional(),
  minAmount: z.number().min(0).optional(),
  maxAmount: z.number().min(0).optional(),
}).merge(PaginationSchema);

export const GetAvailableJobsResponseSchema = ApiResponseSchema(
  z.object({
    jobs: z.array(BookingSchema),
    pagination: PaginationSchema,
  })
);

// Job actions
export const AcceptJobRequestSchema = z.object({
  bookingId: UuidSchema,
  estimatedArrival: z.string().datetime().optional(),
});

export const AcceptJobResponseSchema = ApiResponseSchema(BookingSchema);

export const RejectJobRequestSchema = z.object({
  bookingId: UuidSchema,
  reason: z.string().max(500).optional(),
});

export const RejectJobResponseSchema = ApiResponseSchema(z.object({}));

// Job status updates
export const UpdateJobStatusRequestSchema = z.object({
  bookingId: UuidSchema,
  status: BookingStatusSchema,
  notes: z.string().max(500).optional(),
  location: z.object({
    lat: z.number(),
    lng: z.number(),
  }).optional(),
});

export const UpdateJobStatusResponseSchema = ApiResponseSchema(BookingSchema);

// Get assigned jobs
export const GetAssignedJobsRequestSchema = z.object({
  status: BookingStatusSchema.optional(),
  fromDate: z.string().datetime().optional(),
  toDate: z.string().datetime().optional(),
}).merge(PaginationSchema);

export const GetAssignedJobsResponseSchema = ApiResponseSchema(
  z.object({
    jobs: z.array(BookingSchema),
    pagination: PaginationSchema,
  })
);

// Earnings
export const GetEarningsRequestSchema = z.object({
  fromDate: z.string().datetime().optional(),
  toDate: z.string().datetime().optional(),
  groupBy: z.enum(['day', 'week', 'month']).optional(),
}).merge(PaginationSchema);

export const GetEarningsResponseSchema = ApiResponseSchema(
  z.object({
    totalEarnings: z.number(),
    totalJobs: z.number(),
    averageRating: z.number(),
    earnings: z.array(z.object({
      date: z.string().datetime(),
      amount: z.number(),
      jobsCompleted: z.number(),
    })),
    pagination: PaginationSchema,
  })
);

// Payout
export const RequestPayoutRequestSchema = z.object({
  amount: z.number().min(100), // Minimum payout amount
  bankAccountId: UuidSchema,
});

export const RequestPayoutResponseSchema = ApiResponseSchema(
  z.object({
    payoutId: UuidSchema,
    status: z.enum(['pending', 'processing', 'completed', 'failed']),
    estimatedDate: z.string().datetime(),
  })
);

// Availability
export const UpdateAvailabilityRequestSchema = z.object({
  isAvailable: z.boolean(),
  workingHours: z.object({
    start: z.string().regex(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/),
    end: z.string().regex(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/),
  }).optional(),
  weekdays: z.array(z.number().min(0).max(6)).optional(),
});

export const UpdateAvailabilityResponseSchema = ApiResponseSchema(z.object({}));

export type GetPartnerProfileResponse = z.infer<typeof GetPartnerProfileResponseSchema>;
export type UpdatePartnerProfileRequest = z.infer<typeof UpdatePartnerProfileRequestSchema>;
export type UpdatePartnerProfileResponse = z.infer<typeof UpdatePartnerProfileResponseSchema>;
export type UploadDocumentRequest = z.infer<typeof UploadDocumentRequestSchema>;
export type UploadDocumentResponse = z.infer<typeof UploadDocumentResponseSchema>;
export type GetVerificationStatusResponse = z.infer<typeof GetVerificationStatusResponseSchema>;
export type UpdateJobPreferencesRequest = z.infer<typeof UpdateJobPreferencesRequestSchema>;
export type UpdateJobPreferencesResponse = z.infer<typeof UpdateJobPreferencesResponseSchema>;
export type GetJobPreferencesResponse = z.infer<typeof GetJobPreferencesResponseSchema>;
export type GetAvailableJobsRequest = z.infer<typeof GetAvailableJobsRequestSchema>;
export type GetAvailableJobsResponse = z.infer<typeof GetAvailableJobsResponseSchema>;
export type AcceptJobRequest = z.infer<typeof AcceptJobRequestSchema>;
export type AcceptJobResponse = z.infer<typeof AcceptJobResponseSchema>;
export type RejectJobRequest = z.infer<typeof RejectJobRequestSchema>;
export type RejectJobResponse = z.infer<typeof RejectJobResponseSchema>;
export type UpdateJobStatusRequest = z.infer<typeof UpdateJobStatusRequestSchema>;
export type UpdateJobStatusResponse = z.infer<typeof UpdateJobStatusResponseSchema>;
export type GetAssignedJobsRequest = z.infer<typeof GetAssignedJobsRequestSchema>;
export type GetAssignedJobsResponse = z.infer<typeof GetAssignedJobsResponseSchema>;
export type GetEarningsRequest = z.infer<typeof GetEarningsRequestSchema>;
export type GetEarningsResponse = z.infer<typeof GetEarningsResponseSchema>;
export type RequestPayoutRequest = z.infer<typeof RequestPayoutRequestSchema>;
export type RequestPayoutResponse = z.infer<typeof RequestPayoutResponseSchema>;
export type UpdateAvailabilityRequest = z.infer<typeof UpdateAvailabilityRequestSchema>;
export type UpdateAvailabilityResponse = z.infer<typeof UpdateAvailabilityResponseSchema>;