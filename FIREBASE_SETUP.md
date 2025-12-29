# Firebase Configuration Guide

This guide will help you set up Firebase for the Darna app.

## 📋 Prerequisites

- Firebase account
- Flutter SDK installed
- FlutterFire CLI (`dart pub global activate flutterfire_cli`)

## 🔥 Step-by-Step Setup

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: `darnaa` (or your choice)
4. Enable Google Analytics (optional)
5. Create project

### 2. Enable Firebase Services

#### Authentication
1. Navigate to **Authentication** → **Sign-in method**
2. Enable **Email/Password**
3. Save

#### Cloud Firestore
1. Navigate to **Firestore Database**
2. Click **Create database**
3. Choose **Production mode**
4. Select region closest to your users
5. Click **Enable**

#### Firebase Storage
1. Navigate to **Storage**
2. Click **Get started**
3. Use default security rules
4. Select same region as Firestore
5. Click **Done**

### 3. Add Apps to Firebase

#### Android App
1. Click **Add app** → **Android**
2. Package name: `com.darna.app`
3. Download `google-services.json`
4. Place in `android/app/`

#### iOS App
1. Click **Add app** → **iOS**
2. Bundle ID: `com.darna.app`
3. Download `GoogleService-Info.plist`
4. Place in `ios/Runner/`

### 4. Configure Firestore Security Rules

Copy these rules to Firestore Rules tab:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Products - anyone can read, only admins can write
    match /products/{productId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Users - users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Drivers - authenticated users can read, drivers/admins can write
    match /drivers/{driverId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        (request.auth.uid == driverId || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
    
    // Orders - authenticated users can read/write
    match /orders/{orderId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

Publish the rules.

### 5. Configure Firebase Storage Rules

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    
    // Profile pictures
    match /profile_pictures/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Product images
    match /product_images/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role  == 'admin';
    }
  }
}
```

### 6. Run FlutterFire Configuration

```bash
flutterfire configure
```

This will:
- Generate `lib/firebase_options.dart`
- Configure all platforms
- Link your Firebase project

### 7. Google Maps API Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Enable **Maps SDK for Android**
3. Enable **Maps SDK for iOS**
4. Create API key with restrictions
5. Add key to:
   - `android/app/src/main/AndroidManifest.xml`
   - `ios/Runner/AppDelegate.swift`

### 8. Test Your Setup

```bash
flutter run
```

If everything is set up correctly:
- ✅ App launches without errors
- ✅ Can sign up/login
- ✅ Products load from Firestore
- ✅ Maps display correctly

## 🔒 Security Best Practices

- Never commit API keys to Git
- Use environment variables for sensitive data
- Restrict API keys to specific apps
- Enable Firebase App Check for production
- Regularly review Firestore rules

## ❓ Troubleshooting

### "Default FirebaseApp is not initialized"
- Make sure `Firebase.initializeApp()` is called in `main.dart`
- Check `google-services.json` placement

### "Permission denied" in Firestore
- Review and update security rules
- Check user authentication status

### Maps not displaying
- Verify API key is correct
- Check API key restrictions
- Ensure Maps SDK is enabled

## 📚 Additional Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Google Maps Flutter Plugin](https://pub.dev/packages/google_maps_flutter)

---

For more help, open an issue or check existing documentation!
