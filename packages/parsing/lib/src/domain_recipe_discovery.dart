import 'dart:async';
import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

class DomainRecipeDiscovery {
  DomainRecipeDiscovery({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<Uri>> discoverRecipes(
    String domain, {
    int maxSitemaps = 10,
    int maxUrls = 750,
  }) async {
    final normalized = _normalizeDomain(domain);
    final baseHost = normalized.host;
    final baseScheme = normalized.scheme;

    final sitemapQueue = Queue<Uri>();
    final visitedSitemaps = <Uri>{};
    final discoveredUrls = <Uri>{};

    sitemapQueue.addAll(_initialSitemaps(normalized));

    while (sitemapQueue.isNotEmpty &&
        visitedSitemaps.length < maxSitemaps &&
        discoveredUrls.length < maxUrls) {
      final sitemapUri = sitemapQueue.removeFirst();
      if (visitedSitemaps.contains(sitemapUri)) {
        continue;
      }
      visitedSitemaps.add(sitemapUri);

      final body = await _fetchText(sitemapUri);
      if (body == null || body.isEmpty) {
        continue;
      }

      try {
        final xml = XmlDocument.parse(body);
        final sitemapElements = xml.findAllElements('sitemap');
        if (sitemapElements.isNotEmpty) {
          for (final element in sitemapElements) {
            final loc = element.findElements('loc').firstOrNull?.innerText;
            if (loc == null) continue;
            final locUri = Uri.tryParse(loc);
            if (locUri == null) continue;
            if (!_isSameHost(locUri, baseHost)) continue;
            final normalizedLoc = locUri.scheme.isEmpty
                ? normalized.replace(path: locUri.path)
                : locUri;
            sitemapQueue.add(normalizedLoc);
          }
          continue;
        }

        final urlElements = xml.findAllElements('url');
        for (final element in urlElements) {
          if (discoveredUrls.length >= maxUrls) {
            break;
          }
          final loc = element.findElements('loc').firstOrNull?.innerText;
          if (loc == null) continue;
          final locUri = Uri.tryParse(loc);
          if (locUri == null) continue;
          final normalizedUrl = _normalizeUrl(locUri, baseScheme, baseHost);
          if (!_looksLikeRecipe(normalizedUrl)) {
            continue;
          }
          discoveredUrls.add(normalizedUrl);
        }
      } catch (_) {
        // ignore invalid XML and move on
        continue;
      }
    }

    return discoveredUrls.take(maxUrls).toList(growable: false);
  }

  void close() {
    _client.close();
  }

  Uri _normalizeDomain(String input) {
    var domain = input.trim();
    if (!domain.startsWith('http')) {
      domain = 'https://$domain';
    }
    final uri = Uri.parse(domain);
    if (!uri.hasScheme || !uri.hasAuthority) {
      throw ArgumentError('Invalid domain: $input');
    }
    return Uri(scheme: uri.scheme, host: uri.host);
  }

  Iterable<Uri> _initialSitemaps(Uri base) {
    final paths = [
      '/sitemap_index.xml',
      '/sitemap.xml',
      '/wp-sitemap.xml',
      '/sitemap1.xml',
    ];
    return paths.map((path) => base.replace(path: path));
  }

  Future<String?> _fetchText(Uri uri) async {
    try {
      final response =
          await _client.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.body;
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  bool _isSameHost(Uri uri, String host) {
    final effectiveHost = uri.host.isEmpty ? host : uri.host;
    return effectiveHost == host || effectiveHost.endsWith('.$host');
  }

  Uri _normalizeUrl(Uri uri, String scheme, String host) {
    if (!uri.hasScheme && !uri.hasAuthority) {
      return Uri(scheme: scheme, host: host, path: uri.path, query: uri.query);
    }
    if (!uri.hasScheme) {
      return uri.replace(scheme: scheme);
    }
    return uri;
  }

  bool _looksLikeRecipe(Uri uri) {
    final path = uri.path.toLowerCase();
    return path.contains('recipe') ||
        path.contains('recept') ||
        path.contains('kitchen') ||
        path.contains('/food/');
  }
}
