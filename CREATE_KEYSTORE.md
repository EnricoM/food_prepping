# Creating Your Release Keystore

## Step-by-Step Guide

### Step 1: Create the Keystore Directory
```bash
mkdir -p /home/enrico/keystores
```

### Step 2: Generate the Keystore
Run this command (it will ask you for passwords and information):

```bash
keytool -genkeypair -v -keystore /home/enrico/keystores/recipe_parser_release.keystore \
  -alias recipeparser \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000
```

**What you'll be asked:**
1. **Keystore password**: Create a strong password (you'll need this later)
2. **Re-enter password**: Confirm the password
3. **First and last name**: Your name or organization name
4. **Organizational unit**: (optional, press Enter to skip)
5. **Organization**: Your organization name (optional)
6. **City or locality**: Your city
7. **State or province**: Your state/province
8. **Country code**: Two-letter code (e.g., US, GB, NL)
9. **Confirm**: Type "yes" to confirm
10. **Key password**: 
    - Press Enter to use the same password as keystore
    - OR enter a different password (you'll need to remember this too)

### Step 3: Verify the Keystore
```bash
ls -lh /home/enrico/keystores/recipe_parser_release.keystore
```

You should see a file around 2-3 KB in size.

### Step 4: Create key.properties File
Create `android/key.properties` with your keystore information:

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=recipeparser
storeFile=/home/enrico/keystores/recipe_parser_release.keystore
```

**⚠️ IMPORTANT**: 
- Replace `YOUR_KEYSTORE_PASSWORD` with the password you entered in Step 2
- Replace `YOUR_KEY_PASSWORD` with the key password (same as keystore if you pressed Enter)
- Use the **absolute path** (starting with `/home/enrico/...`)

### Step 5: Update build.gradle.kts
✅ **Already done!** The build file is already configured to:
- Load keystore properties from `key.properties`
- Use the release signing config when keystore exists
- Fall back to debug signing if keystore is not found

No action needed - just make sure `key.properties` is set up correctly (Step 2).

## Security Notes

- **Never commit** `key.properties` or the keystore file to Git
- **Back up** the keystore file to a secure location (encrypted cloud storage)
- **Remember** your passwords - store them in a password manager
- With **Google Play App Signing**, if you lose the upload key, you can request a reset

## Next Steps

After creating the keystore:
1. I'll create the `key.properties` file (you'll need to add your passwords)
2. I'll update `build.gradle.kts` to use the keystore
3. You can then build a signed release bundle

