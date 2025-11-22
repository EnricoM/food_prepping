# Internal Testing Setup Guide

This guide walks you through setting up internal testing in Google Play Console.

---

## Prerequisites

- ✅ Google Play Console account created
- ✅ App created in Play Console
- ✅ Keystore configured
- ✅ Real AdMob IDs configured

---

## Step 0: Enable Google Play App Signing (IMPORTANT - Do This First!)

**⚠️ Do this BEFORE uploading your first AAB!**

Google Play App Signing is the recommended approach where Google manages your app signing key. This is safer and allows you to reset your upload key if lost.

### When to Set It Up:

**Option A: Proactively (Recommended)**
- Do this now, before uploading anything
- Go to: **Release → Setup → App signing**
- Click "Let Google manage and protect your app signing key"
- Select **"Yes"**
- Upload your upload key certificate (see below)

**Option B: When Uploading First AAB**
- Google will prompt you when you upload your first AAB
- You'll see a popup asking about app signing
- Select **"Yes, let Google manage my app signing key"**

### How to Get Your Upload Key Certificate:

If you need to upload the certificate manually:

```bash
keytool -export -rfc -keystore ~/keystores/recipe_parser_release.keystore \
  -alias recipeparser -file upload_certificate.pem
```

Then upload `upload_certificate.pem` in Play Console.

**Note:** If you choose Option B (when uploading), Google will extract the certificate from your AAB automatically, so you don't need to do this step.

---

## Step 1: Build Release AAB

First, make sure you have the latest release build with your real AdMob IDs:

```bash
cd /home/enrico/StudioProjects/food_prepping
flutter build appbundle --release
```

**Output location:** `build/app/outputs/bundle/release/app-release.aab`

**Note:** This build includes:
- Your real AdMob App ID
- Your real banner ad unit ID
- Signed with your release keystore

---

## Step 2: Access Play Console

