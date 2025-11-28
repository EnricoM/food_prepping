# Privacy Policy Guide for Apps with Ads

## ✅ Yes, You Need a Privacy Policy!

**Google Play Store Requirement:**
- Apps with ads (AdMob) **MUST** have a privacy policy URL
- Required for Data Safety form completion
- Required for app approval

**Your app uses:**
- ✅ Google Mobile Ads (AdMob) - collects Advertising ID
- ✅ Recipe parsing from URLs
- ✅ Local storage (Hive) - recipes, inventory, shopping lists
- ✅ Optional: Barcode scanning, receipt scanning

---

## What Your Privacy Policy Must Include

### 1. **Data Collection**
- **Advertising ID**: Collected by AdMob for personalized ads
- **App Usage**: If you track analytics (optional)
- **User Content**: Recipes, shopping lists stored locally

### 2. **Data Usage**
- How you use collected data
- Why you collect it
- Who has access

### 3. **Data Sharing**
- AdMob/Google (for ads)
- Any third-party services

### 4. **User Rights**
- How to opt-out
- How to delete data
- Contact information

### 5. **Contact Information**
- Your email or contact form
- Your name/organization

---

## How to Create a Privacy Policy

### Option 1: Use a Privacy Policy Generator (Easiest) ⭐ Recommended

**Free Generators:**
1. **PrivacyPolicyGenerator.com**
   - https://www.privacypolicygenerator.com/
   - Free, generates HTML
   - Includes AdMob section

2. **FreePrivacyPolicy.com**
   - https://www.freeprivacypolicy.com/
   - Free, customizable
   - AdMob templates

3. **Termly**
   - https://termly.io/products/privacy-policy-generator/
   - Free tier available

**Steps:**
1. Go to generator website
2. Fill in your app details
3. Select "AdMob/Google Ads" as data collection
4. Generate policy
5. Copy the HTML/text
6. Host it (see hosting options below)

### Option 2: Use a Template

I can create a template for you based on your app's features. Let me know if you want this.

### Option 3: Write Your Own

If you write your own, make sure to include all required sections above.

---

## Where to Host Your Privacy Policy

### Option 1: GitHub Pages (Free, Easy) ⭐ Recommended

1. **Create a GitHub repository:**
   ```bash
   # Create a new repo on GitHub (e.g., "recipe-parser-privacy")
   ```

2. **Create privacy-policy.html:**
   ```html
   <!DOCTYPE html>
   <html>
   <head>
       <title>Privacy Policy - Recipe Parser</title>
       <meta charset="utf-8">
       <meta name="viewport" content="width=device-width, initial-scale=1">
   </head>
   <body>
       <h1>Privacy Policy</h1>
       <!-- Paste your privacy policy content here -->
   </body>
   </html>
   ```

3. **Enable GitHub Pages:**
   - Go to repo Settings → Pages
   - Select main branch
   - Your URL: `https://yourusername.github.io/recipe-parser-privacy/privacy-policy.html`

### Option 2: Google Sites (Free)

1. Go to https://sites.google.com
2. Create a new site
3. Paste your privacy policy
4. Publish
5. Get the public URL

### Option 3: Your Own Website

If you have a website, create a `/privacy-policy` page.

### Option 4: Firebase Hosting (Free)

If you're using Firebase, you can host it there.

---

## Privacy Policy Template (Basic)

Here's a basic template you can customize:

