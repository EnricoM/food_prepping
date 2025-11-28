# Using Your Keystore for App Updates

## Important: Use the SAME Keystore for All Versions

**Key Point**: You'll use the **exact same keystore** for every version of your app:
- Version 1.0.0 → Same keystore
- Version 1.0.1 → Same keystore
- Version 2.0.0 → Same keystore
- All future versions → Same keystore

**Why?** Google Play needs to verify that updates come from the same developer. If you use a different keystore, Play Console will reject the update.

---

## Backing Up to Google Drive

### Step 1: Encrypt the Keystore (Recommended)

Before uploading to Google Drive, encrypt it for extra security:

```bash
# Using zip with encryption
zip -e recipe_parser_keystore.zip /home/enrico/keystores/recipe_parser_release.keystore

# OR using 7zip (if installed)
7z a -p -mhe=on recipe_parser_keystore.7z /home/enrico/keystores/recipe_parser_release.keystore
```

**Important**: Remember the encryption password! Store it in a password manager.

### Step 2: Upload to Google Drive

1. Upload the encrypted `.zip` or `.7z` file to Google Drive
2. **OR** upload the keystore directly (it's already password-protected, but encryption adds extra security)
3. Store the encryption password separately (password manager)

### Step 3: Also Back Up key.properties Info

Create a secure note with:
- Keystore password
- Key alias: `recipeparser`
- Key password (if different from keystore password)
- Store this in a password manager (NOT in Google Drive)

---

## Using the Keystore on Different Machines

### On a New Laptop/Computer:

1. **Download the keystore from Google Drive**
   ```bash
   # If encrypted, decrypt first
   unzip recipe_parser_keystore.zip
   # OR
   7z x recipe_parser_keystore.7z
   ```

2. **Place it in a known location**
   ```bash
   mkdir -p ~/keystores
   cp recipe_parser_release.keystore ~/keystores/
   ```

3. **Create key.properties file**
   ```bash
   cd /path/to/your/project/android
   cp key.properties.template key.properties
   ```
   
   Edit `key.properties`:
   ```properties
   storePassword=YOUR_KEYSTORE_PASSWORD
   keyPassword=YOUR_KEY_PASSWORD
   keyAlias=recipeparser
   storeFile=/home/username/keystores/recipe_parser_release.keystore
   ```
   
   **Update the path** to match your new machine's path!

4. **Verify it works**
   ```bash
   flutter build apk --release
   ```

---

## Workflow for App Updates

### Every Time You Release a New Version:

1. **Increment version in `pubspec.yaml`**
   ```yaml
   version: 1.0.1+2  # versionName + versionCode
   ```
   - `1.0.1` = User-visible version
   - `+2` = Build number (must increase each time)

2. **Use the SAME keystore** (no changes needed)
   - Your `key.properties` is already configured
   - Your `build.gradle.kts` is already set up
   - Just build!

3. **Build the release bundle**
   ```bash
   flutter build appbundle --release
   ```

4. **Upload to Play Console**
   - Go to Play Console → Your App → Release → Production
   - Upload the new `app-release.aab`
   - Add release notes
   - Submit for review

**That's it!** The same keystore signs all versions.

---

## What Changes vs. What Stays the Same

### ✅ Stays the Same (for all versions):
- Keystore file (`recipe_parser_release.keystore`)
- Keystore password
- Key alias (`recipeparser`)
- Key password
- `key.properties` file (passwords stay the same)
- `build.gradle.kts` configuration

### 🔄 Changes Each Version:
- Version number in `pubspec.yaml` (must increment)
- The actual app code/features
- The AAB file you upload

---

## Security Best Practices

### ✅ DO:
- Encrypt keystore before uploading to cloud
- Store passwords in a password manager
- Keep multiple backups (cloud + offline)
- Use the same keystore for all versions
- Test your backup recovery process

### ❌ DON'T:
- Commit keystore to Git (already in `.gitignore`)
- Commit `key.properties` to Git (already in `.gitignore`)
- Share keystore or passwords
- Use different keystores for different versions
- Store passwords in plain text files

---

## Quick Reference: Update Workflow

```bash
# 1. Update version in pubspec.yaml
# version: 1.0.1+2

# 2. Build release bundle (uses same keystore automatically)
flutter build appbundle --release

# 3. Upload to Play Console
# File: build/app/outputs/bundle/release/app-release.aab

# 4. Done! Same keystore, new version.
```

---

## Troubleshooting

### "Upload key certificate mismatch"
- **Cause**: Using a different keystore than before
- **Fix**: Always use the same keystore file

### "Keystore file not found"
- **Cause**: Wrong path in `key.properties`
- **Fix**: Update `storeFile` path to match your machine

### "Keystore password was incorrect"
- **Cause**: Wrong password in `key.properties`
- **Fix**: Double-check passwords (no extra spaces)

---

## Summary

1. **Back up keystore** to Google Drive (encrypted recommended)
2. **Use SAME keystore** for all app versions
3. **Only change version number** in `pubspec.yaml` for updates
4. **Build and upload** - keystore handles signing automatically
5. **Keep passwords safe** in a password manager

The keystore is your "signature" - use it consistently for all versions! 🔐

