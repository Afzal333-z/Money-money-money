#!/bin/bash

echo "===================================="
echo "Money Money - Clean Build Script"
echo "===================================="
echo ""
echo "This will clean all build caches and rebuild from scratch"
echo ""

echo "[1/5] Cleaning Flutter build cache..."
flutter clean
echo ""

echo "[2/5] Cleaning Gradle build cache..."
rm -rf android/.gradle
rm -rf android/app/build
rm -rf android/build
rm -rf build
echo ""

echo "[3/5] Cleaning global Gradle daemon cache..."
gradle --stop 2>/dev/null || true
echo ""

echo "[4/5] Getting Flutter dependencies..."
flutter pub get
echo ""

echo "[5/5] Building APK..."
flutter build apk --debug
echo ""

echo "===================================="
echo "Clean build complete!"
echo "===================================="
