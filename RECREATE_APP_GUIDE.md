# Guide: Recreating App as Free with Ads

This guide helps you remove your current app from Play Console and create a new entry as a **free app with ads** from the start.

---

## ⚠️ Important Information to Note First

Before deleting, write down these details (you'll need them):

**Current Package Name:** `jeffs.cooking.recipe_parser`  
**AdMob App ID:** `ca-app-pub-5743498140441400~1769276614`  
**AdMob Ad Unit ID:** `ca-app-pub-5743498140441400/3104864428`

**Decision:** You can either:
- **Option A:** Use the same package name (simpler, but may need to wait)
- **Option B:** Use a new package name (cleaner, but need to update AdMob)

**Recommendation:** Use the same package name if possible (less work).

---

## Step 1: Remove Current App from Play Console

### Option 1: Unpublish (Recommended First Step)

1. **Go to Play Console** → Your app
2. **Left sidebar** → **"Policy"** → **"App content"**
3. **"Unpublish app"** → Click it
4. Confirm unpublishing

**Note:** This removes it from the store but keeps the app entry.

### Option 2: Delete App (Permanent)

⚠️ **Warning:** This is permanent and cannot be undone!

1. **Go to Play Console** → Your app
2. **Left sidebar** → **"Settings"** (gear icon)
3. **"Developer account"** → Scroll down
4. **"Delete app"** → Enter app name to confirm
5. Click **"Delete"**

**Important:** 
- You may need to wait 24-48 hours before reusing the same package name
- All data, reviews, and stats will be lost
- Consider unpublishing first to test

---

## Step 2: Create New App Entry

1. **Go to Play Console** → **"All apps"**
2. Click **"Create app"** (or **"Add new app"**)
3. Fill in the form:

### App Details:

**App name:** `Recipe Parser` (or your preferred name)

**Default language:** Your language (e.g., English)

**App or game:** Select **"App"**

**Free or paid:** Select **"Free"** ✅ (This is key!)

**Declarations:**
- ✅ Check **"Contains ads"** (since you're using AdMob)
- Leave other boxes unchecked unless applicable

4. Click **"Create app"**

---

## Step 3: Set Up App as Free with Ads

### In the New App Entry:

1. **Go to "Store presence"** → **"Store listing"**

2. **Pricing & distribution:**
   - **Price:** Free ✅
   - **Contains ads:** Yes ✅
   - **Ads:** Select **"Google AdMob"**

3. **Complete other sections:**
   - App icon
   - Screenshots
   - Short description
   - Full description
   - Privacy policy URL

---

## Step 4: Package Name Decision

### Option A: Use Same Package Name (Recommended)

**Pros:**
- ✅ No code changes needed
- ✅ AdMob already configured
- ✅ Keystore already set up

**Cons:**
- ⚠️ May need to wait 24-48 hours after deletion
- ⚠️ If it's still in "unpublished" state, you might need to wait

**Steps:**
1. When creating the app, use: `jeffs.cooking.recipe_parser`
2. If you get an error that it's taken, wait 24-48 hours
3. Your existing AdMob setup will work immediately

### Option B: Use New Package Name

**Pros:**
- ✅ Can create immediately
- ✅ Fresh start

**Cons:**
- ❌ Need to update `build.gradle.kts`
- ❌ Need to update AdMob with new package name
- ❌ Need to update `AndroidManifest.xml` if namespace changes

**Steps if choosing new package name:**

1. **Update `android/app/build.gradle.kts`:**
   ```kotlin
   applicationId = "your.new.package.name"
   namespace = "your.new.package.name"  // Update this too
   ```

2. **Update AdMob:**
   - Go to AdMob → Your app
   - Add new Android app with new package name
   - Get new Ad Unit ID (or reuse existing if allowed)

3. **Update `AndroidManifest.xml`:**
   - Update AdMob App ID if you created a new app in AdMob

---

## Step 5: Upload Your App Bundle

1. **Build release bundle:**
   ```bash
   flutter build appbundle --release
   ```

2. **Go to Play Console** → Your new app
3. **"Production"** → **"Create new release"**
4. **Upload** the `.aab` file from `build/app/outputs/bundle/release/`
5. **Complete release notes**
6. **Review and roll out**

---

## Step 6: Public Merchant Profile (Minimal)

Since it's a **free app with ads**, you only need:

1. **Go to "Settings"** → **"Developer account"** → **"Public merchant profile"**

2. **Fill in:**
   - **Developer Name:** `Recipe Parser` (brand name, not your real name)
   - **Developer Email:** `recipeparser.support@gmail.com` (dedicated support email)
   - **Website:** Your GitHub Pages or Google Sites URL (optional)
   - **Phone:** Leave blank
   - **Address:** Leave blank ✅ (usually not required for free apps)

3. **Save**

---

## Step 7: Update AdMob (If Needed)

### If Using Same Package Name:
- ✅ No changes needed
- Your existing AdMob app should work

### If Using New Package Name:
1. **Go to AdMob** → **"Apps"**
2. **"Add app"** → **"Android"**
3. Enter new package name
4. Link to existing AdMob account or create new
5. Get new Ad Unit ID and update your code

---

## Checklist

Before you start:
- [ ] Note down current package name: `jeffs.cooking.recipe_parser`
- [ ] Note down AdMob App ID: `ca-app-pub-5743498140441400~1769276614`
- [ ] Note down AdMob Ad Unit ID: `ca-app-pub-5743498140441400/3104864428`
- [ ] Decide: Same package name or new one?

After creating new app:
- [ ] App created as **"Free"** ✅
- [ ] **"Contains ads"** checked ✅
- [ ] Package name set (same or new)
- [ ] Public merchant profile filled (name + email only)
- [ ] App bundle uploaded
- [ ] AdMob configured (if new package name)

---

## Troubleshooting

### "Package name already exists"
- **Solution:** Wait 24-48 hours after deleting the old app
- Or use a new package name

### "Cannot delete app"
- **Solution:** Unpublish first, then delete
- Some apps can't be deleted if they have active subscriptions

### AdMob not working
- **Solution:** Verify package name matches in AdMob
- Check AdMob App ID in `AndroidManifest.xml`
- Ensure app is linked in AdMob

---

## Summary

**Recommended Approach:**
1. ✅ Unpublish current app (or delete if you're sure)
2. ✅ Wait 24 hours (if deleting)
3. ✅ Create new app as **"Free"** with **"Contains ads"** checked
4. ✅ Use same package name: `jeffs.cooking.recipe_parser`
5. ✅ Fill minimal public merchant profile (name + email only)
6. ✅ Upload app bundle
7. ✅ No code changes needed if using same package name!

This should give you a clean setup as a free app with ads, with minimal merchant profile requirements.

