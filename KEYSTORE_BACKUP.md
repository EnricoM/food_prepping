# Keystore Backup Guide

## ⚠️ CRITICAL: Keep This Information Safe

With Google Play App Signing, you only need to protect your **upload key**. If lost, you can request a reset, but it's still important to back it up.

## What You Need to Back Up

### 1. The Keystore File
- **Location**: `/home/enrico/keystores/recipe_parser_release.keystore`
- **Action**: Copy this file to at least 2 secure locations (encrypted cloud storage + offline backup)

### 2. Keystore Password
- The password you entered when creating the keystore
- **Action**: Store in a password manager (e.g., Bitwarden, 1Password, LastPass)

### 3. Alias Name
- **Value**: `recipeparser`
- **Action**: Document this (it's in your `key.properties` file)

### 4. Alias Password
- The password for the alias (may be the same as keystore password)
- **Action**: Store in password manager

## Backup Checklist

- [ ] Copy keystore file to encrypted cloud storage (Google Drive, Dropbox, etc.)
- [ ] Copy keystore file to offline backup (USB drive, external hard drive)
- [ ] Store keystore password in password manager
- [ ] Store alias password in password manager
- [ ] Document alias name (`recipeparser`) in password manager notes
- [ ] Verify backup: Test that you can access the keystore file from backup location
- [ ] Share backup location with trusted person (optional but recommended)

## What Happens If You Lose the Upload Key?

1. **With Google Play App Signing**: You can request an "Upload key reset" in Play Console
   - Go to: Play Console → Your App → Release → Setup → App signing
   - Click "Request upload key reset"
   - Generate a new upload keystore and continue releasing
   - **No impact on existing users** - they continue using the app signed with Google's key

2. **Without Google Play App Signing**: You cannot update the app (would need new package name)

## Security Best Practices

- ✅ Never commit keystore files or passwords to Git
- ✅ Use strong, unique passwords (20+ characters)
- ✅ Store passwords in a password manager, not in plain text
- ✅ Keep multiple encrypted backups in different locations
- ✅ Test your backup recovery process periodically

## Quick Reference

```
Keystore File: /home/enrico/keystores/recipe_parser_release.keystore
Alias Name: recipeparser
Keystore Password: [stored in password manager]
Alias Password: [stored in password manager]
```