```html
<!DOCTYPE html>
<html>
<head>
    <title>Privacy Policy - Recipe Parser</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        body { font-family: Arial, sans-serif; max-width: 800px; margin: 40px auto; padding: 20px; line-height: 1.6; }
        h1 { color: #333; }
        h2 { color: #666; margin-top: 30px; }
    </style>
</head>
<body>
    <h1>Privacy Policy</h1>
    <p><strong>Last updated:</strong> [DATE]</p>
    
    <h2>1. Introduction</h2>
    <p>Recipe Parser ("we", "our", or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and share information when you use our mobile application.</p>
    
    <h2>2. Information We Collect</h2>
    
    <h3>2.1 Advertising Data</h3>
    <p>We use Google AdMob to display advertisements in our app. AdMob may collect and use the following information:</p>
    <ul>
        <li><strong>Advertising ID:</strong> A unique identifier used for advertising purposes</li>
        <li><strong>Device Information:</strong> Device type, operating system, and app version</li>
        <li><strong>Location Data:</strong> General location (if permitted)</li>
    </ul>
    <p>This data is used to show you relevant advertisements. You can opt-out of personalized ads in your device settings.</p>
    
    <h3>2.2 App Data</h3>
    <p>The following data is stored locally on your device:</p>
    <ul>
        <li>Recipes you save</li>
        <li>Shopping lists</li>
        <li>Inventory items</li>
        <li>Meal plans</li>
    </ul>
    <p>This data is stored locally and is not transmitted to our servers.</p>
    
    <h3>2.3 Recipe URLs</h3>
    <p>When you parse a recipe from a URL, we fetch the recipe data from that website. We do not store the URLs you visit.</p>
    
    <h2>3. How We Use Your Information</h2>
    <ul>
        <li>To provide and improve our services</li>
        <li>To display relevant advertisements</li>
        <li>To analyze app usage and performance</li>
    </ul>
    
    <h2>4. Data Sharing</h2>
    <p>We share information with the following third parties:</p>
    <ul>
        <li><strong>Google AdMob:</strong> For advertising services. See Google's Privacy Policy: https://policies.google.com/privacy</li>
    </ul>
    <p>We do not sell your personal information.</p>
    
    <h2>5. Your Rights</h2>
    <p>You have the right to:</p>
    <ul>
        <li>Opt-out of personalized ads in your device settings</li>
        <li>Delete app data by uninstalling the app</li>
        <li>Request information about data we collect</li>
    </ul>
    
    <h2>6. Data Security</h2>
    <p>We implement appropriate security measures to protect your information. However, no method of transmission over the internet is 100% secure.</p>
    
    <h2>7. Children's Privacy</h2>
    <p>Our app is not intended for children under 13. We do not knowingly collect information from children.</p>
    
    <h2>8. Changes to This Policy</h2>
    <p>We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new policy on this page.</p>
    
    <h2>9. Contact Us</h2>
    <p>If you have questions about this Privacy Policy, please contact us at:</p>
    <p>
        Email: [YOUR_EMAIL]<br>
        [Your Name/Organization]
    </p>
</body>
</html>
```

---

## Quick Setup Steps

1. **Generate/Create Privacy Policy**
   - Use a generator OR customize the template above

2. **Host It**
   - GitHub Pages (easiest free option)
   - Google Sites
   - Your website

3. **Get the URL**
   - Example: `https://yourusername.github.io/recipe-parser-privacy/privacy-policy.html`

4. **Add to Play Console**
   - Go to: Policy → App content → Privacy policy
   - Paste the URL
   - Save

5. **Update in Data Safety Form**
   - Declare Advertising ID collection
   - Link to privacy policy

---

## What to Declare in Play Console Data Safety

When filling out the Data Safety form, declare:

✅ **Data Collected:**
- Advertising ID (collected, shared with AdMob)
- App activity (if you track usage)
- Device ID (collected by AdMob)

✅ **Data Usage:**
- Advertising or marketing
- Analytics (if applicable)

✅ **Data Sharing:**
- Shared with AdMob/Google

---

## Checklist

- [ ] Privacy policy created
- [ ] Privacy policy hosted (has a public URL)
- [ ] URL added to Play Console → Policy → App content
- [ ] Data Safety form completed
- [ ] Advertising ID declared in Data Safety
- [ ] Contact information included in policy

---

## Need Help?

If you want me to:
1. Create a custom privacy policy template for your app
2. Help set up GitHub Pages hosting
3. Review your privacy policy

Just let me know! 🚀

