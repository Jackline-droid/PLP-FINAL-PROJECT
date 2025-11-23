# Security Notes

## Firebase API Keys

The `firebase_options.dart` file contains Firebase API keys that are flagged by security scanners. 

### Important: These are Client-Side Keys

Firebase API keys in `firebase_options.dart` are **client-side keys** that are:
- ✅ **Safe to expose** in client applications
- ✅ **Restricted by domain/app ID** in Firebase Console
- ✅ **Public by design** (they're included in compiled apps)

### Security Best Practices

1. **API Key Restrictions**: Configure restrictions in Firebase Console:
   - Go to Firebase Console → Project Settings → API Keys
   - Add HTTP referrer restrictions for web keys
   - Add Android app restrictions for Android keys
   - Add iOS bundle ID restrictions for iOS keys

2. **Firebase Security Rules**: Always configure proper security rules:
   - Firestore: Restrict read/write access
   - Storage: Restrict upload/download access
   - Authentication: Use proper validation

3. **For This Project**:
   - `firebase_options.dart` is in `.gitignore` to prevent committing real keys
   - Use `firebase_options.dart.template` as a starting point
   - Generate your own using `flutterfire configure`

## Setup Instructions

### Option 1: Use FlutterFire CLI (Recommended)
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

### Option 2: Manual Setup
1. Copy `firebase_options.dart.template` to `firebase_options.dart`
2. Replace placeholder values with your Firebase project credentials
3. Get credentials from Firebase Console → Project Settings

## Rotating Exposed Keys

If your keys have been exposed and you want to rotate them:

1. **Firebase Console**:
   - Go to Project Settings → General
   - Under "Your apps", find your app
   - Click "Add fingerprint" or regenerate credentials

2. **Update the App**:
   - Run `flutterfire configure` again
   - Or manually update `firebase_options.dart`

3. **Update Restrictions**:
   - Configure API key restrictions in Firebase Console
   - Update app IDs if needed

## Notes for Production

- ✅ Client-side API keys are safe to include in apps
- ✅ Use Firebase Security Rules for data protection
- ✅ Enable App Check for additional security
- ✅ Monitor usage in Firebase Console
- ❌ Never expose server-side keys or service account keys

---

**For this demo project**: The keys in the repository are for demonstration purposes only. For production, always use your own Firebase project with properly configured restrictions.

