# Keystore Setup - Next Steps

## ✅ What I've Done

1. ✅ Created keystore directory: `/home/enrico/keystores/`
2. ✅ Created `create_keystore.sh` script for easy keystore creation
3. ✅ Updated `build.gradle.kts` to use the keystore (when it exists)
4. ✅ Created `key.properties.template` file
5. ✅ Added keystore files to `.gitignore` (security)

## 📝 What You Need to Do

### Step 1: Create the Keystore

Run this command:
```bash
./create_keystore.sh
```

**OR** run manually:
```bash
keytool -genkeypair -v \
  -keystore /home/enrico/keystores/recipe_parser_release.keystore \
  -alias recipeparser \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000
```

**When prompted:**
- **Keystore password**: Create a strong password (save it!)
- **Re-enter password**: Confirm
- **Name/Organization**: Enter your details
- **Key password**: Press Enter to use same as keystore, OR enter different password

### Step 2: Create key.properties File

```bash
# Copy the template
cp android/key.properties.template android/key.properties

# Edit the file and replace the placeholders with your actual passwords
nano android/key.properties
# OR use your preferred editor
```

Replace:
- `YOUR_KEYSTORE_PASSWORD_HERE` → Your keystore password
- `YOUR_KEY_PASSWORD_HERE` → Your key password (same as keystore if you pressed Enter)

### Step 3: Verify Setup

```bash
# Check keystore exists
ls -lh /home/enrico/keystores/recipe_parser_release.keystore

# Check key.properties exists
ls -lh android/key.properties
```

### Step 4: Test the Build

```bash
# Build a release APK to test signing
flutter build apk --release

# If successful, you're ready to build the app bundle for Play Store
flutter build appbundle --release
```

## 🔒 Security Reminders

- ✅ `key.properties` is in `.gitignore` - won't be committed
- ✅ Keystore files are in `.gitignore` - won't be committed
- ⚠️ **Back up** your keystore file to secure location (encrypted cloud storage)
- ⚠️ **Store passwords** in a password manager
- ⚠️ **Never share** keystore or passwords

## 🎯 After Setup

Once the keystore is created and configured:
1. You can build signed release builds
2. You can create app bundles for Play Store
3. You're ready for Google Play App Signing setup

## ❓ Troubleshooting

**Error: "key.properties not found"**
- Make sure you created `android/key.properties` from the template
- Check the file path is correct

**Error: "Keystore password was incorrect"**
- Double-check your passwords in `key.properties`
- Make sure there are no extra spaces

**Error: "Keystore file not found"**
- Verify the keystore exists: `ls /home/enrico/keystores/recipe_parser_release.keystore`
- Check the path in `key.properties` matches

