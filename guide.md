# 🚀 RoadHero Flutter Environment Setup Guide

Follow this step-by-step guide to run the transformed `road_hero` codebase on a new PC with the Flutter SDK installed.

## 1. Initial Setup and Cleaning
Since the project is moving environments, it's best to clear out any old cached builds so everything is generated fresh.
Open a terminal in the project root (`road_hero/`) and run:
```bash
flutter clean
flutter pub get
```
> [!NOTE] 
> Because we stripped out `freezed` and built the models manually, you **do not** need to run any code generation commands like `build_runner`!

## 2. Verify with the Analyzer
Running the analyzer is highly recommended. It will catch any lingering typos or unresolved imports across the files we edited:
```bash
flutter analyze
```
> [!TIP]
> If you see any minor errors (like an unresolved variable or a syntax issue), your IDE will easily point you to the missing import or typo.

## 3. Check Important Configurations
Before you hit run, you should double-check the following configurations based on your current network and environment:

### 🌐 Backend Base URL
Open `lib/core/config/app_config.dart`. Ensure that the API base URL matches your active backend:
`http://34.254.56.65/api/v1/driver/`

### 🔒 SSL Bypass for Development
In `lib/core/api/dio_client.dart` (around line 26), there is a debug-only bypass for SSL validation. 
> [!WARNING]
> This is perfectly fine while testing against a raw IP address, but **remember to remove this callback** whenever you attach a real domain name and an SSL certificate to your production backend!

### 🌍 Location Permissions (Android/iOS)
Since we integrated `geolocator` for map tracking and setting locations, verify that your native manifest files have the appropriate permissions:

* **Android** (`android/app/src/main/AndroidManifest.xml`): Make sure the following are present:
  ```xml
  <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
  <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
  ```
* **iOS** (`ios/Runner/Info.plist`): Make sure the following description is present:
  ```xml
  <key>NSLocationWhenInUseUsageDescription</key>
  <string>We need your location to send emergency roadside assistance.</string>
  ```

## 4. Running the App
We now use the `google_fonts` package to automatically fetch the **Lexend** typography. **Ensure the device/emulator testing the app has internet access during its first run so it can download the font.**

Run the application:
```bash
flutter run
```

🎉 **That's it!** As long as the Flutter environment on your new PC is properly configured (e.g., standard Android Studio or Xcode setup), the project will build the production architecture and all the new UI interfaces immediately without any complex build steps.
