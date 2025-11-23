# Safety Demo App - Final Project

A comprehensive Flutter safety application demonstrating advanced technical concepts including native integration, encryption, local persistence, and Firebase integration.

## 🎯 Project Overview

This app demonstrates:
- **Native Integration**: MethodChannel communication with Android (Kotlin) for panic button detection
- **Secure Communication**: End-to-end encrypted local chat using AES-256
- **Complex Database Schema**: Local persistence with Hive (NoSQL)
- **Incident Mapping**: Geolocation services with privacy-preserving fuzzing
- **Firebase Integration**: Authentication and cloud services
- **Mock API Integration**: HTTP requests to external services

## 📋 Features

### Core Features
1. **Panic Button Trigger**
   - Native Android volume button detection (3 rapid presses)
   - Automatic location capture
   - Background alert processing

2. **Encrypted Chat**
   - AES-256 encryption for messages
   - Local storage with Hive
   - Real-time UI updates
   - Toggle between encrypted/decrypted view

3. **Incident Mapping**
   - Static map visualization
   - Real-time location tracking
   - Coordinate fuzzing for privacy
   - Incident persistence

4. **Firebase Authentication**
   - Email/password authentication
   - Secure session management
   - User profile integration

5. **Dashboard**
   - Quick action cards
   - Recent alerts display
   - Emergency resources from API
   - Incident history

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Firebase project (for authentication)
- Android device/emulator (for native features)

### Installation

1. **Clone the repository**
   ```bash
   cd safety_demo
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Add Android app to Firebase project
   - Download `google-services.json` and place it in `android/app/`
   - Enable Email/Password authentication in Firebase Console
   - **Generate firebase_options.dart**:
     ```bash
     # Option 1: Use FlutterFire CLI (recommended)
     dart pub global activate flutterfire_cli
     flutterfire configure
     
     # Option 2: Copy template and fill in values
     cp lib/firebase_options.dart.template lib/firebase_options.dart
     # Then edit firebase_options.dart with your Firebase credentials
     ```
   - **Note**: `firebase_options.dart` is in `.gitignore` to protect API keys. See `SECURITY.md` for details.

4. **Android Configuration**
   - Location permissions are already configured in `AndroidManifest.xml`
   - Minimum SDK: 21 (Android 5.0)
   - Target SDK: 34 (Android 14)

5. **Optional: Add Map Image**
   - Place a static map image at `assets/images/mock_map.png`
   - Or use the grid-based mock map (default)

### Running the App

```bash
# Run on connected device/emulator
flutter run

# Run in release mode
flutter run --release

