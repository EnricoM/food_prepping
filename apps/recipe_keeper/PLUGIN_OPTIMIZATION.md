# Plugin Optimization Analysis

## Current Java Process Sources

Your Flutter app is using several plugins that require Google Play Services, which spawn Java processes:

### 1. **google_mobile_ads (AdMob)** - HIGH IMPACT
- **Status**: Initialized at app startup in `main.dart`
- **Impact**: Requires Google Play Services, spawns multiple Java processes
- **Usage**: Only shown to non-premium users
- **Recommendation**: Make initialization lazy (only when first ad is needed)

### 2. **google_mlkit_text_recognition** - MEDIUM IMPACT
- **Status**: Used in `ReceiptOcrService` (lazy initialization)
- **Impact**: Requires Google Play Services for ML processing
- **Usage**: Only when scanning receipts
- **Recommendation**: Already optimized (lazy), but could be made conditional

### 3. **mobile_scanner** - LOW IMPACT
- **Status**: Used for barcode scanning
- **Impact**: Camera services, minimal Java processes
- **Usage**: Only when scanning barcodes
- **Recommendation**: Already optimized (lazy)

## Optimization Recommendations

### Option 1: Lazy AdMob Initialization (RECOMMENDED)
Move AdMob initialization from `main.dart` to when the first ad is actually needed.

**Benefits:**
- Reduces startup time
- Fewer Java processes at startup
- Only initializes when ads are actually shown

### Option 2: Remove AdMob Entirely (If not needed)
If you're not actively using ads or want to remove them:
- Remove `google_mobile_ads` from `pubspec.yaml`
- Remove AdMob initialization from `main.dart`
- Remove `AdBanner` widget usage
- Remove AdMob metadata from `AndroidManifest.xml`

### Option 3: Conditional ML Kit (If receipts not critical)
If receipt scanning is not a core feature:
- Make ML Kit optional
- Only load when user accesses receipt scanning feature

## Current Plugin Usage

- ✅ **google_mobile_ads**: Used in `AdBanner` widget, initialized at startup
- ✅ **google_mlkit_text_recognition**: Used in `ReceiptOcrService`, lazy loaded
- ✅ **mobile_scanner**: Used in `BarcodeScanScreen`, lazy loaded

## Next Steps

1. **Immediate**: Make AdMob initialization lazy (biggest impact)
2. **Optional**: Consider removing AdMob if ads aren't critical
3. **Future**: Monitor Java processes after optimization

