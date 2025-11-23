# Quick Setup Guide

## 🚀 Fast Track Setup (5 minutes)

### 1. Install Dependencies
```bash
cd safety_demo
flutter pub get
```

### 2. Firebase Configuration
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project (or use existing)
3. Add Android app with package name: `com.example.safety_demo`
4. Download `google-services.json`
5. Place it in `android/app/` directory
6. Enable **Email/Password** authentication in Firebase Console → Authentication

### 3. Run the App
```bash
flutter run
```

## 📱 Testing the Demo

### Quick Test Flow (2 minutes)

1. **Authentication**
   - Create account with any email/password (min 6 chars)
   - Sign in

2. **Panic Button**
   - Tap "Panic" card on dashboard
   - Tap "Test Panic Button"
   - OR: Press volume button 3 times quickly
   - Safety Mode screen appears

3. **Chat Encryption**
   - Tap "Chat" card
   - Type a message and send
   - Toggle lock icon to see encrypted vs decrypted

4. **Map**
   - Tap "Map" card
   - Grant location permission
   - Tap "Report Incident" to create marker
   - Tap marker to see details

5. **API Resources**
   - Scroll dashboard to see emergency resources
   - Resources fetched from mock API

## 🎯 Demo Scenario Script

**For Presentation/Demo:**

1. **Introduction** (30 sec)
   - "This app demonstrates advanced Flutter concepts: native integration, encryption, local persistence, and Firebase"

2. **Native Integration** (1 min)
   - Show volume button trigger
   - Explain MethodChannel communication
   - Show Safety Mode screen

3. **Encryption** (1 min)
   - Open chat
   - Send message
   - Toggle to show encrypted ciphertext
   - Explain AES-256 encryption

4. **Location & Mapping** (1 min)
   - Show map screen
   - Demonstrate location fuzzing
   - Show incident markers

5. **Firebase & API** (30 sec)
   - Show authentication
   - Show API resources on dashboard

**Total: ~4 minutes**

## 🔧 Troubleshooting

### Firebase Auth Not Working
- Check `google-services.json` is in `android/app/`
- Verify Email/Password auth is enabled in Firebase Console
- Check internet connection

### Location Not Working
- Grant location permissions when prompted
- Enable location services on device/emulator
- Check AndroidManifest.xml has permissions

### Panic Button Not Triggering
- Use test button for guaranteed trigger
- Volume button requires physical device (not emulator)
- Check MainActivity.kt for trigger logic

### Map Shows Grid Instead of Image
- This is normal! Grid is the fallback
- To add custom map: Place image at `assets/images/mock_map.png`
- Update coordinate bounds in `incident_map_screen.dart` if needed

## 📝 Notes for Deployment

### Before Production:
1. Replace static encryption key with secure key derivation
2. Update API endpoints to real services
3. Add proper error handling
4. Configure app signing
5. Test on multiple devices
6. Add analytics/monitoring
7. Implement proper backup/restore

### Build Commands:
```bash
# Debug APK
flutter build apk

# Release APK
flutter build apk --release

# App Bundle (Play Store)
flutter build appbundle --release
```

## ✅ Verification Checklist

Before demo/presentation:
- [ ] App launches without errors
- [ ] Firebase auth works (sign up/in)
- [ ] Panic button triggers (test button works)
- [ ] Location permission requested
- [ ] Chat encrypts/decrypts messages
- [ ] Map displays with markers
- [ ] Dashboard shows resources
- [ ] No console errors

---

**Ready to demo!** 🎉

