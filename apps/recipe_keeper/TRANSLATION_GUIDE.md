# Translation Guide

This guide explains how to translate the Recipe Keeper app into different languages.

## Current Status

- ✅ **228 translation files** created (all language codes from ISO 639-1)
- 📝 All files currently contain **English placeholders**
- 🔧 **Ready for translation**

## Translation Options

### 1. Translation Platforms (Recommended for Teams)

These platforms provide collaborative translation management:

#### **Crowdin** (Free for open source)
- Website: https://crowdin.com
- Steps:
  1. Create account and project
  2. Upload `en.i18n.json`
  3. Invite translators
  4. Download translated files
- Best for: Open source projects, community translations

#### **Lokalise**
- Website: https://lokalise.com
- Features: Team collaboration, translation memory, quality checks
- Best for: Professional teams

#### **Phrase (formerly PhraseApp)**
- Website: https://phrase.com
- Best for: Developer-friendly workflow

### 2. Automated Translation Services

#### **Google Translate API**
```bash
# Install Google Cloud SDK first
gcloud auth application-default login

# Enable Translation API
gcloud services enable translate.googleapis.com

# Use translation script
dart run scripts/translate_files.dart
```
- **Cost**: ~$20 per million characters
- **Quality**: Good for initial translations, needs review
- **Best for**: Quick first pass, then human review

#### **DeepL API**
- Website: https://www.deepl.com/pro-api
- **Cost**: Free tier available, then ~$5-25/month
- **Quality**: Generally better than Google Translate
- **Best for**: European languages

#### **Microsoft Translator API**
- Website: https://azure.microsoft.com/en-us/services/cognitive-services/translator/
- **Cost**: Free tier (2M chars/month), then pay-as-you-go
- **Best for**: Good balance of quality and cost

### 3. Manual Translation

#### Using Google Translate Website
1. Open https://translate.google.com
2. Select English → Target Language
3. Copy sections from `en.i18n.json`
4. Paste translations into target language file
5. **Review for accuracy** (especially UI terms)

#### Using DeepL Website
1. Open https://www.deepl.com/translator
2. Better quality for European languages
3. Follow same process as above

### 4. Professional Translation Services

#### For Commercial Projects
- **Smartling**: Enterprise-grade localization
- **Lionbridge**: Professional translation services
- **Gengo**: On-demand human translation
- **Upwork/Fiverr**: Hire freelance translators

#### For Open Source Projects
- **Crowdin**: Free for open source
- **Weblate**: Self-hosted or cloud translation platform
- **GitHub Issues**: Community contributions

## Priority Languages

Focus on these languages first (by user base):

1. **Spanish (es)** - ~500M speakers
2. **French (fr)** - ~280M speakers
3. **German (de)** - ~130M speakers
4. **Portuguese (pt)** - ~260M speakers
5. **Chinese (zh)** - ~1.3B speakers
6. **Japanese (ja)** - ~125M speakers
7. **Korean (ko)** - ~80M speakers
8. **Arabic (ar)** - ~310M speakers
9. **Hindi (hi)** - ~600M speakers
10. **Italian (it)** - ~85M speakers

## Translation Workflow

### Step 1: Choose Your Method
- Small project: Manual translation (start with 5-10 languages)
- Team project: Translation platform (Crowdin/Lokalise)
- Quick start: Automated API (Google/DeepL) + review

### Step 2: Translate Files
- Keep the same JSON structure
- Translate all string values
- Keep placeholders like `{name}`, `{count}`, etc. unchanged
- Be consistent with terminology

### Step 3: Review & Test
- Have native speakers review
- Test the app in each language
- Check for text overflow issues
- Verify all strings are translated

### Step 4: Generate Code
```bash
cd apps/recipe_keeper
dart run slang
```

This regenerates the translation code with your new translations.

## Translation Best Practices

### 1. Context Matters
- Provide context for translators (screenshots help)
- Note where strings appear in the UI
- Explain any technical terms

### 2. Consistency
- Use consistent terminology
- Keep brand names untranslated (e.g., "Recipe Keeper")
- Maintain consistent tone

### 3. Localization vs Translation
- Adapt to local conventions (dates, numbers, currencies)
- Consider cultural differences
- Test with real users

### 4. Review Process
- Always have native speakers review
- Check for grammar and spelling
- Verify UI text fits properly

## File Structure

All translation files follow this structure:
```
lib/i18n/
  ├── en.i18n.json      (source file)
  ├── es.i18n.json      (Spanish)
  ├── fr.i18n.json      (French)
  ├── de.i18n.json      (German)
  └── ... (225 more files)
```

Each file has the same JSON structure with translated values.

## Testing Translations

### 1. Test Device Language
```dart
// Change device language to test
// Android: Settings → System → Languages
// iOS: Settings → General → Language & Region
```

### 2. Check All Screens
- Navigate through all app screens
- Verify no missing translations
- Check for text overflow
- Test with long translations

### 3. Validate JSON
```bash
# Check JSON validity
cat lib/i18n/es.i18n.json | python3 -m json.tool
```

## Getting Help

- **Translation Platform Docs**: Check platform-specific guides
- **Community**: Ask for help in project forums
- **Professional Help**: Consider hiring translators for key markets

## Example Translation

**English (en.i18n.json)**:
```json
{
  "common": {
    "save": "Save",
    "cancel": "Cancel"
  }
}
```

**Spanish (es.i18n.json)**:
```json
{
  "common": {
    "save": "Guardar",
    "cancel": "Cancelar"
  }
}
```

**French (fr.i18n.json)**:
```json
{
  "common": {
    "save": "Enregistrer",
    "cancel": "Annuler"
  }
}
```

## Next Steps

1. **Decide on approach** (platform, API, or manual)
2. **Prioritize languages** (start with top 5-10)
3. **Begin translation** (one language at a time)
4. **Test thoroughly** (with native speakers)
5. **Iterate** (improve based on feedback)

Good luck with your translations! 🚀

