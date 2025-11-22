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

1. **Go to AdMob Console:**
   - Visit [apps.admob.com](https://apps.admob.com)
   - Sign in

2. **Navigate to your app:**
   - Click **"Apps"** → Select **"Recipe Parser"**

3. **Update app settings:**
   - Click **"App settings"** (or the settings icon)
   - Scroll to **"App-ads.txt"** section
   - **Website URL:** Enter your GitHub Pages URL:
     ```
     https://YOUR_USERNAME.github.io/recipe-parser-app-ads
     ```
     (Don't include `/app-ads.txt` - just the base URL)
   - Click **"Save"**

4. **Wait for verification:**
   - AdMob checks every 24-48 hours
   - Status will change from "Unreviewed" to "Verified"
   - You'll get an email when it's verified

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

