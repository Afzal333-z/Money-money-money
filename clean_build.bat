@echo off
echo ====================================
echo Money Money - Clean Build Script
echo ====================================
echo.
echo This will clean all build caches and rebuild from scratch
echo.

echo [1/5] Cleaning Flutter build cache...
call flutter clean
echo.

echo [2/5] Cleaning Gradle build cache...
rmdir /s /q android\.gradle 2>nul
rmdir /s /q android\app\build 2>nul
rmdir /s /q android\build 2>nul
rmdir /s /q build 2>nul
echo.

echo [3/5] Cleaning global Gradle daemon cache...
call gradle --stop 2>nul
echo.

echo [4/5] Getting Flutter dependencies...
call flutter pub get
echo.

echo [5/5] Building APK...
call flutter build apk --debug
echo.

echo ====================================
echo Clean build complete!
echo ====================================
pause
