import { z } from 'npm:zod';
import { PhoneSchema, ApiResponseSchema } from '../types/base.ts';
import { UserSchema, UserTypeSchema } from '../types/user.ts';

// Login request
export const LoginRequestSchema = z.object({
  phone: PhoneSchema,
  userType: UserTypeSchema,
});

export const LoginResponseSchema = ApiResponseSchema(
  z.object({
    sessionId: z.string(),
    otpSent: z.boolean(),
  })
);

// OTP verification
export const VerifyOtpRequestSchema = z.object({
  phone: PhoneSchema,
  otp: z.string().length(6),
  sessionId: z.string(),
});

export const VerifyOtpResponseSchema = ApiResponseSchema(
  z.object({
    user: UserSchema,
    accessToken: z.string(),
    refreshToken: z.string(),
    isNewUser: z.boolean(),
  })
);

// Refresh token
export const RefreshTokenRequestSchema = z.object({
  refreshToken: z.string(),
});

export const RefreshTokenResponseSchema = ApiResponseSchema(
  z.object({
    accessToken: z.string(),
    refreshToken: z.string(),
  })
);

// Logout
export const LogoutRequestSchema = z.object({
  refreshToken: z.string(),
});

export const LogoutResponseSchema = ApiResponseSchema(z.object({}));

// Update profile
export const UpdateProfileRequestSchema = z.object({
  fullName: z.string().min(2).max(100).optional(),
  email: z.string().email().optional(),
  avatarUrl: z.string().url().optional(),
});

export const UpdateProfileResponseSchema = ApiResponseSchema(UserSchema);

export type LoginRequest = z.infer<typeof LoginRequestSchema>;
export type LoginResponse = z.infer<typeof LoginResponseSchema>;
export type VerifyOtpRequest = z.infer<typeof VerifyOtpRequestSchema>;
export type VerifyOtpResponse = z.infer<typeof VerifyOtpResponseSchema>;
export type RefreshTokenRequest = z.infer<typeof RefreshTokenRequestSchema>;
export type RefreshTokenResponse = z.infer<typeof RefreshTokenResponseSchema>;
export type LogoutRequest = z.infer<typeof LogoutRequestSchema>;
export type LogoutResponse = z.infer<typeof LogoutResponseSchema>;
export type UpdateProfileRequest = z.infer<typeof UpdateProfileRequestSchema>;
export type UpdateProfileResponse = z.infer<typeof UpdateProfileResponseSchema>;