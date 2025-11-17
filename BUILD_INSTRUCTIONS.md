# 🔨 Build Instructions for Money Money App

## 🚨 First Time Setup / Build Issues?

If you're getting build errors, follow these steps **in order**:

---

## 📋 Method 1: Automated Clean Build (RECOMMENDED)

### On Windows:
```bash
# Simply double-click or run:
clean_build.bat
```

### On Mac/Linux:
```bash
# Run:
./clean_build.sh
```

This script will:
1. Clean Flutter cache (`flutter clean`)
2. Delete all Gradle build directories
3. Stop Gradle daemon
4. Get fresh dependencies (`flutter pub get`)
5. Build the app (`flutter build apk --debug`)

---

## 📋 Method 2: Manual Clean Build

If the automated script doesn't work, try these manual steps:

### Step 1: Clean Everything
```bash
# Clean Flutter
flutter clean

# Get fresh dependencies
flutter pub get
```

### Step 2: Clean Android Studio Caches

**In Android Studio:**
1. File → Invalidate Caches / Restart
2. Choose "Invalidate and Restart"
3. Wait for Android Studio to restart
4. File → Sync Project with Gradle Files

### Step 3: Delete Build Directories

**On Windows (Command Prompt):**
```bash
rmdir /s /q android\.gradle
rmdir /s /q android\app\build
rmdir /s /q android\build
rmdir /s /q build
```

**On Mac/Linux (Terminal):**
```bash
rm -rf android/.gradle
rm -rf android/app/build
rm -rf android/build
rm -rf build
```

### Step 4: Stop Gradle Daemon
```bash
cd android
gradle --stop
cd ..
```

### Step 5: Rebuild
```bash
flutter run
# or
flutter build apk --debug
```

---

## 🔧 Verify Your Environment

### Check Versions:
```bash
flutter doctor -v
```

### Required Versions:
- ✅ **Flutter**: 3.0.0+ (latest stable recommended)
- ✅ **Dart**: 3.0.0+
- ✅ **Java/JDK**: 17 or 21 (bundled with Android Studio)
- ✅ **Android Studio**: Hedgehog (2023.1.1) or later

### Our Build Configuration:
- ✅ **Gradle**: 8.7
- ✅ **Android Gradle Plugin**: 8.6.1
- ✅ **Kotlin**: 2.1.0
- ✅ **compileSdk**: 36 (Android 15)
- ✅ **targetSdk**: 35 (Android 14)
- ✅ **minSdk**: 21 (Android 5.0+)

---

## 🐛 Common Issues & Solutions

### Issue 1: "compileSdk 34" Error
**Error:** `Your project is configured to compile against Android SDK 34`

**Solution:**
- The build is using cached values
- Run the clean build script (`clean_build.bat` or `clean_build.sh`)
- OR manually delete `android/.gradle` folder and rebuild

### Issue 2: "jlink.exe execution failed"
**Error:** `Error while executing process jlink.exe`

**Solution:**
- This is a Gradle cache issue
- Delete: `C:\Users\YourName\.gradle\caches` (Windows)
- Delete: `~/.gradle/caches` (Mac/Linux)
- Run clean build script

### Issue 3: AGP/Gradle Version Warnings
**Warning:** `AGP version will soon be dropped`

**Solution:**
- We're already using the latest versions (8.6.1, 8.7, 2.1.0)
- These warnings appear during the sync but won't affect the build
- Ignore them or update to even newer versions when available

### Issue 4: Java Version Issues
**Error:** `Unsupported class file major version`

**Solution:**
- Ensure you're using Java 17 or Java 21
- In Android Studio:
  - File → Project Structure → SDK Location → JDK location
  - Use the bundled JDK: `C:\Program Files\Android\Android Studio\jbr`

### Issue 5: Plugin Version Conflicts
**Error:** `plugin requires Android SDK version 36`

**Solution:**
- Already fixed in `android/app/build.gradle` (compileSdk = 36)
- If still seeing this, clean build caches and rebuild

---

## ✅ Successful Build Checklist

After running the build, you should see:

```
✓ Built build/app/outputs/flutter-apk/app-debug.apk (XX MB)
```

If you see this message, the build succeeded! 🎉

---

## 🚀 Quick Commands Reference

### Development:
```bash
# Run on connected device/emulator
flutter run

# Run with hot reload
flutter run --debug

# Run in release mode
flutter run --release
```

### Building:
```bash
# Build debug APK
flutter build apk --debug

# Build release APK
flutter build apk --release

# Build app bundle (for Play Store)
flutter build appbundle --release
```

### Debugging:
```bash
# Check Flutter environment
flutter doctor -v

# Show devices
flutter devices

# Analyze code
flutter analyze

# Run tests
flutter test
```

---

## 📱 Running on Device

### Android Device:
1. Enable Developer Options on your phone
2. Enable USB Debugging
3. Connect via USB
4. Run `flutter devices` to verify connection
5. Run `flutter run`

### Android Emulator:
1. Open Android Studio → Device Manager
2. Create/Start an emulator
3. Run `flutter run`

---

## 🆘 Still Having Issues?

1. **Update Flutter:**
   ```bash
   flutter upgrade
   ```

2. **Check for Flutter issues:**
   ```bash
   flutter doctor -v
   ```

3. **Verify Gradle installation:**
   ```bash
   cd android
   ./gradlew --version
   ```

4. **Check Android SDK:**
   - Open Android Studio
   - Tools → SDK Manager
   - Ensure Android SDK 36 is installed
   - Ensure Android SDK Platform-Tools are updated

5. **Nuclear option (last resort):**
   ```bash
   # Delete ALL Flutter/Gradle caches
   flutter clean
   rm -rf ~/.gradle/caches  # Mac/Linux
   rmdir /s /q %USERPROFILE%\.gradle\caches  # Windows

   # Reinstall dependencies
   flutter pub get

   # Rebuild
   flutter run
   ```

---

## 📞 Support

If you're still experiencing issues after trying all the above:

1. Run `flutter doctor -v` and check the output
2. Check the full error message in the terminal
3. Look for the specific error in the Gradle build output
4. Search for the error on:
   - https://github.com/flutter/flutter/issues
   - https://stackoverflow.com/questions/tagged/flutter

---

## ✨ Tips for Faster Builds

1. **Use Gradle Daemon** (already enabled in `gradle.properties`)
2. **Enable Parallel Builds** (already enabled)
3. **Use Build Cache** (already enabled)
4. **Close Other Apps** during build
5. **Use SSD** for development projects
6. **Increase Gradle Heap Size** (already set to 4GB in `gradle.properties`)

---

**Happy Coding! 🌳💰✨**
