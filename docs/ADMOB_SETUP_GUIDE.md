# Setting Up Real AdMob Ads (Replacing Test Ads)

## Current Test Ad IDs

You're currently using Google's test ad units:

**App ID (AndroidManifest.xml):**
- `ca-app-pub-3940256099942544~3347511713` (test)

**Banner Ad Units (ad_banner.dart):**
- Android: `ca-app-pub-3940256099942544/6300978111` (test)
- iOS: `ca-app-pub-3940256099942544/2934735716` (test)

---

## ⚠️ When to Set Up Real Ads?

**Recommended Approach:** Set up real AdMob ad units **BEFORE** publishing to Play Store.

**Why?**
- Real ad units automatically show **test ads** until your app is published
- Once published, they automatically switch to **real ads** (no code changes needed!)
- You avoid having to update and republish your app just to switch ad units

**Alternative:** You can publish with test ads first, then switch to real ads later, but this requires:
- Updating code with real ad unit IDs
- Building a new release
- Publishing an update

**Bottom line:** Do the AdMob setup now, then publish. It's the same amount of work upfront, but saves you from doing it twice.

---

## Step 1: Create AdMob Account

1. **Go to AdMob**
   - Visit https://apps.admob.com
   - Sign in with your Google account (use the same account as Play Console)

2. **Create AdMob Account**
   - Click "Get Started"
   - Accept terms and conditions
   - Complete account setup

---

## Step 2: Add Your App to AdMob

1. **In AdMob Dashboard:**
   - Click "Apps" → "Add app"
   - **Select "No, it's not listed on a supported app store"** (since your app isn't published yet)
   - Choose platform: "Android"
   - Enter your app name: "Recipe Parser" (this is just for your reference in AdMob)
   - **Note:** You won't be asked for the package name at this stage - that's normal!
   - Choose whether to enable user metrics (you can leave default)
   - Click "Add app"

2. **Get Your App ID**
   - After adding the app, AdMob will show your **App ID**
   - Format: `ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX`
   - **Save this!** You'll need it for AndroidManifest.xml

**Note:** Even though your app isn't in the store yet, you can still:
- ✅ Create ad units
- ✅ Get ad unit IDs
- ✅ Test ads in your app
- ✅ Use real ad units (they'll show test ads until your app is published)

**After Publishing:** Once your app is live in Play Store, you can link it to AdMob later if needed (in App settings → App stores → Add store), but it's not required to start showing ads.

---

## Step 3: Create Ad Units

1. **Create Banner Ad Unit**
   - In AdMob Dashboard → "Apps" → Select your app
   - Click "Add ad unit"
   - Select "Banner"
   - Name it: "Recipe Parser Banner" (or any name)
   - Click "Create ad unit"

2. **Get Ad Unit IDs**
   - AdMob will show your ad unit IDs
   - Format: `ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX`
   - You'll get separate IDs for Android and iOS
   - **Save both!**

---

## Step 4: Replace Test IDs in Your Code

### 4.1 Update AndroidManifest.xml

**File:** `android/app/src/main/AndroidManifest.xml`

**Replace:**
```xml
<!-- AdMob App ID (test ID). Replace with your real app id before release. -->
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-3940256099942544~3347511713"/>
```

**With your real App ID:**
```xml
<!-- AdMob App ID -->
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX"/>
```

Replace `ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX` with your actual App ID from AdMob.

### 4.2 Update ad_banner.dart

**File:** `lib/src/widgets/ad_banner.dart`

**Replace the `_testUnitId()` function:**

**Current (test IDs):**
```dart
String _testUnitId() {
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return 'ca-app-pub-3940256099942544/6300978111';
    case TargetPlatform.iOS:
      return 'ca-app-pub-3940256099942544/2934735716';
    default:
      return 'ca-app-pub-3940256099942544/6300978111';
  }
}
```

**With your real ad unit IDs:**
```dart
String _adUnitId() {
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'; // Your Android banner ad unit ID
    case TargetPlatform.iOS:
      return 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'; // Your iOS banner ad unit ID
    default:
      return 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'; // Your Android banner ad unit ID
  }
}
```

**Also update the BannerAd initialization:**
```dart
_banner = BannerAd(
  size: AdSize.banner,
  adUnitId: _adUnitId(), // Changed from _testUnitId()
  listener: BannerAdListener(
    // ... rest of the code
  ),
  request: const AdRequest(),
)..load();
```

---

## Step 5: Test with Test Ads First (Recommended)

Before using real ads, test that everything works:

1. **Keep test IDs temporarily**
2. **Build and test the app**
3. **Verify ads load correctly**
4. **Then replace with real IDs**

Or use AdMob's test mode:
- Add your device as a test device in AdMob
- Real ad units will show test ads on test devices
- Production users will see real ads

---

## Step 6: Build and Deploy

After replacing the IDs:

```bash
# Build release bundle
flutter build appbundle --release

# Upload to Play Console
# The app will now show real ads to users
```

---

## Important Notes

### ⚠️ AdMob Account Setup

- **Payment Info Required**: AdMob requires payment information to show real ads
- **Account Verification**: May take a few days to verify your account
- **Minimum Payout**: Usually $100 (varies by country)

### ⚠️ Ad Policy Compliance

- **Content Policy**: Make sure your app complies with AdMob policies
- **Invalid Traffic**: Don't click your own ads (will get banned)
- **User Experience**: Don't make ads too intrusive

### ⚠️ Testing

- **Test Devices**: Add your test devices in AdMob to see test ads
- **Test Mode**: Use test ad units during development
- **Real Ads**: Only use real ad units in production builds

---

## Quick Checklist

- [ ] Create AdMob account
- [ ] Add app to AdMob
- [ ] Get App ID from AdMob
- [ ] Create banner ad unit
- [ ] Get ad unit IDs (Android and iOS)
- [ ] Replace App ID in AndroidManifest.xml
- [ ] Replace ad unit IDs in ad_banner.dart
- [ ] Test with test ads first
- [ ] Build release bundle
- [ ] Upload to Play Console

---

## Troubleshooting

### "Ad failed to load"
- Check ad unit IDs are correct
- Verify App ID in AndroidManifest.xml
- Check AdMob account is active
- Ensure payment info is set up

### "Ad unit not found"
- Double-check ad unit IDs
- Verify app is added to AdMob
- Wait a few minutes after creating ad units

### "Invalid ad unit ID format"
- Format should be: `ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX`
- No spaces or extra characters
- Check you copied the full ID

---

## Need Help?

If you need assistance:
1. AdMob Help Center: https://support.google.com/admob
2. AdMob Policies: https://support.google.com/admob/answer/6128543
3. Flutter AdMob Guide: https://pub.dev/packages/google_mobile_ads

Good luck! 🚀

