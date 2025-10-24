# Production Readiness Guide

This guide covers all steps needed to prepare the Student Notifier app for production deployment.

## ✅ Completed Tasks

### 1. Debug Logging Cleanup
- ✅ Created `AppLogger` utility class in `lib/utils/app_logger.dart`
- ✅ Replaced all `print()` statements (12 occurrences) with `AppLogger` calls
- ✅ Replaced all `debugPrint()` statements (20+ occurrences) with `AppLogger` calls
- ✅ Logs are automatically disabled in production builds
- ✅ Removed unnecessary TODO comments from signup_screen.dart
- ✅ Files updated:
  - user_cubit.dart
  - profile_screen.dart
  - socket_service.dart
  - auth_service.dart
  - class_service.dart
  - student_service.dart
  - notification_service.dart

### 2. Environment Configuration
- ✅ Created `lib/config/environment.dart` with Environment enum
- ✅ Supports both development and production environments
- ✅ Updated `lib/config/api_config.dart` to use environment configuration
- ✅ Easy switching between environments (single constant change)

**To switch to production:** Change `Environment.current` in `environment.dart`:
```dart
static const Environment current = Environment.production;
```

### 3. Debug Banner
- ✅ Already disabled: `debugShowCheckedModeBanner: false` in main.dart

---

## 🔧 TODO: App Branding & Identifiers

### Current State
- Package name: `com.example.students`
- App name: `students`
- Version: `1.0.0+1`

### Required Changes

#### 1. Update Package Name (Android)
**File:** `android/app/build.gradle.kts`
```kotlin
defaultConfig {
    applicationId = "com.yourcompany.studentnotifier"  // Change this
    minSdk = 21  // Recommended minimum
    targetSdk = 34  // Latest Android version
    versionCode = 1
    versionName = "1.0.0"
}
```

#### 2. Update App Display Name
**File:** `android/app/src/main/AndroidManifest.xml`
```xml
<application
    android:label="Student Notifier"  <!-- Change from "students" -->
```

#### 3. Update iOS Bundle Identifier (if supporting iOS)
**File:** `ios/Runner.xcodeproj/project.pbxproj`
Search and replace: `com.example.students` → `com.yourcompany.studentnotifier`

**File:** `ios/Runner/Info.plist`
```xml
<key>CFBundleDisplayName</key>
<string>Student Notifier</string>
<key>CFBundleIdentifier</key>
<string>com.yourcompany.studentnotifier</string>
```

#### 4. Update pubspec.yaml
**File:** `pubspec.yaml`
```yaml
name: student_notifier
description: "Student attendance notification system for schools"
version: 1.0.0+1
```

---

## 🌐 Production API Configuration

### Update Production URLs
**File:** `lib/config/environment.dart`
```dart
class _ProductionConfig {
  // Replace with your actual production server
  static const String baseUrl = 'https://api.yourschool.com/api';
  static const String socketUrl = 'https://api.yourschool.com';
}
```

### Enable Production Mode
**File:** `lib/config/environment.dart`
```dart
static const Environment current = Environment.production;
```

---

## 🔐 Android Release Build Configuration

### 1. Create Signing Key
```bash
keytool -genkey -v -keystore ~/student-notifier-release.keystore \
  -alias student-notifier -keyalg RSA -keysize 2048 -validity 10000
```

### 2. Create key.properties
**File:** `android/key.properties`
```properties
storePassword=<your-keystore-password>
keyPassword=<your-key-password>
keyAlias=student-notifier
storeFile=<path-to-keystore>/student-notifier-release.keystore
```

**⚠️ IMPORTANT:** Add to `.gitignore`:
```
android/key.properties
*.keystore
```

### 3. Update build.gradle.kts
**File:** `android/app/build.gradle.kts`

Add before `android {` block:
```kotlin
// Load keystore properties
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = java.util.Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(java.io.FileInputStream(keystorePropertiesFile))
}
```

Update `android {` block:
```kotlin
android {
    // ... existing config ...

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            // Enable code shrinking and obfuscation
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}
```

