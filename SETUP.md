# HomeGenie Platform - Setup Guide

## Overview

Complete HomeGenie platform with customer and partner apps, backend API, and testing tools.

## Project Structure

```
homegenie-platform/
├── shared/                     # Shared contracts and types
├── supabase/                   # Backend (Supabase Edge Functions + Database)
├── homegenie_app/             # Customer Flutter app
├── homegenie_partner_app/     # Partner Flutter app
├── postman/                   # API testing collection
└── docs/                      # Documentation
```

## Prerequisites

1. **Flutter SDK** (3.0+)
2. **Node.js** (18+)
3. **Supabase CLI**
4. **Docker Desktop** (for local Supabase)
5. **Postman** (for API testing)

## Setup Instructions

### 1. Install Dependencies

```bash
# Install Supabase CLI
npm install -g supabase

# Install shared dependencies
cd shared
npm install

# Install Flutter dependencies
cd ../homegenie_app
flutter pub get

cd ../homegenie_partner_app
flutter pub get
```

### 2. Start Backend Services

```bash
# Start Supabase local development
supabase start

# This will start:
# - PostgreSQL database (port 54322)
# - API server (port 54321)
# - Studio UI (port 54323)
# - Auth server
# - Storage server
```

### 3. Generate Code

```bash
# Generate Dart models from TypeScript contracts
cd shared
node scripts/generate-dart-models.js

# Generate API clients for Flutter
cd ../homegenie_app
flutter packages pub run build_runner build

cd ../homegenie_partner_app
flutter packages pub run build_runner build
```

### 4. Database Setup

The database will be automatically set up with:
- ✅ Complete schema with all tables
- ✅ Row Level Security (RLS) policies
- ✅ Sample services data
- ✅ Indexes for performance

### 5. Test the Platform

#### Option A: Using Postman
1. Import `postman/HomeGenie-API.postman_collection.json`
2. Set base URL to `http://127.0.0.1:54321/functions/v1`
3. Test authentication flow:
   - Login → Request OTP
   - Verify OTP
   - Access protected endpoints

#### Option B: Using Flutter Apps
```bash
# Run customer app
cd homegenie_app
flutter run

# Run partner app (in new terminal)
cd homegenie_partner_app
flutter run
```

## API Endpoints

### Authentication
- `POST /auth-login` - Request OTP
- `POST /auth-verify-otp` - Verify OTP and get tokens
- `GET /auth-profile` - Get user profile
- `PUT /auth-profile` - Update profile
- `POST /auth-refresh-token` - Refresh access token
- `POST /auth-logout` - Logout user

### Customer APIs
- `GET /customer-profile` - Get customer profile
- `PUT /customer-profile` - Update customer profile
- `GET/POST/PUT/DELETE /customer-addresses` - Address management
- `GET /customer-services` - Browse services
- `GET /customer-services/{id}` - Service details
- `GET/POST /customer-bookings` - Booking management
- `PUT /customer-bookings/{id}/cancel` - Cancel booking
- `PUT /customer-bookings/{id}/reschedule` - Reschedule booking
- `POST /customer-bookings/ratings` - Rate service

### Partner APIs
- `GET /partner-profile` - Get partner profile
- `PUT /partner-profile` - Update partner profile
- `POST /partner-profile/documents` - Upload verification documents
- `GET /partner-profile/verification` - Check verification status
- `GET /partner-jobs/available` - Get available jobs
- `GET /partner-jobs/assigned` - Get assigned jobs
- `POST /partner-jobs/{id}/accept` - Accept job
- `PUT /partner-jobs/{id}/status` - Update job status
- `GET /partner-earnings` - Get earnings data
- `POST /partner-earnings` - Request payout

## Key Features

### ✅ Backend (Supabase)
- Complete database schema with RLS
- TypeScript edge functions
- OTP-based authentication
- File upload support
- Real-time subscriptions

### ✅ Frontend (Flutter)
- Material Design 3 UI
- Riverpod state management
- Type-safe API integration
- Offline data caching
- Push notifications ready

### ✅ Architecture
- Contract-first development
- Shared types across frontend/backend
- Comprehensive error handling
- Scalable folder structure
- Automated code generation

## Development Workflow

1. **Make API Changes**: Update TypeScript contracts in `shared/`
2. **Generate Models**: Run dart model generation script
3. **Update Edge Functions**: Modify functions in `supabase/functions/`
4. **Test APIs**: Use Postman collection
5. **Update Flutter Apps**: Implement UI changes
6. **Test End-to-End**: Run both apps and test user flows

## Environment Configuration

### Development
- Database: Local PostgreSQL
- API: Local Supabase functions
- Auth: Local Supabase auth

### Production Setup
1. Create Supabase project
2. Deploy edge functions: `supabase functions deploy`
3. Run migrations: `supabase db push`
4. Configure environment variables
5. Deploy Flutter apps to app stores

## Troubleshooting

### Port Conflicts
```bash
# Kill processes on Supabase ports
lsof -ti:54321,54322,54323 | xargs kill -9
supabase stop
supabase start
```

### Docker Issues
- Ensure Docker Desktop is running
- Check available memory (min 4GB recommended)

### Flutter Build Issues
```bash
flutter clean
flutter pub get
flutter packages pub run build_runner clean
flutter packages pub run build_runner build --delete-conflicting-outputs
```

## Testing Scenarios

### Customer Flow
1. ✅ Phone authentication with OTP
2. ✅ Browse and search services
3. ✅ Create booking with address
4. ✅ View booking history
5. ✅ Cancel/reschedule booking
6. ✅ Rate completed service

### Partner Flow
1. ✅ Phone authentication with OTP
2. ✅ Complete verification process
3. ✅ Set availability and preferences
4. ✅ View and accept available jobs
5. ✅ Update job status during service
6. ✅ View earnings and request payout

### Admin Features (Future)
- Service management
- User verification approval
- Analytics and reporting
- Payment processing

## Security Features

- ✅ Row Level Security on all tables
- ✅ JWT token-based authentication
- ✅ Phone number verification
- ✅ Input validation on all endpoints
- ✅ CORS configuration
- ✅ File upload restrictions

## Performance Optimizations

- ✅ Database indexes on key columns
- ✅ Pagination on list endpoints
- ✅ Image optimization and caching
- ✅ Lazy loading in Flutter apps
- ✅ Connection pooling in database

The platform is now ready for development and testing! 🚀