import 'dart:async';
import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

class DomainRecipeDiscovery {
  DomainRecipeDiscovery({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;
  static const _defaultHeaders = {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
            '(KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
    'Accept':
        'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
    'Accept-Language': 'en-US,en;q=0.9',
  };

  static final Set<String> _positivePathIndicators = {
    'recipe',
    'recipes',
    'recept',
    'rezept',
    'recette',
    'recetas',
    'cocina',
    'kitchen',
    'cook',
    'cooking',
    'food',
    'bake',
    'baking',
    'dessert',
    'dinner',
    'lunch',
    'breakfast',
    'salad',
    'soup',
    'stew',
    'curry',
    'bread',
    'cake',
    'cookie',
    'entree',
    'main-course',
    'side-dish',
  };

  static final Set<String> _nonRecipeSegments = {
    'about',
    'contact',
    'privacy',
    'privacy-policy',
    'terms',
    'terms-of-use',
    'legal',
    'advertise',
    'sponsor',
    'press',
    'shop',
    'store',
    'cart',
    'checkout',
    'login',
    'logout',
    'signup',
    'account',
    'search',
    'tag',
    'author',
    'category',
    'wp-json',
    'feed',
    'comments',
    'comment',
    'page',
    'print',
    'attachment',
    'robots.txt',
    'attachment_id',
    's',
  };

  static final Set<String> _nonRecipeSlugs = {
    'about',
    'about-us',
    'privacy-policy',
    'terms-of-use',
    'terms-and-conditions',
    'contact',
    'contact-us',
    'press',
    'sponsor',
    'advertise',
    'work-with-me',
    'disclaimer',
    'cookie-policy',
    'page',
    'feed',
    'author',
    'search',
    'tag',
    'category',
    'archives',
  };

  static final RegExp _postSlugPattern =
      RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+){2,}$');
  static final RegExp _yearSegmentPattern = RegExp(r'^(?:19|20)\d{2}$');
  static final RegExp _monthSegmentPattern = RegExp(r'^(0?[1-9]|1[0-2])$');
  static final List<String> _disallowedExtensions = [
    '.xml',
    '.xsl',
    '.json',
    '.txt',
    '.csv',
    '.pdf',
  ];

  Future<List<Uri>> discoverRecipes(
    String domain, {
    int maxSitemaps = 10,
    int maxUrls = 750,
  }) async {
    final normalized = _normalizeDomain(domain);
    final baseHost = normalized.host;
    final canonicalHost = _canonicalHost(baseHost);
    final baseScheme = normalized.scheme;

    final sitemapQueue = Queue<Uri>();
    final visitedSitemaps = <Uri>{};
    final discoveredEntries = <_SitemapUrlEntry>[];
    final seenUrls = <String>{};

    sitemapQueue.addAll(_initialSitemaps(normalized));

    while (sitemapQueue.isNotEmpty && visitedSitemaps.length < maxSitemaps) {
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
            if (!_isSameHost(locUri, canonicalHost)) continue;
            final normalizedLoc = locUri.scheme.isEmpty
                ? normalized.replace(path: locUri.path)
                : locUri;
            sitemapQueue.add(normalizedLoc);
          }
          continue;
        }

        final urlElements = xml.findAllElements('url');
        for (final element in urlElements) {
          final loc = element.findElements('loc').firstOrNull?.innerText;
          if (loc == null) continue;
          final locUri = Uri.tryParse(loc);
          if (locUri == null) continue;
          final normalizedUrl = _normalizeUrl(locUri, baseScheme, baseHost);
          if (!isLikelyRecipeUrl(normalizedUrl)) {
            continue;
          }
          final key = normalizedUrl.toString();
          if (!seenUrls.add(key)) {
            continue;
          }
          final lastModText =
              element.findElements('lastmod').firstOrNull?.innerText;
          discoveredEntries.add(
            _SitemapUrlEntry(
              url: normalizedUrl,
              lastModified: _parseLastModified(lastModText),
            ),
          );
        }
      } catch (_) {
        // ignore invalid XML and move on
        continue;
      }
    }

    if (discoveredEntries.isEmpty) {
      final crawledEntries = await _crawlSiteForRecipes(
        normalizedBase: normalized,
        canonicalHost: canonicalHost,
        baseScheme: baseScheme,
        seenUrls: seenUrls,
        maxUrls: maxUrls,
      );
      discoveredEntries.addAll(crawledEntries);
    }

    discoveredEntries.sort(_compareEntries);
    return discoveredEntries
        .take(maxUrls)
        .map((entry) => entry.url)
        .toList(growable: false);
  }

  void close() {
    _client.close();
  }

  /// Heuristic used to determine if a URL is likely to contain a single recipe.
  static bool isLikelyRecipeUrl(Uri uri) => _looksLikeRecipe(uri);

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

  Future<String?> _fetchText(
    Uri uri, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _client
          .get(uri, headers: headers ?? _defaultHeaders)
          .timeout(const Duration(seconds: 15));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.body;
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<List<_SitemapUrlEntry>> _crawlSiteForRecipes({
    required Uri normalizedBase,
    required String canonicalHost,
    required String baseScheme,
    required Set<String> seenUrls,
    required int maxUrls,
    int maxPages = 150,
  }) async {
    final queue = Queue<Uri>()..add(normalizedBase);
    final visitedPages = <String>{};
    final seenPages = <String>{normalizedBase.toString()};
    final discovered = <_SitemapUrlEntry>[];

    while (queue.isNotEmpty &&
        visitedPages.length < maxPages &&
        discovered.length < maxUrls) {
      final page = queue.removeFirst();
      final pageKey = page.toString();
      if (visitedPages.contains(pageKey)) {
        continue;
      }
      visitedPages.add(pageKey);

      final body = await _fetchText(page);
      if (body == null || body.isEmpty) {
        continue;
      }
      final document = html_parser.parse(body);
      final anchors = document.querySelectorAll('a[href]');
      for (final anchor in anchors) {
        final href = anchor.attributes['href'];
        final resolved = _resolveLink(page, href);
        if (resolved == null) continue;
        final sanitized = resolved.replace(fragment: null);
        if (!_isSameHost(sanitized, canonicalHost)) continue;
        if (_shouldSkipPath(sanitized)) continue;

        final normalizedUrl = _normalizeUrl(sanitized, baseScheme, normalizedBase.host);
        final urlKey = normalizedUrl.toString();

        if (isLikelyRecipeUrl(normalizedUrl)) {
          if (seenUrls.add(urlKey)) {
            discovered.add(
              _SitemapUrlEntry(
                url: normalizedUrl,
                lastModified: null,
              ),
            );
            if (discovered.length >= maxUrls) {
              break;
            }
          }
        } else if (seenPages.length < maxPages && seenPages.add(urlKey)) {
          queue.add(normalizedUrl);
        }
      }
    }

    return discovered;
  }

  bool _isSameHost(Uri uri, String canonicalHost) {
    if (canonicalHost.isEmpty) {
      return false;
    }
    final effectiveHost = uri.host.isEmpty
        ? canonicalHost
        : _canonicalHost(uri.host);
    return effectiveHost == canonicalHost ||
        effectiveHost.endsWith('.$canonicalHost');
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

  DateTime? _parseLastModified(String? value) {
    if (value == null) {
      return null;
    }
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    try {
      return DateTime.parse(trimmed);
    } catch (_) {
      return null;
    }
  }

  int _compareEntries(_SitemapUrlEntry a, _SitemapUrlEntry b) {
    final aDate = a.lastModified;
    final bDate = b.lastModified;
    if (aDate != null && bDate != null) {
      final cmp = bDate.compareTo(aDate);
      if (cmp != 0) {
        return cmp;
      }
    } else if (aDate != null) {
      return -1;
    } else if (bDate != null) {
      return 1;
    }
    return a.url.toString().compareTo(b.url.toString());
  }

  bool _shouldSkipPath(Uri uri) {
    final path = uri.path.toLowerCase();
    if (path.isEmpty || path == '/') {
      return false;
    }
    if (_disallowedExtensions.any(path.endsWith)) {
      return true;
    }
    return false;
  }

  static bool _looksLikeRecipe(Uri uri) {
    final path = uri.path.toLowerCase();
    if (path.isEmpty || path == '/' || path == '/home') {
      return false;
    }
    if (_disallowedExtensions.any(path.endsWith)) {
      return false;
    }
    if (uri.queryParameters.keys.any(_nonRecipeSegments.contains)) {
      return false;
    }

    final segments = uri.pathSegments
        .map((segment) => segment.toLowerCase())
        .where((segment) => segment.isNotEmpty)
        .toList();
    if (segments.isEmpty) {
      return false;
    }
    if (segments.any(_nonRecipeSegments.contains)) {
      return false;
    }

    final lastSegment = segments.last;
    if (_nonRecipeSlugs.contains(lastSegment)) {
      return false;
    }

    if (_positivePathIndicators.any(path.contains)) {
      // Avoid treating bare listing pages like /recipes/ as candidates.
      if (segments.length == 1 &&
          _positivePathIndicators.contains(segments.first)) {
        return false;
      }
      return true;
    }

    if (_postSlugPattern.hasMatch(lastSegment)) {
      return true;
    }

    if (segments.length >= 3 &&
        _yearSegmentPattern.hasMatch(segments[segments.length - 3]) &&
        _monthSegmentPattern.hasMatch(segments[segments.length - 2])) {
      return true;
    }

    for (var i = 0; i < segments.length - 1; i++) {
      final segment = segments[i];
      if (_positivePathIndicators.contains(segment)) {
        return true;
      }
    }

    if (lastSegment.length >= 8 &&
        lastSegment.contains('-') &&
        !_nonRecipeSlugs.contains(lastSegment)) {
      return true;
    }

    return false;
  }

  String _canonicalHost(String host) {
    final lower = host.toLowerCase();
    if (lower.startsWith('www.') && lower.length > 4) {
      return lower.substring(4);
    }
    return lower;
  }

  Uri? _resolveLink(Uri base, String? href) {
    if (href == null || href.isEmpty) {
      return null;
    }
    final trimmed = href.trim();
    if (trimmed.isEmpty ||
        trimmed.startsWith('#') ||
        trimmed.startsWith('javascript:') ||
        trimmed.startsWith('mailto:') ||
        trimmed.startsWith('tel:')) {
      return null;
    }
    try {
      Uri uri;
      if (trimmed.startsWith('//')) {
        uri = Uri.parse('${base.scheme}:$trimmed');
      } else {
        uri = Uri.parse(trimmed);
        if (!uri.hasScheme) {
          uri = base.resolveUri(uri);
        }
      }
      if (uri.scheme != 'http' && uri.scheme != 'https') {
        return null;
      }
      return uri;
    } catch (_) {
      return null;
    }
  }
}

class _SitemapUrlEntry {
  _SitemapUrlEntry({
    required this.url,
    required this.lastModified,
  });

  final Uri url;
  final DateTime? lastModified;
}
