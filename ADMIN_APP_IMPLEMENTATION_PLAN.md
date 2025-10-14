# HomeGenie Admin App - Complete Implementation Plan

## Executive Summary
This document outlines the comprehensive plan to create a third Flutter application (`homegenie_admin_app`) that allows administrators to manage customers, partners, and bookings on behalf of users. The admin app will enable profile pre-creation, booking management, and partner assignment while maintaining seamless integration when users eventually sign up through their respective apps.

---

## Table of Contents
1. [System Architecture Overview](#1-system-architecture-overview)
2. [Database Changes Required](#2-database-changes-required)
3. [Authentication & Authorization](#3-authentication--authorization)
4. [Admin App Structure](#4-admin-app-structure)
5. [Feature Implementation Details](#5-feature-implementation-details)
6. [Reusable Components Strategy](#6-reusable-components-strategy)
7. [Database Functions & Edge Functions](#7-database-functions--edge-functions)
8. [Testing Strategy](#8-testing-strategy)
9. [Implementation Timeline](#9-implementation-timeline)
10. [Risk Analysis & Mitigation](#10-risk-analysis--mitigation)

---

## 1. System Architecture Overview

### Current Architecture
- **homegenie_app**: Customer Flutter app
- **homegenie_partner_app**: Partner Flutter app
- **shared**: Shared Flutter library for theme and config
- **supabase**: Backend with PostgreSQL database, RLS policies, and edge functions

### New Architecture
```
HomeGeniePlatform/
├── homegenie_app/              # Customer app (existing)
├── homegenie_partner_app/      # Partner app (existing)
├── homegenie_admin_app/        # NEW: Admin app
├── shared/                     # Shared resources
│   ├── lib/
│   │   ├── theme/
│   │   ├── config/
│   │   ├── models/            # NEW: Shared models
│   │   ├── widgets/           # NEW: Shared widgets
│   │   └── utils/             # NEW: Shared utilities
└── supabase/
    ├── migrations/
    └── functions/
```

---

## 2. Database Changes Required

### 2.1 New Tables

#### `admin_users` Table
```sql
CREATE TABLE public.admin_users (
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE PRIMARY KEY,
    role TEXT NOT NULL DEFAULT 'admin' CHECK (role IN ('super_admin', 'admin', 'support')),
    permissions JSONB DEFAULT '{
        "manage_customers": true,
        "manage_partners": true,
        "manage_bookings": true,
        "manage_services": false,
        "view_analytics": true
    }'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### `admin_actions_log` Table
```sql
CREATE TABLE public.admin_actions_log (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    admin_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
    action_type TEXT NOT NULL,
    target_type TEXT NOT NULL, -- 'customer', 'partner', 'booking'
    target_id UUID,
    description TEXT,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_admin_actions_admin_id ON public.admin_actions_log(admin_id);
CREATE INDEX idx_admin_actions_target ON public.admin_actions_log(target_type, target_id);
CREATE INDEX idx_admin_actions_created_at ON public.admin_actions_log(created_at DESC);
```

### 2.2 Schema Modifications

#### Update `user_type` ENUM
```sql
ALTER TYPE user_type ADD VALUE 'admin';
```

#### Add `created_by_admin` Column to Profiles
```sql
-- Add to customer_profiles
ALTER TABLE public.customer_profiles
ADD COLUMN created_by_admin UUID REFERENCES public.users(id) ON DELETE SET NULL,
ADD COLUMN phone_linked_at TIMESTAMPTZ NULL;

-- Add to partner_profiles
ALTER TABLE public.partner_profiles
ADD COLUMN created_by_admin UUID REFERENCES public.users(id) ON DELETE SET NULL,
ADD COLUMN phone_linked_at TIMESTAMPTZ NULL;
```

### 2.3 RLS Policy Updates

#### Admin Bypass Policies
```sql
-- Helper function to check if user is admin
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.users u
        JOIN public.admin_users au ON u.id = au.user_id
        WHERE u.id = auth.uid()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Admin policies for customer_profiles
CREATE POLICY "Admins can view all customer profiles" ON public.customer_profiles
    FOR SELECT USING (public.is_admin());

CREATE POLICY "Admins can create customer profiles" ON public.customer_profiles
    FOR INSERT WITH CHECK (public.is_admin());

CREATE POLICY "Admins can update customer profiles" ON public.customer_profiles
    FOR UPDATE USING (public.is_admin());

-- Admin policies for partner_profiles
CREATE POLICY "Admins can view all partner profiles" ON public.partner_profiles
    FOR SELECT USING (public.is_admin());

CREATE POLICY "Admins can create partner profiles" ON public.partner_profiles
    FOR INSERT WITH CHECK (public.is_admin());

CREATE POLICY "Admins can update partner profiles" ON public.partner_profiles
    FOR UPDATE USING (public.is_admin());

-- Admin policies for bookings
CREATE POLICY "Admins can view all bookings" ON public.bookings
    FOR SELECT USING (public.is_admin());

CREATE POLICY "Admins can create bookings" ON public.bookings
    FOR INSERT WITH CHECK (public.is_admin());

CREATE POLICY "Admins can update all bookings" ON public.bookings
    FOR UPDATE USING (public.is_admin());

-- Admin policies for users
CREATE POLICY "Admins can view all users" ON public.users
    FOR SELECT USING (public.is_admin());

CREATE POLICY "Admins can create users" ON public.users
    FOR INSERT WITH CHECK (public.is_admin());

CREATE POLICY "Admins can update users" ON public.users
    FOR UPDATE USING (public.is_admin());
```

---

## 3. Authentication & Authorization

### 3.1 Admin Login Flow
- Use the **same phone OTP authentication** as customer and partner apps
- After OTP verification, check if user has `user_type = 'admin'`
- If not admin, reject login with appropriate error message
- Admin users will be manually created in the database by super admins

### 3.2 Profile Linking Strategy

#### Pre-created Profile Flow
1. Admin creates customer/partner profile with phone number (no auth record yet)
2. Store profile with `created_by_admin` = admin's user_id
3. When user signs up with that phone number:
   - Check if profile exists with that phone
   - If exists, link `user_id` from auth to existing profile
   - Set `phone_linked_at` = NOW()
   - User immediately sees their profile and history

#### Implementation via Database Function
```sql
CREATE OR REPLACE FUNCTION public.link_profile_on_signup()
RETURNS TRIGGER AS $$
DECLARE
    user_phone TEXT;
    existing_customer_profile UUID;
    existing_partner_profile UUID;
BEGIN
    -- Get the phone number from the new user
    user_phone := NEW.phone;

    -- Check if there's a pre-created customer profile with this phone
    SELECT user_id INTO existing_customer_profile
    FROM public.customer_profiles cp
    WHERE cp.phone_number = user_phone
    AND cp.user_id IS NULL
    LIMIT 1;

    IF existing_customer_profile IS NOT NULL AND NEW.user_type = 'customer' THEN
        -- Link the profile
        UPDATE public.customer_profiles
        SET user_id = NEW.id, phone_linked_at = NOW()
        WHERE phone_number = user_phone AND user_id IS NULL;
        RETURN NEW;
    END IF;

    -- Check if there's a pre-created partner profile with this phone
    SELECT user_id INTO existing_partner_profile
    FROM public.partner_profiles pp
    WHERE pp.phone_number = user_phone
    AND pp.user_id IS NULL
    LIMIT 1;

    IF existing_partner_profile IS NOT NULL AND NEW.user_type = 'partner' THEN
        -- Link the profile
        UPDATE public.partner_profiles
        SET user_id = NEW.id, phone_linked_at = NOW()
        WHERE phone_number = user_phone AND user_id IS NULL;
        RETURN NEW;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Note: This function needs schema updates (phone_number column) or alternative lookup
```

#### Alternative: Store Phone in JSONB
Since profiles don't have a direct `phone_number` column, we'll:
1. Store phone in the `users` table when admin creates profile
2. Create user record with a temporary UUID
3. When real user signs up, match on phone and link profiles

---

## 4. Admin App Structure

### 4.1 Directory Structure
```
homegenie_admin_app/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   ├── models/
│   │   │   ├── admin_user.dart
│   │   │   ├── admin_action_log.dart
│   │   │   └── ... (reuse models from customer/partner apps)
│   │   ├── network/
│   │   │   └── admin_api_service.dart
│   │   ├── router/
│   │   │   └── admin_router.dart
│   │   └── storage/
│   ├── features/
│   │   ├── auth/
│   │   │   ├── providers/
│   │   │   └── screens/
│   │   │       ├── admin_login_screen.dart
│   │   │       └── admin_otp_screen.dart
│   │   ├── dashboard/
│   │   │   ├── providers/
│   │   │   │   └── dashboard_stats_provider.dart
│   │   │   └── screens/
│   │   │       └── admin_dashboard_screen.dart
│   │   ├── customers/
│   │   │   ├── providers/
│   │   │   │   └── customers_provider.dart
│   │   │   └── screens/
│   │   │       ├── customer_list_screen.dart
│   │   │       ├── customer_edit_screen.dart
│   │   │       └── customer_create_screen.dart
│   │   ├── partners/
│   │   │   ├── providers/
│   │   │   │   └── partners_provider.dart
│   │   │   └── screens/
│   │   │       ├── partner_list_screen.dart
│   │   │       ├── partner_edit_screen.dart
│   │   │       └── partner_create_screen.dart
│   │   └── bookings/
│   │       ├── providers/
│   │       │   └── admin_bookings_provider.dart
│   │       └── screens/
│   │           ├── booking_list_screen.dart
│   │           ├── booking_details_screen.dart
│   │           └── assign_partner_screen.dart
│   └── main.dart
├── android/
├── ios/
├── pubspec.yaml
└── README.md
```

---

## 5. Feature Implementation Details

### 5.1 Admin Dashboard (Screen 1)

#### Design Specs
- 4 stat cards in 2x2 grid:
  1. Total Active Bookings
  2. Pending Partner Verifications
  3. Total Registered Clients
  4. Total Active Partners
- Primary color: `#007AFF`
- Background: `#F5F5F5` (light), `#121212` (dark)
- Card background: `#FFFFFF` (light), `#1E1E1E` (dark)
- Font: Manrope

#### Implementation
```dart
// File: features/dashboard/screens/admin_dashboard_screen.dart
class AdminDashboardScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(dashboardStatsProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Admin Dashboard', style: Theme.of(context).textTheme.headlineLarge),
              SizedBox(height: 24),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  children: [
                    _StatCard(
                      value: stats.activeBookings,
                      label: 'Total Active Bookings',
                      onTap: () => context.push('/bookings'),
                    ),
                    _StatCard(
                      value: stats.pendingVerifications,
                      label: 'Pending Partner Verifications',
                      onTap: () => context.push('/partners?filter=pending'),
                    ),
                    _StatCard(
                      value: stats.totalClients,
                      label: 'Total Registered Clients',
                      onTap: () => context.push('/customers'),
                    ),
                    _StatCard(
                      value: stats.activePartners,
                      label: 'Total Active Partners',
                      onTap: () => context.push('/partners'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

#### Provider
```dart
// File: features/dashboard/providers/dashboard_stats_provider.dart
final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final apiService = ref.watch(adminApiServiceProvider);
  return await apiService.getDashboardStats();
});
```

### 5.2 Booking List (Screen 2)

#### Features
- Search by ID, client name, partner name
- Filter by: Status, Date Range, Client, Partner, Service
- Color-coded status badges:
  - Confirmed: Green `#28A745`
  - Pending: Yellow `#FFC107`
  - Completed: Blue `#007BFF`
  - Cancelled: Red `#DC3545`
- Each booking card shows:
  - Booking ID
  - Service name
  - Client name
  - Partner name (or "Unassigned")
  - Date and time
  - Status badge
  - "View Details" button

#### Implementation
- Reuse booking models from `homegenie_app`
- Create admin-specific provider with filters
- Implement search and filter UI

### 5.3 Booking Details (Screen 3)

#### Features
- Top app bar with back button and options menu
- Booking summary card:
  - Client Name
  - Contact Info
  - Service
  - Date & Time
  - Address
  - Special Instructions
- Expandable accordions:
  1. **Assign Partner**
     - Shows top 2 partners with ratings and distance
     - "Assign" button for each
     - "View All Partners" link → navigates to Assign Partner screen
  2. **Change Status**
     - Dropdown with status options
     - "Update Status" button
  3. **Reschedule Booking**
     - Date picker
     - Time picker
     - "Confirm Reschedule" button
  4. **Cancel Booking**
     - Warning message
     - "Confirm Cancellation" button (red)

#### Implementation Strategy
- **Reuse** the reschedule and cancel flows from `homegenie_app`
- Create admin-specific wrapper that calls the same backend functions
- Add admin action logging

### 5.4 Customer List (Screen 4)

#### Features
- Search by name, email, or phone
- Filter button (top-right)
- Each customer card shows:
  - Avatar
  - Full name
  - Email
  - Location (city)
  - Chevron right icon
- Empty state: "No users found"

#### Implementation
```dart
// File: features/customers/screens/customer_list_screen.dart
class CustomerListScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends ConsumerState<CustomerListScreen> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final customers = ref.watch(customersProvider(searchQuery));

    return Scaffold(
      appBar: AppBar(
        title: Text('Users'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () => _showFilters(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          _SearchBar(onChanged: (value) => setState(() => searchQuery = value)),
          // Customer list
          Expanded(
            child: customers.when(
              data: (list) => ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) => _CustomerCard(customer: list[index]),
              ),
              loading: () => Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/customers/create'),
        child: Icon(Icons.add),
      ),
    );
  }
}
```

### 5.5 Customer Edit/Create (Screen 5)

#### Features
- **Personal Information** section:
  - First Name (text field)
  - Last Name (text field)
  - Phone Number (text field)
- **Addresses** section:
  - List of existing addresses with edit/delete buttons
  - "Add New Address" button (dashed border)
- **Save Profile** button (blue)
- **Initiate New Booking for This User** button (green)

#### Reusable Components
- **Address management**: Reuse from `homegenie_app/features/address`
- When "Initiate New Booking" is clicked:
  - Navigate to the booking flow from `homegenie_app`
  - Pass customer_id as context
  - Admin creates booking on behalf of customer

### 5.6 Partner List (Screen 6)

#### Features
- Search by name, service, or location
- Filter chips: Service Type, Verification, Availability
- Each partner card shows:
  - Avatar
  - Name
  - Email/Phone
  - Star rating
  - Availability status (Available/Busy/Offline)
  - "View/Edit Profile" link
- Empty state: "No more partners found"

#### Implementation
- Similar to customer list
- Add verification status filter
- Color-coded availability indicators:
  - Available: Green `#2A9D8F`
  - Busy: Yellow `#E9C46A`
  - Offline: Red `#E63946`

### 5.7 Partner Edit/Create (Screen 7)

#### Features
- Profile photo upload
- **Personal Details** section:
  - First Name
  - Last Name
  - Phone Number
- **Service Preferences** section:
  - Display selected services
  - "Edit Preferences" button → **Reuse** service selection screen from partner app
- **Availability Settings** section:
  - Display current availability
  - "Manage Availability" button → **Reuse** availability screen from partner app
- **Document Uploads for Verification** section:
  - Display document status (Pending/Verified)
  - "View/Manage Documents" button → **Reuse** document upload screen from partner app
- **Save Profile** button (green)

#### Reusable Screens
1. Service preferences screen from `homegenie_partner_app`
2. Availability settings screen from `homegenie_partner_app`
3. Document verification screen from `homegenie_partner_app`

### 5.8 Assign Partner to Booking (Screen 8)

#### Features
- Search bar for partners
- Filter chips: Top Rated, Most Experienced, Available Now
- Each partner card shows:
  - Avatar with availability indicator
  - Name
  - Rating and services completed
  - Availability status
  - "Assign" button
- "View All Providers" link

#### Implementation
- Query partners based on:
  - Service type from booking
  - Location proximity
  - Availability
  - Rating
- Sort by configurable criteria
- On "Assign":
  - Update booking.partner_id
  - Create notification for partner
  - Log admin action

---

## 6. Reusable Components Strategy

### 6.1 Move to Shared Package

#### Models
Move these models to `shared/lib/models/`:
- `booking.dart`
- `service.dart`
- `address.dart`
- `user.dart`
- `partner.dart`

#### Widgets
Create `shared/lib/widgets/` with:
- `booking_flow/` - entire booking creation flow
  - `select_service_screen.dart`
  - `select_date_time_screen.dart`
  - `select_address_screen.dart`
  - `booking_checkout_screen.dart`
- `address_management/`
  - `address_form.dart`
  - `address_list.dart`
- `partner_onboarding/`
  - `service_preferences_screen.dart`
  - `availability_settings_screen.dart`
  - `document_upload_screen.dart`

### 6.2 Dependency Updates

#### `shared/pubspec.yaml`
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.4.0
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  supabase_flutter: ^2.0.0
  go_router: ^12.0.0
```

#### Update Apps to Use Shared Widgets
In `homegenie_app`, `homegenie_partner_app`, and `homegenie_admin_app`:
```yaml
dependencies:
  shared:
    path: ../shared
```

### 6.3 Navigation Strategy

Use context parameters to customize behavior:
```dart
// In shared widget
class SelectServiceScreen extends ConsumerWidget {
  final String? customerId; // null = current user, non-null = admin acting on behalf
  final Function(Service) onServiceSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If customerId is provided, admin is creating booking for customer
    // Otherwise, current user is creating their own booking
  }
}
```

---

## 7. Database Functions & Edge Functions

### 7.1 New Database Functions

#### `admin_create_customer_profile`
```sql
CREATE OR REPLACE FUNCTION public.admin_create_customer_profile(
    p_phone TEXT,
    p_first_name TEXT,
    p_last_name TEXT,
    p_email TEXT DEFAULT NULL,
    p_admin_id UUID DEFAULT auth.uid()
)
RETURNS UUID AS $$
DECLARE
    new_user_id UUID;
    existing_user_id UUID;
BEGIN
    -- Check if admin
    IF NOT public.is_admin() THEN
        RAISE EXCEPTION 'Unauthorized: Only admins can create customer profiles';
    END IF;

    -- Check if user already exists with this phone
    SELECT id INTO existing_user_id FROM public.users WHERE phone = p_phone;

    IF existing_user_id IS NOT NULL THEN
        RAISE EXCEPTION 'User with phone % already exists', p_phone;
    END IF;

    -- Create user record (without auth)
    new_user_id := gen_random_uuid();

    INSERT INTO public.users (id, phone, email, full_name, user_type)
    VALUES (new_user_id, p_phone, p_email, p_first_name || ' ' || p_last_name, 'customer');

    -- Create customer profile
    INSERT INTO public.customer_profiles (user_id, created_by_admin)
    VALUES (new_user_id, p_admin_id);

    -- Log action
    INSERT INTO public.admin_actions_log (admin_id, action_type, target_type, target_id, description)
    VALUES (p_admin_id, 'CREATE', 'customer', new_user_id, 'Created customer profile for ' || p_phone);

    RETURN new_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

#### `admin_create_partner_profile`
Similar to customer, but creates partner_profile instead.

#### `admin_create_booking`
```sql
CREATE OR REPLACE FUNCTION public.admin_create_booking(
    p_customer_id UUID,
    p_service_id UUID,
    p_scheduled_date TIMESTAMPTZ,
    p_duration_hours DECIMAL,
    p_address JSONB,
    p_payment_method payment_method,
    p_total_amount DECIMAL,
    p_special_instructions TEXT DEFAULT NULL,
    p_admin_id UUID DEFAULT auth.uid()
)
RETURNS UUID AS $$
DECLARE
    new_booking_id UUID;
BEGIN
    -- Check if admin
    IF NOT public.is_admin() THEN
        RAISE EXCEPTION 'Unauthorized: Only admins can create bookings on behalf of customers';
    END IF;

    -- Temporarily disable scheduled_date future check for admin
    -- Create booking
    INSERT INTO public.bookings (
        customer_id, service_id, scheduled_date, duration_hours,
        address, payment_method, total_amount, special_instructions
    )
    VALUES (
        p_customer_id, p_service_id, p_scheduled_date, p_duration_hours,
        p_address, p_payment_method, p_total_amount, p_special_instructions
    )
    RETURNING id INTO new_booking_id;

    -- Log action
    INSERT INTO public.admin_actions_log (admin_id, action_type, target_type, target_id, description)
    VALUES (p_admin_id, 'CREATE', 'booking', new_booking_id, 'Created booking for customer');

    RETURN new_booking_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

#### `admin_assign_partner_to_booking`
```sql
CREATE OR REPLACE FUNCTION public.admin_assign_partner_to_booking(
    p_booking_id UUID,
    p_partner_id UUID,
    p_admin_id UUID DEFAULT auth.uid()
)
RETURNS BOOLEAN AS $$
BEGIN
    -- Check if admin
    IF NOT public.is_admin() THEN
        RAISE EXCEPTION 'Unauthorized';
    END IF;

    -- Update booking
    UPDATE public.bookings
    SET partner_id = p_partner_id, status = 'confirmed', updated_at = NOW()
    WHERE id = p_booking_id;

    -- Create notification for partner
    INSERT INTO public.notifications (user_id, type, title, body, data)
    VALUES (
        p_partner_id,
        'booking_assigned',
        'New Booking Assigned',
        'You have been assigned a new booking by admin',
        jsonb_build_object('booking_id', p_booking_id)
    );

    -- Log action
    INSERT INTO public.admin_actions_log (admin_id, action_type, target_type, target_id, description)
    VALUES (p_admin_id, 'ASSIGN_PARTNER', 'booking', p_booking_id, 'Assigned partner to booking');

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

#### `get_dashboard_stats`
```sql
CREATE OR REPLACE FUNCTION public.get_dashboard_stats()
RETURNS TABLE (
    active_bookings BIGINT,
    pending_verifications BIGINT,
    total_clients BIGINT,
    active_partners BIGINT
) AS $$
BEGIN
    -- Check if admin
    IF NOT public.is_admin() THEN
        RAISE EXCEPTION 'Unauthorized';
    END IF;

    RETURN QUERY
    SELECT
        (SELECT COUNT(*) FROM public.bookings WHERE status IN ('pending', 'confirmed', 'in_progress')) AS active_bookings,
        (SELECT COUNT(*) FROM public.partner_profiles WHERE verification_status = 'pending') AS pending_verifications,
        (SELECT COUNT(*) FROM public.users WHERE user_type = 'customer') AS total_clients,
        (SELECT COUNT(*) FROM public.partner_profiles WHERE verification_status = 'verified') AS active_partners;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### 7.2 Edge Functions

All existing edge functions can be reused. Admin will call them through the API service with admin permissions.

---

## 8. Testing Strategy

### 8.1 Database Testing
1. Test admin RLS policies
2. Test profile linking on signup
3. Test admin function permissions
4. Test constraint validations

### 8.2 App Testing
1. Test admin login flow
2. Test customer creation and linking
3. Test partner creation and linking
4. Test booking creation on behalf of customer
5. Test partner assignment
6. Test navigation between reused screens

### 8.3 Integration Testing
1. Create customer via admin → Customer signs up → Verify profile linked
2. Create partner via admin → Partner signs up → Verify profile linked
3. Create booking via admin → Assign partner → Partner sees booking
4. Modify booking status via admin → Verify customer sees update

---

## 9. Implementation Timeline

### Phase 1: Database & Backend (3-4 days)
- [ ] Create new tables (`admin_users`, `admin_actions_log`)
- [ ] Update schema (add `created_by_admin` columns)
- [ ] Create admin RLS policies
- [ ] Create admin database functions
- [ ] Test database changes thoroughly
- [ ] Create migration scripts

### Phase 2: Shared Package Refactoring (2-3 days)
- [ ] Move models to `shared/lib/models/`
- [ ] Move booking flow screens to `shared/lib/widgets/booking_flow/`
- [ ] Move address widgets to `shared/lib/widgets/address/`
- [ ] Move partner onboarding screens to `shared/lib/widgets/partner_onboarding/`
- [ ] Update customer and partner apps to use shared components
- [ ] Test existing apps to ensure nothing breaks

### Phase 3: Admin App Foundation (2 days)
- [ ] Create `homegenie_admin_app` Flutter project
- [ ] Set up folder structure
- [ ] Configure dependencies (Riverpod, GoRouter, Supabase)
- [ ] Implement theme matching designs
- [ ] Create admin API service
- [ ] Implement admin auth flow (login + OTP)

### Phase 4: Admin Features - Dashboard & Bookings (3-4 days)
- [ ] Admin Dashboard screen with stats cards
- [ ] Booking List screen with search and filters
- [ ] Booking Details screen with accordions
- [ ] Assign Partner screen
- [ ] Implement booking status change
- [ ] Implement booking reschedule (reuse from customer app)
- [ ] Implement booking cancellation (reuse from customer app)
- [ ] Test booking management flows

### Phase 5: Admin Features - Customers (2 days)
- [ ] Customer List screen with search
- [ ] Customer Create/Edit screen
- [ ] Integrate address management (reuse from customer app)
- [ ] Implement "Initiate New Booking" (reuse booking flow)
- [ ] Test customer management flows

### Phase 6: Admin Features - Partners (3 days)
- [ ] Partner List screen with filters
- [ ] Partner Create/Edit screen
- [ ] Integrate service preferences screen (reuse from partner app)
- [ ] Integrate availability settings (reuse from partner app)
- [ ] Integrate document upload (reuse from partner app)
- [ ] Test partner management flows

### Phase 7: Testing & Polish (2-3 days)
- [ ] End-to-end testing of all admin flows
- [ ] Test profile linking scenarios
- [ ] Fix bugs and edge cases
- [ ] UI polish and responsive design
- [ ] Performance optimization

### Phase 8: Documentation & Deployment (1 day)
- [ ] Update README files
- [ ] Create admin user guide
- [ ] Deploy database migrations to production
- [ ] Create first admin user manually
- [ ] Deploy admin app for testing

**Total Estimated Timeline: 18-22 days**

---

## 10. Risk Analysis & Mitigation

### Risk 1: Profile Linking Failure
**Risk**: User signs up but profile doesn't link correctly
**Mitigation**:
- Thorough testing of linking logic
- Add fallback manual linking function for admins
- Implement monitoring and alerts

### Risk 2: RLS Policy Bypass Issues
**Risk**: Admin policies might conflict with existing policies
**Mitigation**:
- Test all policy combinations
- Use `SECURITY DEFINER` functions for admin operations
- Add comprehensive audit logging

### Risk 3: Shared Package Breaking Changes
**Risk**: Moving code to shared package might break existing apps
**Mitigation**:
- Create comprehensive test suite before refactoring
- Make changes incrementally
- Keep backup of working versions

### Risk 4: Data Integrity Issues
**Risk**: Admin creating invalid bookings or profiles
**Mitigation**:
- Maintain all database constraints
- Implement validation in admin app
- Use transactions for multi-step operations
- Log all admin actions

### Risk 5: Authorization Bypass
**Risk**: Non-admin users accessing admin features
**Mitigation**:
- Check admin status on every API call
- Use RLS policies as second layer of defense
- Implement session validation
- Regular security audits

---

## Appendix A: Database Schema Diagram

```
┌─────────────────┐
│   auth.users    │ (Supabase managed)
└────────┬────────┘
         │
         ├──────────────────────────────────────────┐
         │                                          │
         ▼                                          ▼
┌─────────────────┐                        ┌─────────────────┐
│     users       │                        │  admin_users    │
├─────────────────┤                        ├─────────────────┤
│ id (PK)         │◄───────────────────────┤ user_id (PK,FK) │
│ phone           │                        │ role            │
│ email           │                        │ permissions     │
│ full_name       │                        └─────────────────┘
│ user_type       │
│ (customer/      │
│  partner/admin) │
└────────┬────────┘
         │
         ├──────────────────┬──────────────────┐
         ▼                  ▼                  ▼
┌──────────────────┐ ┌──────────────────┐ ┌──────────────────┐
│customer_profiles │ │partner_profiles  │ │    bookings      │
├──────────────────┤ ├──────────────────┤ ├──────────────────┤
│ user_id (PK,FK)  │ │ user_id (PK,FK)  │ │ id (PK)          │
│ addresses        │ │ verification_st.. │ │ customer_id (FK) │
│ preferences      │ │ services         │ │ partner_id (FK)  │
│ created_by_admin │ │ availability     │ │ service_id (FK)  │
│ phone_linked_at  │ │ rating           │ │ status           │
└──────────────────┘ │ created_by_admin │ │ scheduled_date   │
                     │ phone_linked_at  │ │ address          │
                     └──────────────────┘ └──────────────────┘
```

---

## Appendix B: API Endpoints Summary

### Admin Auth
- `POST /auth/admin-login` - Send OTP to admin phone
- `POST /auth/admin-verify-otp` - Verify OTP and login

### Dashboard
- `GET /admin/dashboard/stats` - Get dashboard statistics

### Customers
- `GET /admin/customers` - List all customers (with pagination, search, filters)
- `GET /admin/customers/:id` - Get customer details
- `POST /admin/customers` - Create customer profile
- `PUT /admin/customers/:id` - Update customer profile
- `DELETE /admin/customers/:id` - Delete customer (soft delete)

### Partners
- `GET /admin/partners` - List all partners (with pagination, search, filters)
- `GET /admin/partners/:id` - Get partner details
- `POST /admin/partners` - Create partner profile
- `PUT /admin/partners/:id` - Update partner profile
- `PUT /admin/partners/:id/verification` - Update verification status

### Bookings
- `GET /admin/bookings` - List all bookings (with pagination, search, filters)
- `GET /admin/bookings/:id` - Get booking details
- `POST /admin/bookings` - Create booking on behalf of customer
- `PUT /admin/bookings/:id` - Update booking
- `PUT /admin/bookings/:id/status` - Change booking status
- `PUT /admin/bookings/:id/assign-partner` - Assign partner to booking
- `PUT /admin/bookings/:id/reschedule` - Reschedule booking
- `POST /admin/bookings/:id/cancel` - Cancel booking

### Admin Actions
- `GET /admin/actions-log` - Get admin action history

---

## Appendix C: Color Palette

### Primary Colors
- Primary Blue: `#007AFF` / `#007BFF`
- Success Green: `#28A745` / `#2A9D8F` / `#04ae73`
- Warning Yellow: `#FFC107` / `#E9C46A`
- Danger Red: `#DC3545` / `#E63946`
- Info Blue: `#007BFF`

### Neutral Colors
- Background Light: `#F5F5F5` / `#F8F9FA` / `#F0F2F5`
- Background Dark: `#121212` / `#1a1a1a` / `#0f231c`
- Card Light: `#FFFFFF`
- Card Dark: `#1E1E1E` / `#2c2c2c`
- Text Light: `#333333` / `#343A40`
- Text Dark: `#E0E0E0` / `#F5F5F5`
- Secondary Text: `#6C757D` / `#757575`

### Status Colors
- Confirmed: `#28A745` (green)
- Pending: `#FFC107` (yellow)
- Completed: `#007BFF` (blue)
- Cancelled: `#DC3545` (red)
- In Progress: `#17A2B8` (teal)

---

## Conclusion

This implementation plan provides a comprehensive roadmap for building the HomeGenie Admin App. The key aspects are:

1. **Database-first approach**: Establish solid foundation with proper RLS policies and admin functions
2. **Code reusability**: Maximize shared components to maintain consistency and reduce duplication
3. **Profile linking**: Seamless integration when users sign up after admin creates their profiles
4. **Design fidelity**: Pixel-perfect implementation of provided designs
5. **Security**: Proper authorization checks at all levels
6. **Auditability**: Complete logging of all admin actions

The plan is thorough, actionable, and designed to be executed systematically without leaving anything for later. Each phase builds on the previous one, ensuring a stable and feature-complete admin application.
