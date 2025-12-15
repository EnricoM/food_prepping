#!/bin/bash
# Script to create the release keystore
# This will prompt you for passwords and information

echo "🔐 Creating Release Keystore for Recipe Parser"
echo "=============================================="
echo ""
echo "This will create a keystore file for signing your app."
echo "You'll be asked for:"
echo "  - Keystore password (create a strong password)"
echo "  - Your name/organization details"
echo "  - Key password (can be same as keystore password)"
echo ""
echo "⚠️  IMPORTANT: Remember these passwords! Store them securely."
echo ""
read -p "Press ENTER to continue or Ctrl+C to cancel..."

keytool -genkeypair -v \
  -keystore /home/enrico/keystores/recipe_parser_release.keystore \
  -alias recipeparser \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Keystore created successfully!"
    echo ""
    echo "Next steps:"
    echo "1. I'll create the key.properties file template"
    echo "2. You'll need to add your passwords to key.properties"
    echo "3. I'll update build.gradle.kts to use the keystore"
    echo ""
    ls -lh /home/enrico/keystores/recipe_parser_release.keystore
else
    echo ""
    echo "❌ Failed to create keystore. Please check the error above."
    exit 1
fi

