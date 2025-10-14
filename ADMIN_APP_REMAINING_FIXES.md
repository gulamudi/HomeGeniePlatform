# Admin App Remaining Fixes

## Completed ✅
1. **Phone Number Format** - Added +91 prefix normalization in both partner and customer creation
2. **Auto-refresh on Dashboard** - Changed provider to `autoDispose` so data refreshes on page navigation
3. **Pull-to-refresh on Dashboard** - Added RefreshIndicator to dashboard

## Remaining Fixes Needed

### 1. Fix "Initiate New Booking" Button (customer_edit_screen.dart:227-244)
**Current Issue**: Button does nothing
**Solution**: Navigate to a booking creation screen with customer pre-selected
```dart
ElevatedButton(
  onPressed: () {
    context.push('/bookings/create?customerId=${widget.customerId}');
  },
  child: const Text('Initiate New Booking for This User'),
)
```

### 2. Add Partner Verification Controls (partner_edit_screen.dart)
**Current Issue**: No way to verify partners from edit screen
**Solution**: Add verification status dropdown and approve/reject buttons
- Add verification status field
- Add approve/reject buttons
- Call API to update verification status

### 3. Implement Edit Preferences (partner_edit_screen.dart:221-234)
**Current Issue**: Button placeholder, no functionality
**Solution**: Navigate to service selection screen or show dialog
- Reuse service selection components from partner app
- Allow multi-select of services
- Update partner_profiles.services array

### 4. Implement Manage Availability (partner_edit_screen.dart:260-275)
**Current Issue**: Button placeholder, no functionality
**Solution**: Navigate to availability management screen
- Reuse availability components from partner app (partner_availability table)
- Allow setting weekly schedules
- Save to partner_availability table

### 5. Implement View/Manage Documents (partner_edit_screen.dart:346-361)
**Current Issue**: Button placeholder, no functionality
**Solution**: Navigate to document management screen
- Show uploaded documents
- Allow viewing/downloading
- Allow uploading new documents
- Update verification status based on documents

### 6. Fix Partner Filters (partner_list_screen.dart)
**Current Issue**: Filters not working
**Solution**: Check the filter implementation
- Ensure search query is passed to provider
- Ensure provider filters properly
- Add status filter (verified/pending/rejected)

### 7. Fix Partner Assignment in Booking Details (assign_partner_screen.dart)
**Current Issue**: No partners showing even with "view all"
**Solution**: Debug the getAvailablePartners API call
- Check if API is being called
- Check if partners exist in database
- Fix any query issues
- Ensure proper display in UI

### 8. Add Pull-to-Refresh to List Pages
**Locations**:
- `partner_list_screen.dart`
- `customer_list_screen.dart`
- `booking_list_screen.dart`

**Solution**: Wrap ListView/GridView with RefreshIndicator
```dart
RefreshIndicator(
  onRefresh: () async {
    ref.invalidate(providerName);
    await Future.delayed(const Duration(milliseconds: 500));
  },
  child: ListView(...),
)
```

## Implementation Priority

1. **HIGH**: Fix partner filters and partner assignment (core functionality)
2. **HIGH**: Add pull-to-refresh to all list screens (UX improvement)
3. **MEDIUM**: Implement booking creation from customer edit
4. **MEDIUM**: Add partner verification controls
5. **LOW**: Implement Edit Preferences/Availability/Documents (can be done incrementally)

## Notes
- Most components can be copied from the partner app (`homegenie_app`)
- Use existing Riverpod providers where possible
- Test each fix thoroughly before moving to next
