# Partner Preferences Architecture - SIMPLIFIED

## Database Schema (KISS Principle)

### Tables Overview

1. **`partner_profiles`** - Static preferences (what partner CAN do)
   - `services`: TEXT[] - Array of service categories (e.g., 'cleaning', 'plumbing')
   - `availability`: JSONB - Weekly schedule (weekdays, working hours)
   - `job_preferences`: JSONB - Job settings (max distance, preferred areas, etc.)

2. **`partner_availability`** - Real-time status (what partner IS doing)
   - `is_online`: BOOLEAN - Currently online?
   - `is_accepting_jobs`: BOOLEAN - Accepting jobs right now?
   - `current_location`: GEOGRAPHY - GPS location
   - **NOTE**: This is DIFFERENT from preferences! Don't confuse them!

3. **`service_areas`** - Available service locations
   - `id`, `name`, `city`, `state`, `center_location`, `radius_km`
   - Already seeded with 18 areas (10 Mumbai, 8 Pune)

## Data Flow

```
Partner App (Flutter)
    ↓
API Client (Dio) → /partner-preferences
    ↓
Supabase Edge Function
    ↓
partner_profiles table (PostgreSQL)
```

## Current Issues & Fixes

### Issue 1: Preferences Not Saving
**Root Cause**: TBD - Need to check logs
**Fix**: Added comprehensive logging to backend

### Issue 2: Service Areas Not Showing
**Root Cause**: Frontend model mismatch
**Fix**: Service areas backend returns correct format, need to verify frontend parsing

## Backend Endpoints

### GET /partner-preferences
- Reads from `partner_profiles` table
- Returns: `{ services, availability, jobPreferences }`

### PUT /partner-preferences
- Updates `partner_profiles` table
- Accepts: `{ services?, availability?, jobPreferences? }`

### GET /service-areas
- Reads from `service_areas` table
- Returns: `{ areas[], groupedByCity{}, count }`

## What's What

- **Services** (`partner_profiles.services`): What type of work you do
- **Availability** (`partner_profiles.availability`): Your regular weekly schedule
- **Job Preferences** (`partner_profiles.job_preferences`): Your job filters (distance, areas, etc.)
- **Service Areas** (`service_areas` table): Geographic areas where service is available

## Next Steps

1. Check Supabase logs to see if UPDATE is actually happening
2. Verify service areas API is being called correctly
3. Simplify frontend state management
