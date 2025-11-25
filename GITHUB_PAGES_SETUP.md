# Setting Up GitHub Pages for app-ads.txt

This guide will help you set up GitHub Pages to host your `app-ads.txt` file for AdMob verification.

---

## Step 1: Create the app-ads.txt File

✅ **Already done!** I've created `app-ads.txt` in your project directory with your Publisher ID.

**File location:** `/home/enrico/StudioProjects/food_prepping/app-ads.txt`

**Content:**
```
google.com, pub-5743498140441400, DIRECT, f08c47fec0942fa0
```

---

## Step 2: Create a GitHub Repository

1. **Go to GitHub:**
   - Visit [github.com](https://github.com)
   - Sign in (or create an account if you don't have one)

2. **Create a new repository:**
   - Click the **"+"** icon (top right) → **"New repository"**
   - **Repository name:** `recipe-parser-app-ads` (or any name you like)
   - **Description:** "app-ads.txt for Recipe Parser app"
   - **Visibility:** 
     - ✅ **Public** (required for GitHub Pages free tier)
     - OR **Private** (if you have GitHub Pro, but Public is fine for this)
   - **DO NOT** check "Add a README file" (we'll add files manually)
   - Click **"Create repository"**

---

## Step 3: Upload app-ads.txt to GitHub

You have two options:

### Option A: Using GitHub Web Interface (Easiest)

1. **On the new repository page**, you'll see "Quick setup" instructions
2. Click **"uploading an existing file"** link
3. **Drag and drop** the `app-ads.txt` file from your computer
   - Or click **"choose your files"** and select it
4. **Commit message:** "Add app-ads.txt for AdMob verification"
5. Click **"Commit changes"**

### Option B: Using Git Command Line

If you prefer command line:

```bash
cd /home/enrico/StudioProjects/food_prepping

# Initialize git (if not already done)
git init

# Add the file
git add app-ads.txt

# Commit
git commit -m "Add app-ads.txt for AdMob verification"

# Add your GitHub repository as remote (replace YOUR_USERNAME and REPO_NAME)
git remote add origin https://github.com/YOUR_USERNAME/recipe-parser-app-ads.git

# Push to GitHub
git branch -M main
git push -u origin main
```

**Note:** Replace `YOUR_USERNAME` with your GitHub username and `REPO_NAME` with your repository name.

---

## Step 4: Enable GitHub Pages

1. **In your GitHub repository**, click **"Settings"** (top menu)

2. **Scroll down** to **"Pages"** (left sidebar)

3. **Under "Source":**
   - Select **"Deploy from a branch"**
   - **Branch:** `main` (or `master` if that's your default)
   - **Folder:** `/ (root)`
   - Click **"Save"**

4. **Wait 1-2 minutes** for GitHub Pages to deploy 

5. **Your site URL will be:**
   ```
   https://YOUR_USERNAME.github.io/recipe-parser-app-ads/
   ```

---

## Step 5: Verify app-ads.txt is Accessible

1. **Open your browser** and go to:
   ```
   https://YOUR_USERNAME.github.io/recipe-parser-app-ads/app-ads.txt
   ```

2. **You should see:**
   ```
   google.com, pub-5743498140441400, DIRECT, f08c47fec0942fa0
   ```

3. **If you see the text** (not an error page), it's working! ✅

---

## Step 6: Update AdMob

### ⚠️ Important: App-ads.txt Section May Not Be Visible Yet

**If you can't find the app-ads.txt section**, it's likely because:
- Your app isn't published to Play Store yet
- The app isn't linked to a store in AdMob
- AdMob discovers app-ads.txt automatically from your Play Store listing

**Don't worry!** You can still set it up now, and AdMob will verify it once your app is published.

### Option 1: Try to Find It (If Available)

1. **Go to AdMob Console:**
   - Visit [apps.admob.com](https://apps.admob.com)
   - Sign in

2. **Navigate to your app:**
   - In the **left sidebar**, click **"Apps"**
   - Click on **"Recipe Parser"** (your app name)

3. **Look for these sections:**
   - **"App settings"** or **"Settings"** tab
   - **"App stores"** section
   - **"App information"** section
   - Scroll through all tabs/sections

4. **If you find "App-ads.txt" or "Website URL" field:**
   - Paste: `https://YOUR_USERNAME.github.io/recipe-parser-app-ads`
   - Click **"Save"**

### Option 2: Add Website to Play Store Listing (Recommended)

**This is the main way AdMob discovers app-ads.txt:**

1. **Go to Google Play Console:**
   - Visit [play.google.com/console](https://play.google.com/console)
   - Select your app: **Recipe Parser**

2. **Add Developer Website:**
   - Go to **"Store presence"** → **"Store listing"**
   - Find **"Website"** or **"Developer website"** field
   - Enter: `https://YOUR_USERNAME.github.io/recipe-parser-app-ads`
   - Click **"Save"**

3. **AdMob will automatically discover it:**
   - Once your app is published, AdMob will check this website
   - It will look for `app-ads.txt` at the root
   - Verification happens automatically (24-48 hours)

### Option 3: Link App to Play Store in AdMob

If your app is published:

1. **In AdMob:**
   - Apps → Recipe Parser
   - Look for **"App stores"** section
   - Click **"Add store"** or **"Link to Play Store"**
   - Search for your app and link it

2. **After linking:**
   - The app-ads.txt section might appear
   - Or AdMob will discover it from your Play Store listing

### Option 4: Wait Until App is Published

**If you can't find the section now:**
- ✅ Set up GitHub Pages (you're doing this now)
- ✅ Add website to Play Store listing (when you publish)
- ✅ AdMob will verify automatically after publishing

**The warning you saw is just a notification** - it won't block your ads from working.

### What to Do Right Now:

**Since you can't find the section in AdMob:**

1. ✅ **Complete GitHub Pages setup** (Steps 1-5 above)
2. ✅ **Verify the file is accessible** at: `https://YOUR_USERNAME.github.io/recipe-parser-app-ads/app-ads.txt`
3. ⏳ **Wait until you publish to Play Store**
4. 📝 **Add website to Play Store listing** (Store presence → Store listing → Website)
5. ✅ **AdMob will discover it automatically** after publishing

**The warning is just informational** - your ads will still work!

### What the URL Should Look Like:

**Correct:**
```
https://enrico.github.io/recipe-parser-app-ads
```

**Wrong:**
```
https://enrico.github.io/recipe-parser-app-ads/app-ads.txt  ❌
enrico.github.io/recipe-parser-app-ads  ❌ (missing https://)
```

---

## Quick Checklist

- [ ] Created GitHub account (if needed)
- [ ] Created new repository
- [ ] Uploaded `app-ads.txt` file
- [ ] Enabled GitHub Pages
- [ ] Verified file is accessible at: `https://YOUR_USERNAME.github.io/recipe-parser-app-ads/app-ads.txt`
- [ ] Updated AdMob with website URL
- [ ] Waiting for AdMob verification (24-48 hours)

---

## Troubleshooting

### "404 Not Found" when accessing app-ads.txt

**Possible causes:**
- GitHub Pages hasn't finished deploying (wait 2-3 minutes)
- File is in wrong location (must be in root, not a subfolder)
- Wrong branch selected in Pages settings (should be `main` or `master`)

**Fix:**
- Check repository → Settings → Pages → verify branch is `main`
- Make sure `app-ads.txt` is in the root of the repository
- Wait a few minutes and try again

### "Repository not found"

- Make sure repository is **Public** (or you have GitHub Pro for private repos)
- Check the URL is correct
- Make sure GitHub Pages is enabled

### AdMob still shows "Unreviewed"

- AdMob checks every 24-48 hours, be patient
- Make sure the file is accessible (test the URL in browser)
- Verify the file content is correct (no extra spaces, correct Publisher ID)
- Make sure you entered the base URL (without `/app-ads.txt`) in AdMob

---

## Your Information

**Publisher ID:** `5743498140441400`  
**App ID:** `ca-app-pub-5743498140441400~1769276614`  
**app-ads.txt content:**
```
google.com, pub-5743498140441400, DIRECT, f08c47fec0942fa0
```

---

## Need Help?

If you get stuck:
1. Check that the file is accessible in your browser
2. Verify GitHub Pages is enabled in repository settings
3. Make sure the repository is public
4. Wait a few minutes after enabling Pages (deployment takes time)

Once it's set up, you're done! AdMob will verify within 24-48 hours. 🎉

