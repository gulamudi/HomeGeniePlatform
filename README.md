# HomeGenie Platform

A comprehensive service platform connecting customers with home service providers.

## Project Structure

```
homegenie-platform/
├── shared/                  # Shared contracts and types
│   ├── contracts/          # API contracts and schemas
│   ├── types/              # Shared TypeScript types
│   └── constants/          # Shared constants
├── supabase/               # Backend (Supabase)
│   ├── functions/          # Edge functions
│   ├── migrations/         # Database migrations
│   ├── seed.sql           # Initial data
│   └── config.toml        # Supabase configuration
├── homegenie-app/         # Customer Flutter app
├── homegenie-partner-app/ # Service provider Flutter app
├── postman/              # API testing collection
└── docs/                 # Documentation
```

## Development Setup

### Prerequisites
- Node.js 18+
- Flutter 3.0+
- Supabase CLI
- Dart SDK

### Getting Started

1. **Install Supabase CLI**
   ```bash
   npm install -g supabase
   ```

2. **Initialize Supabase**
   ```bash
   cd supabase
   supabase init
   supabase start
   ```

3. **Install Dependencies**
   ```bash
   # For shared contracts
   cd shared
   npm install

   # For Flutter apps
   cd homegenie-app
   flutter pub get

   cd ../homegenie-partner-app
   flutter pub get
   ```

## Architecture

### Contract-First Development
- All API contracts defined in TypeScript
- Auto-generated Dart models for Flutter apps
- Type safety enforced across the entire stack
- Postman collection auto-generated from contracts

### Backend (Supabase)
- Edge Functions with TypeScript
- PostgreSQL with Row Level Security
- Real-time subscriptions
- File storage for documents/images

### Frontend (Flutter)
- Two separate apps: Customer and Partner
- Riverpod for state management
- GoRouter for navigation
- Hive for local caching

## Testing

- **Backend**: Unit tests for edge functions, Postman collection
- **Frontend**: Widget tests, unit tests, integration tests
- **E2E**: Full user journey testing

## Deployment

- **Backend**: Supabase Cloud
- **Frontend**: App stores (iOS/Android)

## Contributing

1. Follow contract-first development
2. Update shared contracts before implementation
3. Generate Dart models after contract changes
4. Run tests before submitting PR# HomeGeniePlatform
