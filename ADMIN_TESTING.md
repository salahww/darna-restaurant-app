# Admin Dashboard Testing Guide

## Setup Instructions

### 1. Create Admin User
Run the setup script to create test accounts:

```bash
flutter run lib/setup_admin.dart
```

This will create:
- **Admin**: `admin@darna.com` / `Admin123!`
- **Driver**: `driver@darna.com` / `Driver123!`

### 2. Test Admin Dashboard

#### Login as Admin
1. Sign out if currently logged in
2. Login with: `admin@darna.com` / `Admin123!`
3. App will automatically route to Admin Dashboard

#### Features to Test

**Dashboard Tab:**
- ✅ View statistics cards (Today's Orders, Active Orders, Revenue)
- ✅ See live orders feed
- ✅ Confirm/Reject pending orders
- ✅ Auto-assign driver to confirmed orders
- ✅ View order status updates

**Products Tab:**
- ✅ View all products
- ✅ Toggle product availability
- ✅ Click "Add Product" button
- ✅ Fill English name & description
- ✅ Click "Auto-Translate to French" button
- ✅ Verify French translation appears
- ✅ Save product

### 3. Test Driver Assignment

1. Create a test order as customer
2. Login as admin
3. Go to Dashboard tab
4. Find the pending order
5. Click "Confirm & Assign"
6. Verify driver is automatically assigned

### 4. Test Product Translation

1. Login as admin
2. Go to Products tab
3. Click "+ Add Product"
4. Enter:
   - Name (EN): "Grilled Chicken"
   - Description (EN): "Tender chicken grilled to perfection"
5. Click "Auto-Translate to French"
6. Verify French fields populate:
   - Name (FR): "Poulet Grillé"
   - Description (FR): "Poulet tendre grillé à la perfection"

## Known Issues

- **132 linting warnings** (all minor, mostly `avoid_print`)
- Hot reload should work for UI changes
- May need full restart for role routing changes

## Next Steps

After testing Phase 1:
- **Phase 2**: Driver Dashboard
- **Phase 3**: Customer Tracking with real-time driver location
