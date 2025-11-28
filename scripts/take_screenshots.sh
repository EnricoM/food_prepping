#!/bin/bash
# Automated screenshot script for Play Store
# Requires: Android device connected via ADB or emulator running

set -e

SCREENSHOT_DIR="screenshots/phone"
mkdir -p "$SCREENSHOT_DIR"

echo "📸 Play Store Screenshot Capture Script"
echo "========================================"
echo ""

# Check if adb is available
if ! command -v adb &> /dev/null; then
    echo "❌ ADB not found. Please install Android SDK platform-tools."
    echo "   Or connect your device and take screenshots manually."
    exit 1
fi

# Check if device is connected
DEVICES=$(adb devices | grep -v "List" | grep "device$" | wc -l)
if [ "$DEVICES" -eq 0 ]; then
    echo "❌ No Android device or emulator connected."
    echo ""
    echo "Please:"
    echo "1. Connect your Android device via USB and enable USB debugging"
    echo "2. Or start an Android emulator"
    echo "3. Then run this script again"
    exit 1
fi

echo "✅ Device connected: $(adb devices | grep device$ | head -1 | cut -f1)"
echo ""

# Function to take screenshot
take_screenshot() {
    local name=$1
    local description=$2
    local filename="${SCREENSHOT_DIR}/screenshot_${name}.png"
    
    echo "📷 Taking screenshot: $description"
    echo "   Navigate to the screen in your app, then press ENTER..."
    read -r
    
    adb exec-out screencap -p > "$filename"
    
    if [ -f "$filename" ] && [ -s "$filename" ]; then
        echo "   ✅ Saved: $filename"
        # Get file size
        SIZE=$(stat -f%z "$filename" 2>/dev/null || stat -c%s "$filename" 2>/dev/null || echo "unknown")
        echo "   📊 Size: $SIZE bytes"
    else
        echo "   ❌ Failed to capture screenshot"
        return 1
    fi
    echo ""
}

echo "This script will guide you through taking screenshots of key screens."
echo "Make sure your app is running on the connected device."
echo ""
echo "Press ENTER when ready to start..."
read -r

# List of screenshots to take
take_screenshot "01_home" "Home Screen"
take_screenshot "02_add_recipe" "Add Recipe Screen (showing URL input)"
take_screenshot "03_stored_recipes" "Stored Recipes Screen (with recipe list)"
take_screenshot "04_recipe_detail" "Recipe Detail Screen (showing full recipe)"
take_screenshot "05_domain_discovery" "Domain Discovery Screen"
take_screenshot "06_shopping_list" "Shopping List Screen"
take_screenshot "07_inventory" "Inventory Screen"
take_screenshot "08_settings" "Settings Screen"

echo "========================================"
echo "✅ Screenshot capture complete!"
echo ""
echo "Screenshots saved in: $SCREENSHOT_DIR"
echo ""
echo "Next steps:"
echo "1. Review the screenshots"
echo "2. Ensure they show the app features clearly"
echo "3. Upload to Play Console when creating store listing"
echo ""
ls -lh "$SCREENSHOT_DIR"/*.png 2>/dev/null || echo "No screenshots found"

