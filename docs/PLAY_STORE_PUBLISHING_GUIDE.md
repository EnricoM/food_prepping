# Complete Guide: Publishing to Google Play Store

## Overview
This guide walks you through the entire process of publishing your app to the Google Play Store, from account setup to production release.

---

## Phase 1: Prerequisites & Account Setup

### 1.1 Create Google Play Console Account
- **Cost**: One-time $25 registration fee (lifetime)
- **Steps**:
  1. Go to [play.google.com/console](https://play.google.com/console)
  2. Sign in with your Google account (use your business/non-personal account)
  3. Pay the $25 registration fee
  4. Complete developer account information (name, email, phone)

### 1.2 Prepare Your App Information
Before starting, gather:
- **App name**: "Recipe Parser" (or your chosen name)
- **App description**: What your app does
- **App icon**: 512x512px PNG (you have this configured)
- **Screenshots**: At least 2, up to 8 (phone screenshots)
- **Feature graphic**: 1024x500px (optional but recommended)
- **Privacy policy URL**: Required for apps with ads/user data

---

## Phase 2: App Preparation

### 2.1 Set Up App Signing (Keystore)
**Status**: ⏳ Need to create keystore

**To create the keystore:**
1. Run the script: `./create_keystore.sh`
   - OR run manually: See `CREATE_KEYSTORE.md` for detailed instructions
2. You'll be prompted for:
   - Keystore password (create a strong password - save it!)
   - Your name/organization details
   - Key password (can be same as keystore password)
3. After creation, I'll help you configure `build.gradle.kts` and `key.properties`

### 2.2 Configure Release Signing
You need to:
1. Create `android/key.properties`:
   ```
   storePassword=YOUR_KEYSTORE_PASSWORD
   keyPassword=YOUR_ALIAS_PASSWORD
   keyAlias=recipeparser
   storeFile=/home/enrico/keystores/recipe_parser_release.keystore
   ```

2. Update `android/app/build.gradle.kts` to use the keystore (replace debug signing)

### 2.3 Update App Version
Your current version: `1.0.0+1`
- **versionName** (1.0.0): User-visible version
- **versionCode** (1): Internal build number (must increase with each release)

For future updates:
- Bug fix: `1.0.1+2` (versionCode increments)
- New feature: `1.1.0+3`
- Major update: `2.0.0+4`

### 2.4 Prepare Store Assets
**Required:**
- **App icon**: 512x512px PNG (no transparency)
- **Screenshots**: 
  - Phone: At least 2, up to 8 (16:9 or 9:16)
  - Tablet: Optional (at least 1 if provided)
- **Short description**: 80 characters max
- **Full description**: 4000 characters max
- **Privacy policy URL**: Required (host on your website or use a free service)

**Optional but recommended:**
- **Feature graphic**: 1024x500px (shown on Play Store listing)
- **Promo video**: YouTube link
- **Screenshots with text**: Add captions explaining features

---

## Phase 3: Create App in Play Console

### 3.1 Create New App
1. Go to Play Console → "All apps" → "Create app"
2. Fill in:
   - **App name**: "Recipe Parser" (or your choice)
   - **Default language**: English (United States)
   - **App or game**: App
   - **Free or paid**: Free (with ads)
   - **Declarations**: Check boxes for ads, data collection, etc.

### 3.2 Set Up App Content
Navigate to: **Policy → App content**

**Required sections:**
- **Privacy Policy**: Add URL (required for apps with ads)
- **Data Safety**: Declare what data you collect
  - Since you use AdMob: Declare "Advertising ID" collection
  - Since you parse recipes: May need to declare "App activity" if you track usage
- **Target audience**: Select age group
- **Content rating**: Complete questionnaire (usually takes 5-10 minutes)

---

## Phase 4: Build Release Bundle

### 4.1 Enable Google Play App Signing
**Important**: Do this BEFORE your first upload!

1. In Play Console → Your App → **Release → Setup → App signing**
2. Google will ask: "Let Google manage and protect your app signing key?"
3. **Answer: YES** (this is the safe approach you wanted)
4. Upload your upload key certificate (we'll generate this)

### 4.2 Build App Bundle (AAB)
**Use App Bundle, not APK** (required for new apps, better optimization)

```bash
cd /home/enrico/StudioProjects/food_prepping
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### 4.3 Verify the Bundle
- File size should be reasonable (typically 10-50MB for Flutter apps)
- Check that it's signed (you can verify with `bundletool` if needed)

---

## Phase 5: Upload to Play Console

### 5.1 Create Internal Testing Track (Recommended First Step)
1. Go to: **Release → Testing → Internal testing**
2. Click "Create new release"
3. Upload your `app-release.aab` file
4. Add **Release notes** (what's new in this version)
5. Click "Save" (don't publish yet)

### 5.2 Add Testers
1. In Internal testing → **Testers** tab
2. Add your email address (or create a test group)
3. You'll get a link to test the app

### 5.3 Test the Internal Release
1. Install the app from the test link on your phone
2. Test all major features
3. Verify ads are working (if applicable)
4. Check that everything works as expected

### 5.4 Create Production Release
Once testing is successful:

1. Go to: **Release → Production**
2. Click "Create new release"
3. Upload the same `app-release.aab` (or a new one if you made fixes)
4. Add release notes
5. Review all sections (store listing, content rating, etc.)

---

## Phase 6: Complete Store Listing

### 6.1 Store Presence → Main Store Listing
Fill in:
- **App name**: "Recipe Parser"
- **Short description**: 80 chars max (appears in search results)
- **Full description**: Detailed description of features
- **App icon**: Upload 512x512px
- **Feature graphic**: 1024x500px (optional)
- **Screenshots**: Upload at least 2 phone screenshots
- **Category**: Food & Drink (or appropriate category)
- **Contact details**: Email, website (if applicable)

### 6.2 Store Listing → Graphics
Upload:
- **App icon**: 512x512px (required)
- **Feature graphic**: 1024x500px (recommended)
- **Phone screenshots**: 2-8 images
- **Tablet screenshots**: Optional

### 6.3 Pricing & Distribution
- **Countries**: Select where to distribute (or "All countries")
- **Price**: Free (since you're using ads)
- **Device categories**: Phone, Tablet (select as appropriate)

---

## Phase 7: Complete Required Policies

### 7.1 Data Safety
Declare:
- ✅ **Advertising ID**: Collected (for AdMob)
- ❓ **Other data**: Review what your app collects
- **Data usage**: How you use the data
- **Data sharing**: With whom you share (AdMob, etc.)

### 7.2 Content Rating
- Complete questionnaire about app content
- Usually results in "Everyone" or "Teen" rating
- Takes 5-10 minutes

### 7.3 Privacy Policy
- **Required** if you collect any data (including ads)
- Host on a website or use a free service like:
  - GitHub Pages
  - Google Sites
  - PrivacyPolicyGenerator.com
- Add URL in Play Console

---

## Phase 8: Submit for Review

### 8.1 Pre-Launch Checklist
Before submitting, verify:
- [ ] App bundle uploaded to Production
- [ ] Store listing complete (name, description, screenshots)
- [ ] Privacy policy URL added
- [ ] Data Safety form completed
- [ ] Content rating completed
- [ ] App tested on Internal testing track
- [ ] All required policies accepted

### 8.2 Submit for Review
1. Go to **Release → Production**
2. Review your release
3. Click **"Start rollout to Production"**
4. Google will review (typically 1-7 days for first submission)
5. You'll receive email notifications about review status

### 8.3 Review Process
- **First submission**: Usually 1-7 days
- **Updates**: Usually 1-3 days
- **Rejections**: Google will email you with reasons
- **Appeals**: You can appeal if you disagree

---

## Phase 9: After Publication

### 9.1 Monitor Your App
- **Play Console Dashboard**: View installs, ratings, crashes
- **User reviews**: Respond to reviews
- **Analytics**: Track user behavior (if enabled)

### 9.2 Update Your App
For future updates:
1. Increment version in `pubspec.yaml` (e.g., `1.0.1+2`)
2. Build new bundle: `flutter build appbundle --release`
3. Upload to Production (or Testing first)
4. Add release notes
5. Submit for review

### 9.3 Maintain Your App
- **Respond to reviews**: Users appreciate responses
- **Fix bugs**: Monitor crash reports
- **Update regularly**: Keep app compatible with new Android versions
- **Comply with policies**: Stay updated on policy changes

---

## Quick Reference: Your App Details

```
App Name: Recipe Parser (or your choice)
Package Name: jeffs.cooking.recipe_parser
Current Version: 1.0.0+1
Keystore: /home/enrico/keystores/recipe_parser_release.keystore
Keystore Alias: recipeparser
```

---

## Common Issues & Solutions

### Issue: "Upload key certificate mismatch"
**Solution**: Make sure you're using the same keystore for all uploads

### Issue: "App rejected - Missing privacy policy"
**Solution**: Add privacy policy URL in Play Console → Policy → App content

### Issue: "App rejected - Data Safety form incomplete"
**Solution**: Complete Data Safety form, declare AdMob data collection

### Issue: "Version code already used"
**Solution**: Increment versionCode in `pubspec.yaml` (the number after `+`)

---

## Timeline Estimate

- **Account setup**: 1 day (waiting for payment processing)
- **App preparation**: 1-2 days (signing, assets, testing)
- **Store listing**: 1 day (writing descriptions, taking screenshots)
- **First review**: 1-7 days (Google's review process)
- **Total**: ~1-2 weeks from start to live

---

## Next Steps

1. ✅ Create keystore (DONE)
2. ⏳ Configure `build.gradle.kts` to use keystore
3. ⏳ Create `key.properties` file
4. ⏳ Set up Google Play Console account
5. ⏳ Build first release bundle
6. ⏳ Create app in Play Console
7. ⏳ Upload to Internal testing
8. ⏳ Complete store listing
9. ⏳ Submit for review

Good luck! 🚀

