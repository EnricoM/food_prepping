import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'imported_url_entity.dart';

class ImportedUrlStore {
  ImportedUrlStore._();

  static const _boxName = 'importedUrls';
  static ImportedUrlStore? _instance;

  static ImportedUrlStore get instance {
    final instance = _instance;
    if (instance == null) {
      throw StateError('ImportedUrlStore has not been initialized.');
    }
    return instance;
  }

  static Future<void> init() async {
    if (!Hive.isAdapterRegistered(ImportedUrlEntityAdapter().typeId)) {
      Hive.registerAdapter(ImportedUrlEntityAdapter());
    }
    await Hive.openBox<ImportedUrlEntity>(_boxName);
    _instance = ImportedUrlStore._();
  }

  Box<ImportedUrlEntity> get _box => Hive.box<ImportedUrlEntity>(_boxName);

  ValueListenable<Box<ImportedUrlEntity>> listenable() => _box.listenable();

  Future<void> markAsImported(String url) async {
    try {
      // Normalize URL - ensure it has a scheme
      String normalizedUrl = url.trim();
      if (!normalizedUrl.startsWith('http://') && !normalizedUrl.startsWith('https://')) {
        normalizedUrl = 'https://$normalizedUrl';
      }
      
      final uri = Uri.parse(normalizedUrl);
      String domain = uri.host.toLowerCase();
      
      // Remove www. prefix for consistency
      if (domain.startsWith('www.')) {
        domain = domain.substring(4);
      }
      
      if (domain.isEmpty) {
        return;
      }
      
      // Use the original URL (not normalized) for storage, but normalized for domain
      // Check if already exists
      final existing = _box.values
          .where((entity) => entity.url == url || entity.url == normalizedUrl)
          .isNotEmpty;
      
      if (!existing) {
        await _box.add(ImportedUrlEntity(
          url: url, // Store original URL
          domain: domain, // Store normalized domain
          importedAt: DateTime.now(),
        ));
      }
    } catch (e) {
      // Ignore invalid URLs - but log for debugging
      debugPrint('Failed to mark URL as imported: $url - $e');
    }
  }

  bool isImported(String url) {
    // Normalize URL for comparison
    String normalizedUrl = url.trim();
    if (!normalizedUrl.startsWith('http://') && !normalizedUrl.startsWith('https://')) {
      normalizedUrl = 'https://$normalizedUrl';
    }
    
    return _box.values.any((entity) {
      final entityUrl = entity.url.trim();
      String normalizedEntityUrl = entityUrl;
      if (!normalizedEntityUrl.startsWith('http://') && !normalizedEntityUrl.startsWith('https://')) {
        normalizedEntityUrl = 'https://$normalizedEntityUrl';
      }
      return entityUrl == url || 
             normalizedEntityUrl == normalizedUrl ||
             entityUrl == normalizedUrl;
    });
  }

  String _normalizeDomain(String domain) {
    String normalized = domain.toLowerCase().trim();
    if (normalized.startsWith('www.')) {
      normalized = normalized.substring(4);
    }
    return normalized;
  }

  Set<String> getImportedUrlsForDomain(String domain) {
    // Normalize domain for comparison
    final normalizedDomain = _normalizeDomain(domain);
    
    return _box.values
        .where((entity) => _normalizeDomain(entity.domain) == normalizedDomain)
        .map((entity) => entity.url)
        .toSet();
  }

  Set<String> getAllDomains() {
    return _box.values.map((entity) => entity.domain).toSet();
  }

  List<ImportedUrlEntity> getAllImportedUrls() {
    return _box.values.toList(growable: false)
      ..sort((a, b) => b.importedAt.compareTo(a.importedAt));
  }

  Future<void> clear() => _box.clear();
}

