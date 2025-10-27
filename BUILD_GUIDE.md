# Harmony Hub - Build & Release Guide

## Prerequisites

1. **Flutter SDK** (3.0.0 or higher)
2. **Android Studio** (for Android builds)
3. **Xcode** (for iOS builds - Mac only)
4. **Java 21** (OpenJDK 21.0.4 or higher)

## Environment Setup

### 1. Configure Supabase Credentials

1. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` and add your Supabase credentials:
   ```env
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key-here
   ```

3. Get your credentials from:
   - Go to https://supabase.com
   - Open your project
   - Settings > API
   - Copy "Project URL" and "Project API keys" (anon/public key)

**⚠️ IMPORTANT:** Never commit the `.env` file to git! It's already in `.gitignore`.

### 2. Install Dependencies

```bash
flutter pub get
```

## Development Builds

### Run on Chrome (Web)
```bash
flutter run -d chrome
```

### Run on Android Device/Emulator
```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Or just
flutter run
# Then select device from the list
```

### Run on iOS Simulator (Mac only)
```bash
flutter run -d iphone
```

## Release Builds

### Android APK (Debug - for testing)
```bash
flutter build apk --debug
```
Output: `build/app/outputs/flutter-apk/app-debug.apk`

### Android APK (Release)
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (for Google Play Store)
```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

**Note:** For production, use App Bundle (AAB) instead of APK. Google Play requires AAB for new apps.

### iOS (Mac only)
```bash
# Debug
flutter build ios --debug

# Release
flutter build ios --release
```

### Web
```bash
flutter build web --release
```
Output: `build/web/`

## Code Signing (Production)

### Android

1. **Create a keystore** (one-time):
   ```bash
   keytool -genkey -v -keystore ~/harmony-hub-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias harmony-hub
   ```

2. **Create `android/key.properties`**:
   ```properties
   storePassword=<your-store-password>
   keyPassword=<your-key-password>
   keyAlias=harmony-hub
   storeFile=<path-to-your-keystore>
   ```

3. **Update `android/app/build.gradle`**:
   ```gradle
   // Add before android { block
   def keystoreProperties = new Properties()
   def keystorePropertiesFile = rootProject.file('key.properties')
   if (keystorePropertiesFile.exists()) {
       keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
   }

   android {
       ...
       signingConfigs {
           release {
               keyAlias keystoreProperties['keyAlias']
               keyPassword keystoreProperties['keyPassword']
               storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
               storePassword keystoreProperties['storePassword']
           }
       }
       buildTypes {
           release {
               signingConfig signingConfigs.release
               ...
           }
       }
   }
   ```

### iOS

1. Open project in Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. Configure signing in Xcode:
   - Select "Runner" in project navigator
   - Go to "Signing & Capabilities"
   - Select your team
   - Xcode will automatically manage provisioning profiles

## Build Variants

### Different Flavors (Optional)

You can create different flavors for dev/staging/production:

```bash
# Development
flutter build apk --flavor dev -t lib/main_dev.dart

# Staging
flutter build apk --flavor staging -t lib/main_staging.dart

# Production
flutter build apk --flavor production -t lib/main.dart
```

## Optimization Tips

### 1. Reduce APK Size

```bash
# Build split APKs per architecture
flutter build apk --split-per-abi
```

This creates separate APKs for:
- `arm64-v8a` (64-bit ARM - most modern devices)
- `armeabi-v7a` (32-bit ARM - older devices)
- `x86_64` (64-bit Intel - emulators/tablets)

### 2. Obfuscate Code

```bash
flutter build apk --obfuscate --split-debug-info=build/app/outputs/symbols
```

### 3. Enable R8/ProGuard (Android)

In `android/gradle.properties`:
```properties
android.enableR8=true
android.enableR8.fullMode=true
```

## Troubleshooting

### Clean Build

```bash
flutter clean
flutter pub get
flutter build apk
```

### Gradle Issues

```bash
cd android
./gradlew clean
cd ..
flutter build apk
```

### Check for Issues

```bash
flutter doctor
flutter doctor -v
```

## Version Management

Update version in `pubspec.yaml`:
```yaml
version: 1.0.0+1
#        ^       ^
#        |       |
#     version   build number
```

- **Version**: Semantic version (major.minor.patch)
- **Build number**: Integer that must increase with each release

Example progression:
- `1.0.0+1` - Initial release
- `1.0.1+2` - Bug fix
- `1.1.0+3` - New feature
- `2.0.0+4` - Major update

## Testing Before Release

### 1. Run Tests
```bash
flutter test
```

### 2. Analyze Code
```bash
flutter analyze
```

### 3. Check Formatting
```bash
flutter format --set-exit-if-changed lib/
```

### 4. Test on Physical Devices
- Test on at least 2-3 different Android versions
- Test on different screen sizes
- Test on both Wi-Fi and mobile data

## Publishing

### Google Play Store (Android)

1. Create Google Play Console account
2. Create new application
3. Upload AAB file:
   ```bash
   flutter build appbundle --release
   ```
4. Fill in store listing, screenshots, etc.
5. Submit for review

### Apple App Store (iOS)

1. Create App Store Connect account
2. Create new app
3. Archive in Xcode and upload
4. Fill in app information
5. Submit for review

### Web Hosting

Deploy `build/web/` to:
- Firebase Hosting
- Netlify
- Vercel
- AWS S3 + CloudFront
- Your own server

Example (Firebase):
```bash
firebase deploy --only hosting
```

## CI/CD (Optional)

### GitHub Actions Example

Create `.github/workflows/build.yml`:
```yaml
name: Build APK

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-java@v1
        with:
          java-version: '21'
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
      - run: flutter pub get
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v2
        with:
          name: release-apk
          path: build/app/outputs/flutter-apk/app-release.apk
```

## Current Build Configuration

### Android
- **Minimum SDK**: 21 (Android 5.0 Lollipop)
- **Target SDK**: 35 (Android 15)
- **Compile SDK**: 35
- **Gradle**: 8.7
- **Android Gradle Plugin**: 8.5.0
- **Kotlin**: 1.9.22
- **Java**: 17 (JVM target)

### iOS
- **Minimum iOS**: 12.0
- **Swift**: 5.0+

## Support

For issues or questions:
1. Check Flutter documentation: https://docs.flutter.dev
2. Check Android/iOS specific guides
3. Review error logs carefully
4. Search Stack Overflow
5. Check GitHub issues

## Quick Reference

```bash
# Development
flutter run                          # Run in debug mode
flutter run --release                # Run in release mode
flutter hot-reload                   # Hot reload (in running app: press 'r')
flutter hot-restart                  # Hot restart (in running app: press 'R')

# Building
flutter build apk --release          # Android APK
flutter build appbundle --release    # Android Bundle (Play Store)
flutter build ios --release          # iOS
flutter build web --release          # Web

# Maintenance
flutter clean                        # Clean build cache
flutter pub get                      # Get dependencies
flutter pub upgrade                  # Upgrade dependencies
flutter doctor                       # Check environment
flutter analyze                      # Analyze code
flutter test                         # Run tests

# Deployment
flutter build apk --split-per-abi --obfuscate --split-debug-info=symbols
```