### 4. ProGuard Rules (Optional)
**File:** `android/app/proguard-rules.pro`
```proguard
# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Gson (if used)
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.** { *; }

# Socket.IO
-keep class io.socket.** { *; }
```

---

## 📱 Build Commands

### Development Build
```bash
flutter run
```

### Release Build (Android APK)
```bash
flutter build apk --release
```

### Release Build (Android App Bundle - for Play Store)
```bash
flutter build appbundle --release
```

### Build with Production Environment
Ensure `Environment.current = Environment.production` in `environment.dart` before building.

---

## ✅ Pre-Release Checklist

### Code Quality
- [x] All debug prints removed/replaced with AppLogger
- [x] No TODO comments remaining
- [x] debugShowCheckedModeBanner: false
- [ ] All commented code removed
- [ ] No test/mock data in code

### Configuration
- [x] Environment configuration created
- [ ] Production API URLs updated
- [ ] Environment set to production
- [ ] App name updated
- [ ] Package identifier updated
- [ ] Version number finalized

### Android Build
- [ ] Release keystore created
- [ ] key.properties configured
- [ ] key.properties added to .gitignore
- [ ] Signing config updated in build.gradle.kts
- [ ] ProGuard rules configured (optional)
- [ ] minSdk set appropriately (21+ recommended)
- [ ] targetSdk set to latest (34)

### Testing
- [ ] Test app with production API URLs
- [ ] Test on physical Android device
- [ ] Test with release build
- [ ] Verify all features work (login, signup, notifications, socket.io)
- [ ] Check for memory leaks
- [ ] Verify app permissions

### Security
- [ ] API keys not hardcoded
- [ ] Keystore secured and backed up
- [ ] HTTPS used for all API calls
- [ ] JWT tokens properly secured
- [ ] flutter_secure_storage used for sensitive data

### App Store Preparation (if applicable)
- [ ] App icon created (1024x1024)
- [ ] Feature graphic created
- [ ] Screenshots prepared
- [ ] Privacy policy written
- [ ] Terms of service written
- [ ] App description written

---

## 🚀 Deployment Steps

### 1. Final Preparation
```bash
# Clean project
flutter clean
flutter pub get

# Run analyzer
flutter analyze

# Run tests (if any)
flutter test
```

### 2. Build Release
```bash
# For APK
flutter build apk --release --split-per-abi

# For App Bundle (Google Play)
flutter build appbundle --release
```

### 3. Test Release Build
```bash
# Install on device
flutter install --release
```

### 4. Deploy
- Upload to Google Play Console
- Or distribute APK directly to users

---

## 📝 Notes

### Current App Features
- ✅ Modern UI with school colors (blue/white theme)
- ✅ Real-time notifications via Socket.IO
- ✅ JWT authentication
- ✅ Three user roles: Receptionist, Teacher, Manager
- ✅ Student attendance tracking
- ✅ Responsive design
- ✅ Production-ready logging system

### Known Issues/Limitations
- No profile picture upload (using initials instead)
- Backend must be running for app to work
- No offline support

### Maintenance
- Regularly update dependencies: `flutter pub upgrade`
- Monitor crash reports
- Keep targetSdk updated
- Update API base URLs if server changes

---

## 🆘 Troubleshooting

### Build Errors
**Error:** "Failed to find keystore"
- Verify `key.properties` path is correct
- Check keystore file exists

**Error:** "minSdkVersion X cannot be smaller than version Y"
- Update minSdk in build.gradle.kts

### Runtime Issues
**Socket not connecting:**
- Verify production URL is correct
- Check HTTPS/WSS protocol
- Verify backend is accepting connections

**Login failing:**
- Confirm API baseUrl is correct
- Check network permissions
- Verify backend is running

---

## 📞 Support

For issues or questions:
1. Check this guide first
2. Review error logs: `AppLogger` output in debug mode
3. Test with development environment first
4. Verify backend is functioning

---

**Last Updated:** Production readiness preparation completed
**App Version:** 1.0.0+1
**Flutter Version:** 3.9.2+
**Dart Version:** 3.9.2+