# Build APK
flutter build apk
```

## 📱 Demo Scenario

### Step 1: Authentication
1. Launch the app
2. Create an account or sign in with existing credentials
3. You'll be redirected to the dashboard

### Step 2: Test Panic Button
**Method 1: Volume Button**
- Press volume up/down button 3 times rapidly (within 2 seconds)
- App will trigger panic mode

**Method 2: Test Button**
- Navigate to Panic screen from dashboard
- Tap "Test Panic Button"

**Method 3: Auto Demo**
- Wait 5 seconds after app launch (built-in demo trigger)

### Step 3: Safety Mode
- After panic trigger:
  - Location is automatically captured
  - Alert is saved to local database
  - Safety Mode screen appears
  - Shows real and fuzzed location coordinates

### Step 4: Encrypted Chat
1. Navigate to Chat screen
2. Type a message and send
3. Message is encrypted before storage
4. Toggle lock icon to view encrypted ciphertext vs decrypted plaintext
5. Messages persist after app restart

### Step 5: Incident Map
1. Navigate to Map screen
2. Grant location permissions when prompted
3. View your current location (blue marker)
4. Tap "Report Incident" to create a new incident
5. View incident markers on the map (using fuzzed coordinates)
6. Tap markers to see incident details

### Step 6: Dashboard Features
- View recent alerts
- Access emergency resources (fetched from mock API)
- Quick navigation to all features
- View incident history

## 🏗️ Project Structure

```
safety_demo/
├── android/
│   └── app/
│       └── src/main/
│           ├── kotlin/com/example/safety_demo/
│           │   └── MainActivity.kt          # Native panic trigger
│           └── AndroidManifest.xml          # Permissions
├── lib/
│   ├── main.dart                            # App entry, routing
│   ├── panic_handler.dart                   # Panic button handler
│   ├── models/
│   │   ├── alert_model.dart                 # Alert data model
│   │   ├── chat_message_model.dart         # Chat message model
│   │   └── incident_model.dart              # Incident model
│   ├── services/
│   │   ├── location_service.dart            # Geolocation service
│   │   ├── encryption_service.dart          # AES encryption
│   │   ├── alert_repository.dart            # Alert storage
│   │   ├── chat_repository.dart             # Chat storage
│   │   ├── incident_repository.dart         # Incident storage
│   │   └── mock_api_service.dart            # API integration
│   └── screens/
│       ├── auth_screen.dart                  # Firebase auth
│       ├── dashboard_screen.dart            # Main dashboard
│       ├── safety_mode_screen.dart          # Emergency screen
│       ├── chat_screen.dart                 # Encrypted chat
│       └── incident_map_screen.dart         # Map visualization
├── assets/
│   └── images/                              # Static map image (optional)
└── pubspec.yaml                             # Dependencies
```

## 🔧 Technical Implementation

### Native Integration (MethodChannel)
- **Platform**: Android (Kotlin)
- **Channel**: `com.example.safety_demo/panic_channel`
- **Trigger**: Volume button press detection
- **Communication**: Native → Flutter (panicTriggered method)

### Encryption
- **Algorithm**: AES-256
- **Library**: `encrypt` package (uses pointycastle)
- **Key Management**: Static demo key (replace in production)
- **IV**: Random 16-byte IV per message

### Local Persistence
- **Database**: Hive (NoSQL)
- **Boxes**: 
  - `alerts` - Alert records
  - `chat_messages` - Encrypted messages
  - `incidents` - Incident reports
- **Adapters**: Type-safe Hive adapters for all models

### Location Services
- **Package**: `geolocator`
- **Permissions**: Fine & coarse location
- **Features**: 
  - Current location
  - Last known location
  - Location fuzzing (privacy)

### Firebase Integration
- **Auth**: Email/password authentication
- **Services**: Firebase Core, Auth, Firestore (configured)
- **Session**: Persistent authentication state

### API Integration
- **Service**: `mock_api_service.dart`
- **Endpoint**: JSONPlaceholder (demo API)
- **Features**: 
  - Emergency resources
  - Safety tips
  - Incident reporting

## 📦 Dependencies

### Core
- `flutter` - Flutter SDK
- `firebase_core` - Firebase initialization
- `firebase_auth` - Authentication
- `geolocator` - Location services
- `hive` / `hive_flutter` - Local database
- `encrypt` - Encryption library
- `http` - HTTP requests

### Development
- `build_runner` - Code generation
- `hive_generator` - Hive adapter generation
- `flutter_lints` - Linting rules

## 🔐 Security Notes

### Firebase API Keys
- **Client-side keys are safe to expose** (they're public by design)
- `firebase_options.dart` is in `.gitignore` to prevent committing keys
- Use `firebase_options.dart.template` as a starting point
- See `SECURITY.md` for detailed security information

### Current Implementation (Demo)
- Static encryption key (for demonstration)
- Local-only storage
- No server-side validation

### Production Recommendations
1. **Key Management**
   - Derive encryption key from user credentials
   - Use secure storage (flutter_secure_storage)
   - Implement key rotation

2. **Authentication**
   - Add 2FA support
   - Implement session timeout
   - Add biometric authentication

3. **Data Protection**
   - Encrypt database at rest
   - Implement secure backup
   - Add data export functionality

4. **Network Security**
   - Use HTTPS only
   - Implement certificate pinning
   - Add request signing

## 🧪 Testing

### Manual Testing Checklist
- [ ] App launches successfully
- [ ] Firebase authentication works
- [ ] Panic trigger (volume button/test button)
- [ ] Location permission request
- [ ] Alert creation and storage
- [ ] Safety Mode screen navigation
- [ ] Chat encryption/decryption
- [ ] Message persistence
- [ ] Map display and markers
- [ ] Incident creation
- [ ] API resource fetching
- [ ] Dashboard navigation
- [ ] Sign out functionality

### Unit Testing (Future)
```bash
flutter test
```

## 🐛 Known Issues & Limitations

1. **Map Image**: Static map image not included (uses grid fallback)
2. **Encryption Key**: Static demo key (not production-ready)
3. **API**: Uses mock API (JSONPlaceholder)
4. **Offline Mode**: Limited offline functionality
5. **Error Handling**: Basic error handling (needs improvement)

## 🚧 Future Enhancements

### Short Term
- [ ] Add unit tests
- [ ] Improve error handling
- [ ] Add loading states
- [ ] Enhance UI/UX
- [ ] Add animations

### Long Term
- [ ] Real-time sync with Firebase
- [ ] Push notifications
- [ ] Biometric authentication
- [ ] Offline-first architecture
- [ ] Multi-language support
- [ ] Dark mode
- [ ] Widget tests
- [ ] Integration tests

## 📝 Deployment

### Android Release Build
```bash
# Build release APK
flutter build apk --release

# Build app bundle (for Play Store)
flutter build appbundle --release
```

### Configuration
1. Update `android/app/build.gradle.kts` with signing config
2. Update version in `pubspec.yaml`
3. Configure ProGuard rules (if needed)
4. Test on physical devices

## 📄 License

This project is created for educational/demonstration purposes.

## 👤 Author

PLP Academy - Dart Specialization Final Project

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- Hive for local persistence
- All package maintainers

---

**Status**: ✅ All Saturday and Sunday tasks completed!

For detailed implementation notes, see `IMPLEMENTATION_SUMMARY.md`
