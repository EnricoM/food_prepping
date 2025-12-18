#!/usr/bin/env dart
// ignore_for_file: avoid_print
/// Script to automatically translate i18n files using translation APIs
/// 
/// Supports:
/// - Google Cloud Translation API
/// - DeepL API
/// - Microsoft Translator API
/// 
/// Usage:
///   dart run scripts/auto_translate.dart --provider deepl --api-key YOUR_KEY
///   dart run scripts/auto_translate.dart --provider google --api-key YOUR_KEY
///   dart run scripts/auto_translate.dart --provider microsoft --api-key YOUR_KEY --region YOUR_REGION
///   dart run scripts/auto_translate.dart --provider deepl --api-key YOUR_KEY --languages es,fr,de
///   dart run scripts/auto_translate.dart --provider deepl --api-key YOUR_KEY --dry-run

import 'dart:convert';
import 'dart:io';

const String _sourceLocale = 'en';
const String _i18nDir = 'lib/i18n';
const String _sourceFile = '$_i18nDir/$_sourceLocale.i18n.json';

void main(List<String> args) async {
  final config = _parseArgs(args);
  
  print('🌍 Automatic Translation Script');
  print('================================\n');
  
  if (config.dryRun) {
    print('🔍 DRY RUN MODE - No translations will be saved\n');
  }
  
  // Validate source file exists
  final sourceFile = File(_sourceFile);
  if (!await sourceFile.exists()) {
    print('❌ Error: Source file not found at $_sourceFile');
    print('   Please run from the apps/recipe_keeper directory');
    exit(1);
  }
  
  // Read source file
  print('📖 Reading source file: $_sourceFile');
  final sourceContent = await sourceFile.readAsString();
  final sourceJson = jsonDecode(sourceContent) as Map<String, dynamic>;
  
  // Get target languages
  final i18nDir = Directory(_i18nDir);
  if (!await i18nDir.exists()) {
    print('❌ Error: i18n directory not found at $_i18nDir');
    exit(1);
  }
  
  final allLanguageFiles = await i18nDir
      .list()
      .where((f) => f.path.endsWith('.i18n.json'))
      .where((f) => !f.path.endsWith('$_sourceLocale.i18n.json'))
      .map((f) => f.path.split('/').last.replaceAll('.i18n.json', ''))
      .toList();
  
  final languagesToTranslate = config.languages.isEmpty 
      ? allLanguageFiles 
      : config.languages;
  
  print('📋 Found ${languagesToTranslate.length} languages to translate');
  if (config.languages.isNotEmpty) {
    print('   Selected languages: ${config.languages.join(', ')}');
  }
  print('');
  
  // Validate API configuration
  if (!config.dryRun && config.apiKey.isEmpty) {
    print('❌ Error: --api-key is required');
    print('   Usage: dart run scripts/auto_translate.dart --provider ${config.provider} --api-key YOUR_KEY');
    exit(1);
  }
  
  // Create translator
  final translator = _createTranslator(config);
  
  if (!config.dryRun) {
    print('⚠️  NOTE: This will translate using ${config.provider.toUpperCase()} API');
    print('   Estimated cost: varies by provider and text volume');
    print('   Please review translations before using in production\n');
    print('Press Enter to continue or Ctrl+C to cancel...');
    stdin.readLineSync();
    print('');
  }
  
  // Translate
  final stopwatch = Stopwatch()..start();
  int successCount = 0;
  int errorCount = 0;
  
  for (final lang in languagesToTranslate) {
    try {
      print('🔄 Translating $lang...');
      
      if (config.dryRun) {
        print('   [DRY RUN] Would translate to ${lang}.i18n.json');
        await Future.delayed(Duration(milliseconds: 100)); // Simulate work
        successCount++;
        continue;
      }
      
      final translated = await _translateJson(
        sourceJson, 
        _sourceLocale, 
        lang, 
        translator,
        config,
      );
      
      final targetFile = File('$_i18nDir/$lang.i18n.json');
      final jsonEncoder = JsonEncoder.withIndent('  ');
      await targetFile.writeAsString(jsonEncoder.convert(translated));
      
      print('   ✅ Translated and saved to ${lang}.i18n.json');
      successCount++;
      
      // Rate limiting - be nice to APIs
      await Future.delayed(Duration(milliseconds: 500));
      
    } catch (e, stackTrace) {
      print('   ❌ Error translating $lang: $e');
      if (config.verbose) {
        print('   Stack trace: $stackTrace');
      }
      errorCount++;
    }
  }
  
  stopwatch.stop();
  
  print('\n📊 Translation Summary');
  print('======================');
  print('   ✅ Success: $successCount');
  print('   ❌ Errors: $errorCount');
  print('   ⏱️  Time: ${stopwatch.elapsed.inSeconds}s');
  print('');
  
  if (successCount > 0 && !config.dryRun) {
    print('💡 Next steps:');
    print('   1. Review the translated files');
    print('   2. Run: dart run slang');
    print('   3. Test the app in different languages');
    print('');
  }
}

