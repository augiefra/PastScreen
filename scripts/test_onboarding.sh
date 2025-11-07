#!/bin/bash

# Test Onboarding Script
# Resets the "hasSeenOnboarding" flag and launches the app

echo "🧪 Testing Onboarding System"
echo ""

# Kill existing app instance
echo "1️⃣ Killing existing ScreenSnap instance..."
killall ScreenSnap 2>/dev/null
sleep 1

# Reset UserDefaults flag
echo "2️⃣ Resetting hasSeenOnboarding flag..."
defaults delete com.augiefra.ScreenSnap hasSeenOnboarding 2>/dev/null
echo "✅ Flag reset"

# Launch app
echo "3️⃣ Launching ScreenSnap..."
APP_PATH="/Users/ecologni/Library/Developer/Xcode/DerivedData/ScreenSnap-adykbzvphafuuccwovusohoxryvy/Build/Products/Debug/ScreenSnap.app"

if [ -d "$APP_PATH" ]; then
    open "$APP_PATH"
    echo "✅ App launched"
    echo ""
    echo "📝 Expected behavior:"
    echo "   - App should appear in menu bar"
    echo "   - After ~1 second, onboarding popup should appear"
    echo "   - Click 'Compris!' to dismiss"
    echo ""
    echo "💡 To test 'Don't show again':"
    echo "   - Check the checkbox before clicking 'Compris!'"
    echo "   - Rerun this script"
    echo "   - Onboarding should NOT appear"
else
    echo "❌ App not found at: $APP_PATH"
    echo "💡 Build the app first with: xcodebuild -project ScreenSnap.xcodeproj -scheme ScreenSnap build"
fi
