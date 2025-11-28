#!/bin/bash
# Script to encrypt and prepare keystore for Google Drive backup

KEYSTORE_PATH="/home/enrico/keystores/recipe_parser_release.keystore"
BACKUP_DIR="$HOME/keystore_backup"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "🔐 Keystore Backup Script"
echo "========================"
echo ""

# Check if keystore exists
if [ ! -f "$KEYSTORE_PATH" ]; then
    echo "❌ Keystore not found: $KEYSTORE_PATH"
    exit 1
fi

# Create backup directory
mkdir -p "$BACKUP_DIR"

echo "Keystore found: $KEYSTORE_PATH"
echo ""

# Option 1: Zip with encryption
if command -v zip &> /dev/null; then
    echo "Creating encrypted ZIP backup..."
    BACKUP_FILE="$BACKUP_DIR/recipe_parser_keystore_${TIMESTAMP}.zip"
    zip -e "$BACKUP_FILE" "$KEYSTORE_PATH"
    
    if [ $? -eq 0 ]; then
        echo "✅ Encrypted backup created: $BACKUP_FILE"
        echo ""
        echo "📤 Next steps:"
        echo "1. Upload this file to Google Drive: $BACKUP_FILE"
        echo "2. Store the ZIP password in your password manager"
        echo "3. Delete the local backup after uploading (optional)"
        echo ""
        ls -lh "$BACKUP_FILE"
    else
        echo "❌ Failed to create encrypted backup"
    fi
# Option 2: 7zip
elif command -v 7z &> /dev/null; then
    echo "Creating encrypted 7z backup..."
    BACKUP_FILE="$BACKUP_DIR/recipe_parser_keystore_${TIMESTAMP}.7z"
    7z a -p -mhe=on "$BACKUP_FILE" "$KEYSTORE_PATH"
    
    if [ $? -eq 0 ]; then
        echo "✅ Encrypted backup created: $BACKUP_FILE"
        echo ""
        echo "📤 Next steps:"
        echo "1. Upload this file to Google Drive: $BACKUP_FILE"
        echo "2. Store the 7z password in your password manager"
        echo "3. Delete the local backup after uploading (optional)"
        echo ""
        ls -lh "$BACKUP_FILE"
    else
        echo "❌ Failed to create encrypted backup"
    fi
# Option 3: No encryption tool available
else
    echo "⚠️  No encryption tool found (zip or 7z)"
    echo ""
    echo "Creating unencrypted backup (keystore is already password-protected)..."
    BACKUP_FILE="$BACKUP_DIR/recipe_parser_keystore_${TIMESTAMP}.keystore"
    cp "$KEYSTORE_PATH" "$BACKUP_FILE"
    
    if [ $? -eq 0 ]; then
        echo "✅ Backup created: $BACKUP_FILE"
        echo ""
        echo "⚠️  WARNING: This backup is not encrypted."
        echo "   The keystore itself is password-protected, but consider:"
        echo "   1. Installing zip: sudo apt install zip"
        echo "   2. Then run this script again for encrypted backup"
        echo ""
        echo "📤 Next steps:"
        echo "1. Upload this file to Google Drive: $BACKUP_FILE"
        echo "2. Store keystore password in your password manager"
        echo ""
        ls -lh "$BACKUP_FILE"
    else
        echo "❌ Failed to create backup"
        exit 1
    fi
fi

echo ""
echo "💡 Remember to also back up:"
echo "   - Keystore password"
echo "   - Key alias: recipeparser"
echo "   - Key password (if different)"
echo "   Store these in a password manager!"