1. Go to [Google Play Console](https://play.google.com/console)
2. Sign in with your developer account
3. Select your app: **Recipe Parser**

---

## Step 3: Navigate to Internal Testing

**Exact navigation path:**

1. **Left sidebar** → Click **"Release"** (or "Production" - both work)
2. **Top menu tabs** → Click **"Testing"** (you'll see tabs: "Production", "Testing", "Release dashboard")
3. **Under Testing section** → Click **"Internal testing"** (you'll see: Internal testing, Closed testing, Open testing)

**Visual guide:**
```
Play Console
├── Left Sidebar
│   └── Release ← Click here
│
└── Main Area (after clicking Release)
    ├── [Production] [Testing] [Release dashboard] ← Click "Testing"
    │
    └── After clicking Testing:
        ├── Internal testing ← Click here
        ├── Closed testing
        └── Open testing
```

**Alternative path (sometimes easier):**
- Left sidebar → **"Testing"** → **"Internal testing"**

You should see a page that says "No releases yet" or similar.

---

## Step 4: Create Internal Testing Release

**Finding the upload button:**

1. Once you're in **Internal testing**, look for:
   - A big **"Create new release"** button (usually green/blue, top right or center)
   - OR if you see "No releases yet" → Click **"Create new release"** button
   - OR look for a **"+"** button or **"New release"** link

2. Click it, and you'll see a form with:
   - **Release name** (optional, e.g., "Internal Test v1.0")
   - **Release notes** (what's new - e.g., "Initial release with AdMob integration")
   - **App bundles and APKs** section ← **This is where you upload!**

---

## Step 5: Upload Your AAB

**Where to find the upload button:**

1. In the **"App bundles and APKs"** section, you'll see:
   - A button that says **"Upload"** or **"Browse files"** or **"Add from library"**
   - OR a drag-and-drop area
   - OR a **"+"** icon

2. Click **"Upload"** (or drag-and-drop your AAB file)

3. **File location on your computer:**
   ```
   /home/enrico/StudioProjects/food_prepping/build/app/outputs/bundle/release/app-release.aab
   ```

4. Select the file and click **"Open"** (or just drag it into the upload area)

5. Wait for upload to complete (may take 1-2 minutes)
   - You'll see a progress bar
   - Status will change from "Uploading" → "Processing" → "Ready"

6. Google will validate the bundle automatically

**What Google checks:**
- ✅ Bundle is properly signed
- ✅ No obvious errors
- ✅ Version code is valid
- ✅ App signing setup (if not done yet, Google will prompt you here)

---

## Step 6: Add Release Notes

1. In the **"Release notes"** field, add something like:
   ```
   Initial release
   - Recipe parsing from websites
   - Domain discovery
   - AdMob integration
   ```

2. Click **"Save"** (NOT "Review release" yet)

---

## Step 7: Set Up Testers

1. Still in **Internal testing**, click the **"Testers"** tab (at the top)
2. You'll see two options:
   - **Email addresses** (simple, recommended for first test)
   - **Google Groups** (for multiple testers)

3. **Option A: Email addresses (Easiest)**
   - Click **"Create email list"**
   - Name it: "My Testers" (or any name)
   - Add your email address
   - Click **"Save"**
   - Select this list in the **"Testers"** dropdown

4. **Option B: Google Groups**
   - If you have a Google Group, select it from the dropdown

---

## Step 8: Get Your Testing Link

1. After setting up testers, you'll see a **"Copy link"** button
2. Click it to copy the testing link
3. The link looks like: `https://play.google.com/apps/internaltest/XXXXXXXXXXXXXXXX`

**Important:** This link is what you'll use to install the app on your phone!

---

## Step 9: Review and Roll Out

1. Go back to the **"Releases"** tab in Internal testing
2. You should see your release with status "Draft"
3. Click **"Review release"**
4. Review the summary:
   - App bundle version
   - Release notes
   - Testers
5. Click **"Start rollout to Internal testing"**

**Note:** Internal testing releases are available almost instantly (within minutes).

---

## Step 10: Install on Your Phone

1. **On your Android phone:**
   - Open the testing link you copied (or send it to yourself)
   - You'll see a page saying "You're a tester"
   - Click **"Download it on Google Play"** button
   - This opens the Play Store app
   - Click **"Install"**

2. **Alternative:** If the link doesn't work:
   - Make sure you're signed into the same Google account on your phone
   - The account must match the email you added as a tester
   - Try opening the link in Chrome on your phone

---

## Step 11: Test Your App

Once installed, test these key features:

- [ ] App opens without crashing
- [ ] Recipe parsing works
- [ ] Domain discovery works
- [ ] Ads are displaying (they'll be test ads until published)
- [ ] Navigation works
- [ ] Settings work
- [ ] Premium upgrade screen works

**What to look for:**
- ✅ No crashes
- ✅ Ads load (even if test ads)
- ✅ All features work as expected
- ✅ App feels stable

---

## Step 12: If Everything Works - Publish to Production

If testing is successful:

1. Go to **Release → Production**
2. Click **"Create new release"**
3. Upload the same AAB (or rebuild if you made fixes)
4. Add release notes
5. Complete all required sections (store listing, content rating, privacy policy)
6. Submit for review

**If you find issues:**
- Fix the issues
- Rebuild: `flutter build appbundle --release`
- Upload new AAB to Internal testing
- Test again
- Repeat until everything works

---

## Troubleshooting

### "You're not a tester" error
- Make sure you added your email to the testers list
- Make sure you're signed into the same Google account on your phone
- Wait a few minutes after adding yourself as a tester

### App won't install
- Make sure you uninstalled any previous debug versions
- Check that your phone meets minimum Android version requirements
- Try clearing Play Store cache

### Ads not showing
- This is normal! Real ad units show test ads until the app is published
- As long as you see some ad (even test ads), it's working correctly

### Can't find Internal testing
- Make sure you've created the app in Play Console first
- Check that you're in the correct app
- Internal testing is under: Release → Testing → Internal testing

---

## Quick Checklist

- [ ] Built release AAB: `flutter build appbundle --release`
- [ ] Uploaded AAB to Internal testing
- [ ] Added release notes
- [ ] Added myself as tester
- [ ] Copied testing link
- [ ] Installed app on phone from testing link
- [ ] Tested all major features
- [ ] Everything works ✅

---

## Next Steps

Once internal testing is successful:
1. Complete store listing (screenshots, description, etc.)
2. Complete content rating questionnaire
3. Add privacy policy URL
4. Complete Data Safety form
5. Submit to Production

See `PLAY_STORE_PUBLISHING_GUIDE.md` for complete publishing steps.

