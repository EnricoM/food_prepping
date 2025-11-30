import 'dart:async';
import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

import 'http_utils.dart';
import 'recipe_parser.dart';

class DomainRecipeDiscovery {
  DomainRecipeDiscovery({
    http.Client? client,
    RecipeParser? recipeParser,
    bool validateRecipes = false,
  })  : _client = client ?? http.Client(),
        _recipeParser = recipeParser,
        _validateRecipes = validateRecipes;

  final http.Client _client;
  final RecipeParser? _recipeParser;
  final bool _validateRecipes;
  final Map<String, String> _cookieJar = {};

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
    bool? validateRecipes,
  }) async {
    final shouldValidate = validateRecipes ?? _validateRecipes;
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
          
          // Optionally validate that the page actually contains a recipe
          if (shouldValidate && _recipeParser != null) {
            final hasRecipe = await _validateRecipeUrl(normalizedUrl);
            if (!hasRecipe) {
              continue;
            }
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

    // Always try crawling if we haven't found enough URLs, or if no sitemaps were found
    if (discoveredEntries.isEmpty || discoveredEntries.length < maxUrls) {
      final crawledEntries = await _crawlSiteForRecipes(
        normalizedBase: normalized,
        canonicalHost: canonicalHost,
        baseScheme: baseScheme,
        seenUrls: seenUrls,
        maxUrls: maxUrls - discoveredEntries.length,
        validateRecipes: shouldValidate,
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

  Future<String?> _fetchText(Uri uri) async {
    final response = await _sendRequest(uri);
    if (response == null) {
      return null;
    }
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.body;
    }
    return null;
  }

  Future<List<_SitemapUrlEntry>> _crawlSiteForRecipes({
    required Uri normalizedBase,
    required String canonicalHost,
    required String baseScheme,
    required Set<String> seenUrls,
    required int maxUrls,
    int maxPages = 200, // Increased from 150 to crawl more pages
    bool validateRecipes = false,
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
            // Optionally validate that the page actually contains a recipe
            if (validateRecipes && _recipeParser != null) {
              final hasRecipe = await _validateRecipeUrl(normalizedUrl);
              if (!hasRecipe) {
                continue;
              }
            }
            
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
        } else {
          // Prioritize URLs that look like recipes for crawling
          if (isLikelyRecipeUrl(normalizedUrl)) {
            // Add recipe-like URLs to the front of the queue
            if (seenPages.add(urlKey)) {
              queue.addFirst(normalizedUrl);
            }
          } else if (seenPages.length < maxPages && seenPages.add(urlKey)) {
            // Add other URLs to the back of the queue
            queue.add(normalizedUrl);
          }
        }
      }
    }

    return discovered;
  }

  Map<String, String> _headersFor(Uri uri, Map<String, String> baseHeaders) {
    final headers = Map<String, String>.from(baseHeaders);
    final cookie = _cookieJar[uri.host];
    if (cookie != null && cookie.isNotEmpty) {
      headers['Cookie'] = cookie;
    }
    return headers;
  }

  Future<http.Response?> _sendRequest(Uri uri) async {
    http.Response? lastResponse;
    for (final candidate in HttpUtils.discoveryHeaderCandidates) {
      final response = await _sendWithHeaders(uri, candidate);
      if (response == null) {
        continue;
      }
      lastResponse = response;
      if (response.statusCode >= 200 && response.statusCode < 400) {
        return response;
      }
    }
    return lastResponse;
  }

  Future<http.Response?> _sendWithHeaders(
    Uri uri,
    Map<String, String> baseHeaders,
  ) async {
    http.Response response;
    try {
      response = await _client
          .get(uri, headers: _headersFor(uri, baseHeaders))
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      return null;
    }

    if (HttpUtils.shouldRetryWithCookies(response.statusCode)) {
      final responseCookies =
          HttpUtils.cookieHeaderFromSetCookie(response.headers['set-cookie']);
      if (responseCookies != null) {
        _cookieJar[uri.host] = responseCookies;
        try {
          response = await _client
              .get(uri, headers: _headersFor(uri, baseHeaders))
              .timeout(const Duration(seconds: 15));
        } catch (_) {
          return null;
        }
        if (!HttpUtils.shouldRetryWithCookies(response.statusCode)) {
          _updateCookieJar(uri, response.headers['set-cookie']);
          return response;
        }
      }

      final hostCookies = await HttpUtils.fetchHostCookies(
        _client,
        uri,
        baseHeaders,
        const Duration(seconds: 15),
      );
      if (hostCookies != null) {
        _cookieJar[uri.host] = hostCookies;
        try {
          response = await _client
              .get(uri, headers: _headersFor(uri, baseHeaders))
              .timeout(const Duration(seconds: 15));
        } catch (_) {
          return null;
        }
      }
    }

    _updateCookieJar(uri, response.headers['set-cookie']);
    return response;
  }

  void _updateCookieJar(Uri uri, String? setCookie) {
    final cookie = HttpUtils.cookieHeaderFromSetCookie(setCookie);
    if (cookie != null) {
      _cookieJar[uri.host] = cookie;
    }
  }
  
  /// Validates that a URL actually contains a recipe by attempting to parse it.
  Future<bool> _validateRecipeUrl(Uri uri) async {
    final parser = _recipeParser;
    if (parser == null) {
      return true; // No parser available, skip validation
    }
    try {
      await parser.parseUrl(uri.toString());
      return true;
    } catch (_) {
      return false; // Failed to parse recipe
    }
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
