# Automatic Translation Script

This script automatically translates all i18n files using translation APIs.

## Supported Providers

1. **DeepL API** (Recommended for quality)
   - Sign up: https://www.deepl.com/pro-api
   - Has a free tier (500,000 characters/month)
   - Best translation quality, especially for European languages

2. **Google Cloud Translation API**
   - Setup: https://cloud.google.com/translate/docs/setup
   - Requires Google Cloud account
   - Good coverage of languages

3. **Microsoft Translator API**
   - Setup: https://docs.microsoft.com/en-us/azure/cognitive-services/translator/
   - Requires Azure account
   - Good quality, supports many languages

## Quick Start

### Using DeepL (Recommended)

```bash
# Get your API key from https://www.deepl.com/pro-api
# Then run:

cd apps/recipe_keeper
dart run scripts/auto_translate.dart --provider deepl --api-key YOUR_DEEPL_KEY
```

### Using Google Cloud Translation

```bash
# 1. Create a Google Cloud project
# 2. Enable Cloud Translation API
# 3. Create an API key
# 4. Run:

cd apps/recipe_keeper
dart run scripts/auto_translate.dart --provider google --api-key YOUR_GOOGLE_KEY
```

### Using Microsoft Translator

```bash
# 1. Create Azure account
# 2. Create Translator resource
# 3. Get API key and region
# 4. Run:

cd apps/recipe_keeper
dart run scripts/auto_translate.dart --provider microsoft --api-key YOUR_KEY --region YOUR_REGION
```

## Options

- `--provider PROVIDER`: Translation provider (`deepl`, `google`, or `microsoft`)
- `--api-key KEY`: Your API key (required)
- `--region REGION`: Region for Microsoft Translator (optional)
- `--languages LANG,...`: Comma-separated list of language codes to translate (default: all)
- `--dry-run`: Test without making API calls or saving files
- `--verbose, -v`: Show detailed error messages
- `--help, -h`: Show help message

## Examples

### Translate all languages
```bash
dart run scripts/auto_translate.dart --provider deepl --api-key YOUR_KEY
```

### Translate specific languages only
```bash
dart run scripts/auto_translate.dart --provider deepl --api-key YOUR_KEY --languages es,fr,de,it,pt
```

### Test without making API calls
```bash
dart run scripts/auto_translate.dart --provider deepl --api-key TEST --dry-run
```

### Translate with verbose output
```bash
dart run scripts/auto_translate.dart --provider deepl --api-key YOUR_KEY --verbose
```

## After Translation

1. **Review translations**: Always review translated files, especially for:
   - Technical terms
   - Brand names (should remain untranslated)
   - UI context-specific phrases
   - Cultural appropriateness

2. **Generate code**: After translating, regenerate the slang code:
   ```bash
   cd apps/recipe_keeper
   dart run slang
   ```

3. **Test**: Test your app in different languages to ensure:
   - Text fits properly in UI
   - No text overflow issues
   - Proper locale formatting

## Cost Considerations

### DeepL Free Tier
- 500,000 characters/month free
- For ~300 keys with ~50 chars average = ~15,000 chars per language
- Free tier can translate ~33 languages

### Google Cloud Translation
- First 500,000 characters/month free
- Then $20 per million characters
- Very cost-effective for large volumes

### Microsoft Translator
- Free tier: 2 million characters/month
- Then $10 per million characters
- Good for getting started

## Best Practices

1. **Start with priority languages**: Translate your top 5-10 languages first
   - es (Spanish)
   - fr (French)
   - de (German)
   - it (Italian)
   - pt (Portuguese)
   - zh (Chinese)
   - ja (Japanese)
   - ko (Korean)
   - ar (Arabic)
   - hi (Hindi)

2. **Review before using**: Machine translation is a good starting point, but:
   - Have native speakers review
   - Check for context-specific translations
   - Verify technical terms

3. **Handle placeholders**: The script automatically preserves placeholders like `{name}`, `{count}`, etc.

4. **Rate limiting**: The script includes delays between API calls to avoid rate limits

## Troubleshooting

### "API key is required"
- Make sure you've provided the `--api-key` parameter

### "API error 401/403"
- Check that your API key is correct
- Verify the API is enabled in your account
- Check API key permissions

### "Rate limit exceeded"
- The script includes rate limiting, but if you hit limits:
  - Wait a few minutes and try again
  - Use `--languages` to translate in smaller batches
  - Consider upgrading your API plan

### "Language not supported"
- Some providers don't support all language codes
- Try using the base language code (e.g., `zh` instead of `zh_CN`)
- Check provider documentation for supported languages