Config _parseArgs(List<String> args) {
  String provider = 'deepl';
  String apiKey = '';
  String region = '';
  List<String> languages = [];
  bool dryRun = false;
  bool verbose = false;
  
  for (int i = 0; i < args.length; i++) {
    final arg = args[i];
    if (arg == '--provider' && i + 1 < args.length) {
      provider = args[++i].toLowerCase();
    } else if (arg == '--api-key' && i + 1 < args.length) {
      apiKey = args[++i];
    } else if (arg == '--region' && i + 1 < args.length) {
      region = args[++i];
    } else if (arg == '--languages' && i + 1 < args.length) {
      languages = args[++i].split(',').map((e) => e.trim()).toList();
    } else if (arg == '--dry-run') {
      dryRun = true;
    } else if (arg == '--verbose' || arg == '-v') {
      verbose = true;
    } else if (arg == '--help' || arg == '-h') {
      _printHelp();
      exit(0);
    }
  }
  
  return Config(
    provider: provider,
    apiKey: apiKey,
    region: region,
    languages: languages,
    dryRun: dryRun,
    verbose: verbose,
  );
}

void _printHelp() {
  print('''
Usage: dart run scripts/auto_translate.dart [options]

Options:
  --provider PROVIDER    Translation provider: deepl, google, or microsoft (default: deepl)
  --api-key KEY         API key for the translation provider (required)
  --region REGION       Region for Microsoft Translator (optional, e.g., "eastus")
  --languages LANG,...  Comma-separated list of language codes to translate (default: all)
  --dry-run            Run without making API calls or saving files
  --verbose, -v        Show detailed error messages
  --help, -h           Show this help message

Examples:
  # Translate all languages using DeepL
  dart run scripts/auto_translate.dart --provider deepl --api-key YOUR_DEEPL_KEY

  # Translate specific languages using Google
  dart run scripts/auto_translate.dart --provider google --api-key YOUR_GOOGLE_KEY --languages es,fr,de

  # Test without making API calls
  dart run scripts/auto_translate.dart --provider deepl --api-key TEST --dry-run

API Setup:
  DeepL: https://www.deepl.com/pro-api
  Google: https://cloud.google.com/translate/docs/setup
  Microsoft: https://docs.microsoft.com/en-us/azure/cognitive-services/translator/
''');
}

Translator _createTranslator(Config config) {
  switch (config.provider) {
    case 'deepl':
      return DeepLTranslator(config.apiKey);
    case 'google':
      return GoogleTranslator(config.apiKey);
    case 'microsoft':
      return MicrosoftTranslator(config.apiKey, config.region);
    default:
      print('❌ Error: Unknown provider "${config.provider}"');
      print('   Supported providers: deepl, google, microsoft');
      exit(1);
  }
}

Future<Map<String, dynamic>> _translateJson(
  Map<String, dynamic> source,
  String sourceLang,
  String targetLang,
  Translator translator,
  Config config,
) async {
  final Map<String, dynamic> result = {};
  
  for (final entry in source.entries) {
    if (entry.value is String) {
      // Translate string value
      final text = entry.value as String;
      
      // Skip empty strings
      if (text.isEmpty) {
        result[entry.key] = text;
        continue;
      }
      
      // Extract placeholders to preserve them
      final placeholders = _extractPlaceholders(text);
      final textWithoutPlaceholders = _removePlaceholders(text);
      
      // Translate
      final translated = await translator.translate(
        textWithoutPlaceholders,
        sourceLang,
        targetLang,
      );
      
      // Restore placeholders
      result[entry.key] = _restorePlaceholders(translated, placeholders);
      
    } else if (entry.value is Map) {
      // Recursively translate nested maps
      result[entry.key] = await _translateJson(
        entry.value as Map<String, dynamic>,
        sourceLang,
        targetLang,
        translator,
        config,
      );
    } else {
      // Copy other types as-is (numbers, booleans, etc.)
      result[entry.key] = entry.value;
    }
  }
  
  return result;
}

List<String> _extractPlaceholders(String text) {
  final regex = RegExp(r'\{[^}]+\}');
  return regex.allMatches(text).map((m) => m.group(0)!).toList();
}

String _removePlaceholders(String text) {
  return text.replaceAll(RegExp(r'\{[^}]+\}'), 'PLACEHOLDER');
}

String _restorePlaceholders(String translated, List<String> placeholders) {
  String result = translated;
  for (final placeholder in placeholders) {
    if (result.contains('PLACEHOLDER')) {
      result = result.replaceFirst('PLACEHOLDER', placeholder);
    }
  }
  return result;
}

class Config {
  final String provider;
  final String apiKey;
  final String region;
  final List<String> languages;
  final bool dryRun;
  final bool verbose;
  
  Config({
    required this.provider,
    required this.apiKey,
    required this.region,
    required this.languages,
    required this.dryRun,
    required this.verbose,
  });
}

