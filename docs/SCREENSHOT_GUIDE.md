# Play Store Screenshot Guide

## Required Screenshots

For Google Play Store, you need at least **2 phone screenshots** (up to 8 recommended).

### Recommended Screenshots (in order):

1. **Home Screen** - Main entry point showing app overview
2. **Add Recipe Screen** - Core feature: parsing recipes from URLs
3. **Stored Recipes Screen** - Shows your recipe collection with statistics
4. **Recipe Detail Screen** - Beautiful recipe view with ingredients and instructions
5. **Domain Discovery Screen** - Unique feature: discover recipes from websites
6. **Shopping List Screen** - Practical feature for meal planning
7. **Inventory Screen** - Track ingredients you have
8. **Settings Screen** - Show customization options

## Screenshot Requirements

- **Format**: PNG or JPEG
- **Size**: 
  - Phone: 16:9 or 9:16 aspect ratio
  - Minimum: 320px (shortest side)
  - Maximum: 3840px (longest side)
- **Recommended**: 1080x1920 (9:16) or 1920x1080 (16:9)
- **No device frames needed** (Google adds them automatically)

## How to Take Screenshots

### Option 1: Using ADB (Android Device/Emulator)

If you have an Android device connected or emulator running:

```bash
# List connected devices
adb devices

# Take a screenshot (saves to device, then pull it)
adb shell screencap -p /sdcard/screenshot.png
adb pull /sdcard/screenshot.png screenshots/screenshot_1.png

# Or use this one-liner:
adb exec-out screencap -p > screenshots/screenshot_1.png
```

### Option 2: Manual Screenshots on Device

1. Run the app on your Android device:
   ```bash
   flutter run
   ```

2. Navigate to each screen you want to capture

3. Take screenshot using device:
   - **Android**: Power + Volume Down
   - Or use the screenshot button in notification panel

4. Transfer screenshots to your computer:
   ```bash
   adb pull /sdcard/Pictures/Screenshots screenshots/
   ```

### Option 3: Using Flutter Screenshot Package

I can create an automated script that captures screens programmatically. This requires:
- Adding `screenshot` package
- Creating a script that navigates and captures

### Option 4: Using Android Studio Emulator

1. Start Android Studio
2. Create/start an Android Virtual Device (AVD)
3. Run the app: `flutter run`
4. Use the camera icon in the emulator toolbar to take screenshots
5. Screenshots are saved automatically

## Organizing Screenshots

Create a `screenshots/` directory:

```bash
mkdir -p screenshots/phone
```

Name them descriptively:
- `screenshot_01_home.png`
- `screenshot_02_add_recipe.png`
- `screenshot_03_stored_recipes.png`
- `screenshot_04_recipe_detail.png`
- `screenshot_05_domain_discovery.png`
- `screenshot_06_shopping_list.png`
- `screenshot_07_inventory.png`
- `screenshot_08_settings.png`

## Tips for Great Screenshots

1. **Show real content**: Use actual recipes, not empty states
2. **Highlight key features**: Make sure important UI elements are visible
3. **Consistent styling**: Use the same device/theme for all screenshots
4. **Good lighting**: Ensure text is readable
5. **No personal data**: Remove any personal information
6. **Show variety**: Capture different types of recipes/content

## Next Steps

1. Take screenshots using one of the methods above
2. Save them in `screenshots/phone/` directory
3. Verify they meet size requirements
4. Upload to Play Console when creating your store listing

