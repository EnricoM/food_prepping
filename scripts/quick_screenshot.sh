#!/bin/bash
# Quick screenshot helper - takes one screenshot at a time

SCREENSHOT_DIR="screenshots/phone"
mkdir -p "$SCREENSHOT_DIR"

if ! command -v adb &> /dev/null; then
    echo "ADB not found. Install Android SDK platform-tools first."
    exit 1
fi

DEVICES=$(adb devices | grep -v "List" | grep "device$" | wc -l)
if [ "$DEVICES" -eq 0 ]; then
    echo "No device connected. Connect your phone or start an emulator."
    exit 1
fi

# Generate filename with timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
FILENAME="${SCREENSHOT_DIR}/screenshot_${TIMESTAMP}.png"

echo "Taking screenshot..."
adb exec-out screencap -p > "$FILENAME"

if [ -f "$FILENAME" ] && [ -s "$FILENAME" ]; then
    SIZE=$(stat -c%s "$FILENAME" 2>/dev/null || echo "unknown")
    echo "✅ Screenshot saved: $FILENAME ($SIZE bytes)"
else
    echo "❌ Failed to capture screenshot"
    exit 1
fi