abstract class Translator {
  Future<String> translate(String text, String sourceLang, String targetLang);
}

class DeepLTranslator implements Translator {
  final String apiKey;
  final HttpClient _httpClient = HttpClient();
  
  DeepLTranslator(this.apiKey);
  
  @override
  Future<String> translate(String text, String sourceLang, String targetLang) async {
    if (text.trim().isEmpty) return text;
    
    // Map language codes to DeepL format
    final source = _mapToDeepLLang(sourceLang);
    final target = _mapToDeepLLang(targetLang);
    
    final uri = Uri.parse('https://api-free.deepl.com/v2/translate');
    final request = await _httpClient.postUrl(uri);
    request.headers.set('Authorization', 'DeepL-Auth-Key $apiKey');
    request.headers.set('Content-Type', 'application/x-www-form-urlencoded');
    
    final body = 'text=${Uri.encodeComponent(text)}&source_lang=$source&target_lang=$target';
    request.write(body);
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    if (response.statusCode != 200) {
      throw Exception('DeepL API error (${response.statusCode}): $responseBody');
    }
    
    final json = jsonDecode(responseBody) as Map<String, dynamic>;
    final translations = json['translations'] as List;
    if (translations.isEmpty) {
      throw Exception('No translation returned from DeepL API');
    }
    
    return translations.first['text'] as String;
  }
  
  String _mapToDeepLLang(String lang) {
    // Handle language codes with region (e.g., "en_US" -> "EN")
    final baseLang = lang.split('_')[0].toUpperCase();
    
    // DeepL uses specific codes
    final mapping = {
      'EN': 'EN',
      'ES': 'ES',
      'FR': 'FR',
      'DE': 'DE',
      'IT': 'IT',
      'PT': 'PT',
      'RU': 'RU',
      'JA': 'JA',
      'ZH': 'ZH',
      'NL': 'NL',
      'PL': 'PL',
      'KO': 'KO',
      'TR': 'TR',
      'AR': 'AR',
      'HI': 'HI',
    };
    
    return mapping[baseLang] ?? baseLang;
  }
}

class GoogleTranslator implements Translator {
  final String apiKey;
  final HttpClient _httpClient = HttpClient();
  
  GoogleTranslator(this.apiKey);
  
  @override
  Future<String> translate(String text, String sourceLang, String targetLang) async {
    if (text.trim().isEmpty) return text;
    
    // Map language codes (remove region for Google)
    final source = sourceLang.split('_')[0];
    final target = targetLang.split('_')[0];
    
    final uri = Uri.parse(
      'https://translation.googleapis.com/language/translate/v2?key=$apiKey',
    );
    final request = await _httpClient.postUrl(uri);
    request.headers.set('Content-Type', 'application/json');
    
    final body = jsonEncode({
      'q': text,
      'source': source,
      'target': target,
      'format': 'text',
    });
    request.write(body);
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    if (response.statusCode != 200) {
      throw Exception('Google Translate API error (${response.statusCode}): $responseBody');
    }
    
    final json = jsonDecode(responseBody) as Map<String, dynamic>;
    final data = json['data'] as Map<String, dynamic>;
    final translations = data['translations'] as List;
    if (translations.isEmpty) {
      throw Exception('No translation returned from Google Translate API');
    }
    
    return translations.first['translatedText'] as String;
  }
}

class MicrosoftTranslator implements Translator {
  final String apiKey;
  final String region;
  final HttpClient _httpClient = HttpClient();
  
  MicrosoftTranslator(this.apiKey, this.region);
  
  @override
  Future<String> translate(String text, String sourceLang, String targetLang) async {
    if (text.trim().isEmpty) return text;
    
    // Map language codes (remove region for Microsoft)
    final source = sourceLang.split('_')[0];
    final target = targetLang.split('_')[0];
    
    // Microsoft Translator v3 endpoint
    final uri = Uri.parse(
      'https://api.cognitive.microsofttranslator.com/translate?api-version=3.0&from=$source&to=$target',
    );
    final request = await _httpClient.postUrl(uri);
    request.headers.set('Ocp-Apim-Subscription-Key', apiKey);
    request.headers.set('Ocp-Apim-Subscription-Region', region.isNotEmpty ? region : 'global');
    request.headers.set('Content-Type', 'application/json');
    
    final body = jsonEncode([
      {'Text': text}
    ]);
    request.write(body);
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    if (response.statusCode != 200) {
      throw Exception('Microsoft Translator API error (${response.statusCode}): $responseBody');
    }
    
    final json = jsonDecode(responseBody) as List;
    if (json.isEmpty) {
      throw Exception('No translation returned from Microsoft Translator API');
    }
    
    final translation = json.first as Map<String, dynamic>;
    final translations = translation['translations'] as List;
    if (translations.isEmpty) {
      throw Exception('No translation returned from Microsoft Translator API');
    }
    
    return translations.first['text'] as String;
  }
}

