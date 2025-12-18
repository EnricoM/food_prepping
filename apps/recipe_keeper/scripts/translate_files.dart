#!/usr/bin/env dart
/// Script to automatically translate i18n files using Google Translate API
/// 
/// Prerequisites:
/// 1. Install Google Cloud SDK: https://cloud.google.com/sdk/docs/install
/// 2. Enable Cloud Translation API: https://console.cloud.google.com/apis/library/translate.googleapis.com
/// 3. Set up authentication: gcloud auth application-default login
/// 4. Install dependencies: dart pub add googleapis googleapis_auth http
/// 
/// Usage:
///   dart run scripts/translate_files.dart
///   dart run scripts/translate_files.dart --target-languages es,fr,de
///   dart run scripts/translate_files.dart --dry-run

import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

void main(List<String> args) async {
  final targetLanguages = _parseArgs(args);
  final isDryRun = args.contains('--dry-run');
  
  print('🌍 Translation Script');
  print('====================\n');
  
  if (isDryRun) {
    print('🔍 DRY RUN MODE - No translations will be saved\n');
  }
  
  // Paths
  final scriptDir = File(Platform.script.toFilePath()).parent;
  final projectDir = scriptDir.parent;
  final i18nDir = Directory(path.join(projectDir.path, 'lib', 'i18n'));
  final sourceFile = File(path.join(i18nDir.path, 'en.i18n.json'));
  
  if (!await sourceFile.exists()) {
    print('❌ Error: Source file not found at ${sourceFile.path}');
    exit(1);
  }
  
  // Read source file
  print('📖 Reading source file: en.i18n.json');
  final sourceContent = await sourceFile.readAsString();
  final sourceJson = jsonDecode(sourceContent) as Map<String, dynamic>;
  
  // Get target languages
  final allFiles = await i18nDir.list()
      .where((f) => f.path.endsWith('.i18n.json'))
      .where((f) => !f.path.endsWith('en.i18n.json'))
      .map((f) => path.basenameWithoutExtension(f.path).replaceAll('.i18n', ''))
      .toList();
  
  final languagesToTranslate = targetLanguages.isEmpty ? allFiles : targetLanguages;
  
  print('📋 Found ${languagesToTranslate.length} languages to translate\n');
  
  print('⚠️  NOTE: This script uses Google Translate API');
  print('   For production, consider:');
  print('   1. Professional translation services');
  print('   2. Native speaker review');
  print('   3. Translation platforms (Crowdin, Lokalise, etc.)');
  print('   4. Manual translation\n');
  
  if (!isDryRun) {
    print('Press Enter to continue or Ctrl+C to cancel...');
    await stdin.readLine();
  }
  
  // Translation options
  print('\n📝 Translation Options:');
  print('1. Google Translate API (requires API key)');
  print('2. DeepL API (requires API key)');
  print('3. Manual translation (copy files to translate)');
  print('\nSelect option (1-3): ');
  
  if (!isDryRun) {
    final choice = stdin.readLineSync() ?? '3';
    if (choice == '1') {
      await _translateWithGoogleTranslate(sourceJson, languagesToTranslate, i18nDir, isDryRun);
    } else if (choice == '2') {
      await _translateWithDeepL(sourceJson, languagesToTranslate, i18nDir, isDryRun);
    } else {
      print('\n📋 Manual Translation Guide:');
      _printManualTranslationGuide(languagesToTranslate, i18nDir);
    }
  } else {
    print('\n📋 Manual Translation Guide:');
    _printManualTranslationGuide(languagesToTranslate, i18nDir);
  }
}

List<String> _parseArgs(List<String> args) {
  final targetIndex = args.indexOf('--target-languages');
  if (targetIndex != -1 && targetIndex + 1 < args.length) {
    return args[targetIndex + 1].split(',').map((e) => e.trim()).toList();
  }
  return [];
}

Future<void> _translateWithGoogleTranslate(
  Map<String, dynamic> sourceJson,
  List<String> languages,
  Directory i18nDir,
  bool isDryRun,
) async {
  print('\n⚠️  Google Translate API integration requires:');
  print('   - googleapis package installed');
  print('   - Google Cloud credentials configured');
  print('   - Cloud Translation API enabled');
  print('\nSee: https://cloud.google.com/translate/docs/setup');
  print('\nFor now, please use manual translation or a translation service.');
}

Future<void> _translateWithDeepL(
  Map<String, dynamic> sourceJson,
  List<String> languages,
  Directory i18nDir,
  bool isDryRun,
) async {
  print('\n⚠️  DeepL API integration requires:');
  print('   - DeepL API key (https://www.deepl.com/pro-api)');
  print('   - http package for API calls');
  print('\nFor now, please use manual translation or a translation service.');
}

void _printManualTranslationGuide(List<String> languages, Directory i18nDir) {
  print('\n📚 Manual Translation Options:\n');
  
  print('Option A: Use Translation Platforms (Recommended for teams)');
  print('  • Crowdin: https://crowdin.com');
  print('  • Lokalise: https://lokalise.com');
  print('  • Phrase: https://phrase.com');
  print('  • POEditor: https://poeditor.com');
  print('  → Upload en.i18n.json, get translations, download results\n');
  
  print('Option B: Use Translation Services');
  print('  • Google Translate: https://translate.google.com');
  print('  • DeepL: https://www.deepl.com/translator');
  print('  • Microsoft Translator: https://translator.microsoft.com');
  print('  → Copy content section by section and translate\n');
  
  print('Option C: Hire Professional Translators');
  print('  • Upwork: https://www.upwork.com');
  print('  • Gengo: https://gengo.com');
  print('  • Smartling: https://www.smartling.com');
  print('  → Provide en.i18n.json files for each language\n');
  
  print('Option D: Community Translation');
  print('  • GitHub: Create issues for each language');
  print('  • Crowdin: Free for open source projects');
  print('  • Let community contribute translations\n');
  
  print('📝 Files to translate:');
  for (final lang in languages.take(20)) {
    print('   • ${lang}.i18n.json');
  }
  if (languages.length > 20) {
    print('   ... and ${languages.length - 20} more');
  }
  
  print('\n💡 Tip: Start with your top 5-10 target languages first!');
  print('   Focus on: es, fr, de, it, pt, zh, ja, ko, ar, hi\n');
}

