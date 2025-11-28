# Setting Up key.properties

## What is key.properties?

The `key.properties` file stores your keystore configuration so Gradle can automatically sign your release builds. It contains:
- Keystore password
- Key password  
- Key alias
- Path to keystore file

## Step-by-Step Setup

### Step 1: File Already Created ✅

I've created `android/key.properties` from the template. Now you need to fill in your actual passwords.

### Step 2: Edit key.properties

Open the file in your editor:

```bash
# Using nano (terminal editor)
nano android/key.properties

# OR using your IDE/editor
code android/key.properties
# OR
gedit android/key.properties
```

### Step 3: Replace the Placeholders

The file currently looks like this:

```properties
storePassword=YOUR_KEYSTORE_PASSWORD_HERE
keyPassword=YOUR_KEY_PASSWORD_HERE
keyAlias=recipeparser
storeFile=/home/enrico/keystores/recipe_parser_release.keystore
```

**Replace:**
- `YOUR_KEYSTORE_PASSWORD_HERE` → The password you entered when creating the keystore
- `YOUR_KEY_PASSWORD_HERE` → The key password (same as keystore password if you pressed Enter, or the different password you entered)

**Keep as-is:**
- `keyAlias=recipeparser` (this is correct)
- `storeFile=/home/enrico/keystores/recipe_parser_release.keystore` (verify this path is correct)

### Step 4: Final File Should Look Like

```properties
storePassword=MySecurePassword123!
keyPassword=MySecurePassword123!
keyAlias=recipeparser
storeFile=/home/enrico/keystores/recipe_parser_release.keystore
```

**Important:**
- No quotes around passwords
- No spaces before/after the `=` sign
- Use the exact passwords you used when creating the keystore

### Step 5: Verify the Setup

```bash
# Check the file exists and has content
cat android/key.properties

# Verify keystore path is correct
ls -lh /home/enrico/keystores/recipe_parser_release.keystore
```

### Step 6: Test It Works

```bash
# Try building a release APK
flutter build apk --release
```

If it builds successfully, your `key.properties` is configured correctly! ✅

---

## Common Questions

### Q: What if I used the same password for keystore and key?
**A:** That's fine! Just use the same password for both `storePassword` and `keyPassword`.

### Q: What if I forgot my password?
**A:** You'll need to create a new keystore. The old one can't be recovered without the password.

### Q: Can I change the keystore path?
**A:** Yes, just update `storeFile=` to point to wherever you stored the keystore. Use absolute path (starting with `/`).

### Q: Is this file secure?
**A:** Yes! It's in `.gitignore`, so it won't be committed to Git. But still:
- Don't share it
- Don't commit it to version control
- Keep your passwords strong

---

## Troubleshooting

### Error: "key.properties not found"
```bash
# Make sure the file exists
ls android/key.properties

# If not, create it from template
cp android/key.properties.template android/key.properties
```

### Error: "Keystore password was incorrect"
- Double-check you're using the exact password (case-sensitive)
- Make sure there are no extra spaces
- Verify you're using the password from when you created the keystore

### Error: "Keystore file not found"
- Check the path in `storeFile=` matches where your keystore actually is
- Use absolute path (starting with `/home/enrico/...`)
- Verify the keystore exists: `ls /home/enrico/keystores/recipe_parser_release.keystore`

### Error: "Invalid keystore format"
- Make sure the keystore file wasn't corrupted
- Try recreating the keystore if needed

---

## Security Notes

✅ **DO:**
- Use strong passwords
- Keep `key.properties` in `.gitignore` (already done)
- Store passwords in a password manager
- Back up the keystore file

❌ **DON'T:**
- Commit `key.properties` to Git
- Share passwords
- Use weak passwords
- Store passwords in plain text elsewhere

---

## Quick Reference

**File location:** `android/key.properties`

**Required fields:**
- `storePassword` = Your keystore password
- `keyPassword` = Your key password (usually same as keystore)
- `keyAlias` = `recipeparser`
- `storeFile` = `/home/enrico/keystores/recipe_parser_release.keystore`

**Test:** `flutter build apk --release`

Once this works, you're ready to build app bundles for Play Store! 🚀

