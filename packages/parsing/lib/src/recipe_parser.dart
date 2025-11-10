import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

import 'package:core/core.dart';

class RecipeParseException implements Exception {
  RecipeParseException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => 'RecipeParseException($message)';
}

class RecipeParser {
  RecipeParser({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<RecipeParseResult> parseUrl(
    String url, {
    Duration timeout = const Duration(seconds: 20),
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse(url);
    http.Response? lastResponse;

    final hasCustomUserAgent = headers?.containsKey('User-Agent') ?? false;
    final headerCandidates = <Map<String, String>>[
      {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
            '(KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
        'Accept':
            'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.9,nl;q=0.8',
        'Accept-Encoding': 'gzip, deflate, br',
      },
      if (!hasCustomUserAgent) {'User-Agent': 'curl/8.5.0', 'Accept': '*/*'},
    ];

    if (headerCandidates.isEmpty) {
      headerCandidates.add({});
    }

    for (final candidate in headerCandidates) {
      final effectiveHeaders = <String, String>{...candidate, ...?headers};

      try {
        final response = await _getWithFallback(uri, effectiveHeaders, timeout);
        if (response.statusCode < 400) {
          final effectiveBody = _decodeBody(response);
          return parseHtml(effectiveBody, sourceUrl: uri.toString());
        }
        lastResponse = response;
      } on TimeoutException catch (e) {
        throw RecipeParseException('Request to $url timed out', cause: e);
      } on http.ClientException catch (e) {
        throw RecipeParseException('Failed to load $url', cause: e);
      }
    }

    final statusCode = lastResponse?.statusCode;
    throw RecipeParseException(
      statusCode != null
          ? 'Failed to load $url (HTTP $statusCode)'
          : 'Failed to load $url',
    );
  }

  Future<http.Response> _getWithFallback(
    Uri uri,
    Map<String, String> headers,
    Duration timeout,
  ) async {
    final initialCookies = await _fetchHostCookies(uri, headers, timeout);
    final requestHeaders = Map<String, String>.from(headers);
    if (initialCookies != null) {
      requestHeaders['Cookie'] = initialCookies;
    }

    http.Response response = await _client
        .get(uri, headers: requestHeaders)
        .timeout(timeout);

    if (!_shouldRetry(response.statusCode)) {
      return response;
    }

    final responseCookies = _cookieHeaderFromSetCookie(
      response.headers['set-cookie'],
    );
    if (responseCookies != null) {
      final retryHeaders = Map<String, String>.from(headers)
        ..['Cookie'] = responseCookies;
      final retry = await _client
          .get(uri, headers: retryHeaders)
          .timeout(timeout);
      if (!_shouldRetry(retry.statusCode)) {
        return retry;
      }
      response = retry;
    }

    if (initialCookies == null) {
      final hostCookies = await _fetchHostCookies(uri, headers, timeout);
      if (hostCookies != null) {
        final retryHeaders = Map<String, String>.from(headers)
          ..['Cookie'] = hostCookies;
        final retry = await _client
            .get(uri, headers: retryHeaders)
            .timeout(timeout);
        if (!_shouldRetry(retry.statusCode)) {
          return retry;
        }
        response = retry;
      }
    }

    return response;
  }

  bool _shouldRetry(int statusCode) => statusCode == 401 || statusCode == 403;

  Future<String?> _fetchHostCookies(
    Uri uri,
    Map<String, String> headers,
    Duration timeout,
  ) async {
    final rootUri = uri.replace(path: '/');
    try {
      final retryHeaders = Map<String, String>.from(headers)
        ..remove('Accept-Encoding');
      final response = await _client
          .get(rootUri, headers: retryHeaders)
          .timeout(timeout);
      return _cookieHeaderFromSetCookie(response.headers['set-cookie']);
    } catch (_) {
      return null;
    }
  }

  String? _cookieHeaderFromSetCookie(String? setCookie) {
    if (setCookie == null || setCookie.isEmpty) {
      return null;
    }
    final matches = RegExp(r'([^=,\s]+=[^;]+)').allMatches(setCookie);
    final values = matches
        .map((match) => match.group(0))
        .whereType<String>()
        .toList();
    if (values.isEmpty) {
      return null;
    }
    return values.join('; ');
  }

  Future<RecipeParseResult> parseHtml(String html, {String? sourceUrl}) async {
    final document = html_parser.parse(html);
    final uri = sourceUrl != null ? Uri.tryParse(sourceUrl) : null;
    final notes = <String>[];

    final jsonLdResult = _parseJsonLd(document, uri, notes);
    if (jsonLdResult != null) {
      return jsonLdResult;
    }

    final microdataResult = _parseMicrodata(document, uri, notes);
    if (microdataResult != null) {
      return microdataResult;
    }

    final heuristicResult = _parseHeuristic(document, uri, notes);
    if (heuristicResult != null) {
      return heuristicResult;
    }

    throw RecipeParseException('Unable to detect recipe content on the page');
  }

  void close() {
    _client.close();
  }

  RecipeParseResult? _parseJsonLd(
    Document document,
    Uri? baseUri,
    List<String> notes,
  ) {
    final scripts = document.querySelectorAll(
      'script[type="application/ld+json"]',
    );
    for (final script in scripts) {
      final content = script.text.trim();
      if (content.isEmpty) continue;
      final data = _decodeJsonLd(content, notes);
      if (data == null) {
        continue;
      }

      final recipes = _collectRecipeNodes(data);
      for (final recipeNode in recipes) {
        final recipe = _recipeFromJson(recipeNode, baseUri);
        if (recipe != null) {
          notes.add('Parsed recipe via JSON-LD');
          return RecipeParseResult(
            recipe: recipe,
            strategy: 'JSON-LD',
            notes: notes,
          );
        }
      }
    }
    return null;
  }

  RecipeParseResult? _parseMicrodata(
    Document document,
    Uri? baseUri,
    List<String> notes,
  ) {
    final recipeNodes = document.querySelectorAll(
      '[itemtype*="schema.org/Recipe"]',
    );
    if (recipeNodes.isEmpty) {
      return null;
    }

    for (final node in recipeNodes) {
      final recipe = _recipeFromMicrodata(node, baseUri);
      if (recipe != null) {
        notes.add('Parsed recipe via microdata');
        return RecipeParseResult(
          recipe: recipe,
          strategy: 'Microdata',
          notes: notes,
        );
      }
    }
    return null;
  }

  RecipeParseResult? _parseHeuristic(
    Document document,
    Uri? baseUri,
    List<String> notes,
  ) {
    final title =
        _elementText(document.querySelector('h1')) ??
        _elementText(document.querySelector('title'));
    if (title == null) {
      return null;
    }

    final ingredients = _extractSectionEntries(document, const [
      'ingredient',
      'ingredients',
      'ingrediënt',
      'ingrediënten',
      'ingredienten',
      'ingrediente',
      'ingredientes',
      'wat heb je nodig',
      'benodigdheden',
    ]);
    final instructions = _extractSectionEntries(
      document,
      const [
        'instruction',
        'instructions',
        'direction',
        'directions',
        'method',
        'methods',
        'bereiding',
        'bereidingswijze',
        'werkwijze',
        'stappen',
        'stap',
        'instructie',
        'instructies',
        'preparation',
        'prepare',
        'bereid',
        'hoe maak',
        'hoe bereid',
        'how to',
        'how do you',
      ],
      splitOnBreaks: true,
      filter: (items) {
        if (items.isEmpty) {
          return false;
        }
        if (_listsBasicallyEqual(items, ingredients)) {
          return false;
        }
        return true;
      },
    );

    if (ingredients.isEmpty || instructions.isEmpty) {
      return null;
    }

    final description = _elementAttr(
      document.querySelector('meta[name="description"]'),
      'content',
    );
    final ogImage = _elementAttr(
      document.querySelector(
        'meta[property="og:image"], meta[name="twitter:image"]',
      ),
      'content',
    );
    final imageUrl =
        ogImage ?? _elementAttr(document.querySelector('img'), 'src');

    notes.add('Parsed recipe via heuristic DOM parsing');
    return RecipeParseResult(
      recipe: Recipe(
        title: title,
        description: description,
        ingredients: ingredients,
        instructions: instructions,
        imageUrl: _resolveUrl(imageUrl, baseUri),
        sourceUrl: baseUri?.toString(),
        metadata: {
          if (imageUrl != null && baseUri != null) 'imageSource': imageUrl,
          'strategy': 'heuristic',
        },
      ),
      strategy: 'Heuristic',
      notes: notes,
    );
  }

  List<Map<String, Object?>> _collectRecipeNodes(dynamic data) {
    final results = <Map<String, Object?>>[];

    void walk(dynamic node) {
      if (node is Map<String, dynamic>) {
        final type = node['@type'];
        if (_containsRecipeType(type)) {
          results.add(node.cast<String, Object?>());
        }

        for (final value in node.values) {
          walk(value);
        }
      } else if (node is List) {
        for (final item in node) {
          walk(item);
        }
      }
    }

    walk(data);
    return results;
  }

  bool _containsRecipeType(Object? typeField) {
    if (typeField is String) {
      return typeField.toLowerCase() == 'recipe';
    }
    if (typeField is List) {
      return typeField.any(
        (value) => value is String && value.toLowerCase() == 'recipe',
      );
    }
    return false;
  }

  Recipe? _recipeFromJson(Map<String, Object?> node, Uri? baseUri) {
    final title = _clean(node['name']);
    final description = _clean(node['description']);
    final author = _extractAuthor(node['author']);
    final imageUrl = _extractImage(node['image'], baseUri);
    final ingredients = _extractIngredients(node);
    final instructions = _extractInstructions(node);
    final yieldValue = _clean(node['recipeYield'] ?? node['yield']);

    if (title == null || ingredients.isEmpty || instructions.isEmpty) {
      return null;
    }

    return Recipe(
      title: title,
      description: description,
      author: author,
      imageUrl: imageUrl,
      ingredients: ingredients,
      instructions: instructions,
      sourceUrl: baseUri?.toString(),
      yield: yieldValue,
      prepTime: _parseIso8601Duration(node['prepTime']),
      cookTime: _parseIso8601Duration(node['cookTime']),
      totalTime: _parseIso8601Duration(node['totalTime']),
      metadata: {
        if (node.containsKey('recipeCuisine')) 'cuisine': node['recipeCuisine'],
        if (node.containsKey('recipeCategory'))
          'category': node['recipeCategory'],
        if (node.containsKey('keywords')) 'keywords': node['keywords'],
      },
    );
  }

  Recipe? _recipeFromMicrodata(Element node, Uri? baseUri) {
    final title =
        _elementText(node.querySelector('[itemprop="name"]')) ??
        _elementText(node.querySelector('h1'));
    if (title == null) {
      return null;
    }

    final description = _elementText(
      node.querySelector('[itemprop="description"]'),
    );
    final ingredients = node
        .querySelectorAll(
          '[itemprop="recipeIngredient"], [itemprop="ingredients"]',
        )
        .map((element) => _clean(element.text))
        .nonNulls
        .toList();

    final instructionNodes = node.querySelectorAll(
      '[itemprop="recipeInstructions"]',
    );
    final instructions = instructionNodes.isEmpty
        ? _collectListItems(node.querySelectorAll('ol li, ul li'))
        : instructionNodes
              .expand((element) => _extractInstructionNode(element))
              .nonNulls
              .map(_clean)
              .nonNulls
              .toList();

    if (ingredients.isEmpty || instructions.isEmpty) {
      return null;
    }

    final imgNode = node.querySelector('[itemprop="image"]');
    String? imageUrl;
    if (imgNode != null) {
      imageUrl =
          _elementAttr(imgNode, 'content') ??
          _elementAttr(imgNode, 'src') ??
          _elementText(imgNode);
    }

    final authorNode = node.querySelector('[itemprop="author"]');
    final author =
        _elementText(authorNode) ?? _elementAttr(authorNode, 'content');

    final yieldValue = _elementText(
      node.querySelector('[itemprop="recipeYield"]'),
    );

    return Recipe(
      title: title,
      description: description,
      author: author,
      imageUrl: _resolveUrl(imageUrl, baseUri),
      ingredients: ingredients,
      instructions: instructions,
      sourceUrl: baseUri?.toString(),
      yield: yieldValue,
      prepTime: _parseIso8601Duration(
        _elementAttr(node.querySelector('[itemprop="prepTime"]'), 'content') ??
            _elementText(node.querySelector('[itemprop="prepTime"]')),
      ),
      cookTime: _parseIso8601Duration(
        _elementAttr(node.querySelector('[itemprop="cookTime"]'), 'content') ??
            _elementText(node.querySelector('[itemprop="cookTime"]')),
      ),
      totalTime: _parseIso8601Duration(
        _elementAttr(node.querySelector('[itemprop="totalTime"]'), 'content') ??
            _elementText(node.querySelector('[itemprop="totalTime"]')),
      ),
      metadata: {if (yieldValue != null) 'servings': yieldValue},
    );
  }

  List<String> _extractSectionEntries(
    Document document,
    List<String> keywords, {
    bool splitOnBreaks = false,
    bool Function(List<String> items)? filter,
  }) {
    final normalizedKeywords = keywords.map(_normalizeHeadingKeyword).toSet();
    final headings = document.querySelectorAll('h2, h3, h4, h5, h6');

    for (final heading in headings) {
      final normalizedHeading = _normalizeHeadingKeyword(heading.text);
      final matched = normalizedKeywords.any(
        (keyword) => normalizedHeading.contains(keyword),
      );
      if (!matched) {
        continue;
      }

      final candidates = _extractItemsFromHeading(
        heading,
        splitOnBreaks: splitOnBreaks,
      );
      if (candidates.isEmpty) {
        continue;
      }
      if (filter != null && !filter(candidates)) {
        continue;
      }
      return candidates;
    }

    return const [];
  }

  List<String> _extractItemsFromHeading(
    Element heading, {
    required bool splitOnBreaks,
  }) {
    final listCandidates = _extractListAfterHeading(heading);
    if (listCandidates.isNotEmpty) {
      return listCandidates;
    }

    final parent = heading.parent;
    if (splitOnBreaks && parent != null) {
      final textBlocks = _extractTextBlocks(parent, heading);
      if (textBlocks.isNotEmpty) {
        return textBlocks;
      }
    }

    final sibling = heading.nextElementSibling;
    if (sibling != null) {
      final siblingList = _extractListItemsWithin(sibling);
      if (siblingList.isNotEmpty) {
        return siblingList;
      }
      if (splitOnBreaks) {
        final blocks = _extractTextBlocks(sibling, null);
        if (blocks.isNotEmpty) {
          return blocks;
        }
      }
      final text = _clean(sibling.text);
      if (text != null) {
        return [text];
      }
    }

    if (parent != null) {
      final text = _textAfterHeading(parent, heading);
      if (text != null) {
        return [text];
      }
    }

    return const [];
  }

  List<String> _extractListAfterHeading(Element heading) {
    final parent = heading.parent;
    if (parent == null) {
      return const [];
    }

    Element? current = heading.nextElementSibling;
    while (current != null) {
      final listItems = _extractListItemsWithin(current);
      if (listItems.isNotEmpty) {
        return listItems;
      }
      if (_isHeadingElement(current)) {
        break;
      }
      current = current.nextElementSibling;
    }

    return const [];
  }

  List<String> _extractListItemsWithin(Element element) {
    if (element.localName == 'ul' || element.localName == 'ol') {
      return element.children
          .map((child) => _clean(child.text))
          .whereType<String>()
          .toList();
    }
    final nested = element.querySelector('ul, ol');
    if (nested == null) {
      return const [];
    }
    return nested.children
        .map((child) => _clean(child.text))
        .whereType<String>()
        .toList();
  }

  List<String> _extractTextBlocks(Element container, Element? heading) {
    final results = <String>[];
    final buffer = StringBuffer();
    var hasContent = false;
    var collecting = heading == null;

    void flush() {
      if (!hasContent) {
        return;
      }
      final text = _clean(buffer.toString());
      if (text != null) {
        results.add(text);
      }
      buffer.clear();
      hasContent = false;
    }

    for (final node in container.nodes) {
      if (!collecting) {
        if (identical(node, heading)) {
          collecting = true;
        }
        continue;
      }

      if (node is Element &&
          _isHeadingElement(node) &&
          !identical(node, heading)) {
        break;
      }

      if (node is Element &&
          (node.localName == 'ul' || node.localName == 'ol')) {
        final listItems = node.children
            .map((child) => _clean(child.text))
            .nonNulls
            .toList();
        if (listItems.isNotEmpty) {
          results.addAll(listItems);
        }
        continue;
      }

      if (node is Element &&
          (node.localName == 'br' || node.localName == 'p')) {
        if (node.localName == 'p') {
          final text = _clean(node.text);
          if (text != null) {
            if (hasContent) {
              buffer.write(' ');
            }
            buffer.write(text);
            hasContent = true;
          }
        }
        flush();
        continue;
      }

      final text = _clean(node.text);
      if (text != null) {
        if (hasContent) {
          buffer.write(' ');
        }
        buffer.write(text);
        hasContent = true;
      }
    }

    flush();
    return results;
  }

  String? _textAfterHeading(Element container, Element heading) {
    final buffer = StringBuffer();
    var collecting = false;
    var hasContent = false;

    for (final node in container.nodes) {
      if (!collecting) {
        if (identical(node, heading)) {
          collecting = true;
        }
        continue;
      }

      if (node is Element && _isHeadingElement(node)) {
        break;
      }

      final text = _clean(node.text);
      if (text != null) {
        if (hasContent) {
          buffer.write(' ');
        }
        buffer.write(text);
        hasContent = true;
      }
    }

    if (!hasContent) {
      return null;
    }

    return buffer.toString().trim();
  }

  bool _isHeadingElement(Element element) {
    final tag = element.localName?.toLowerCase();
    return tag != null && tag.startsWith('h') && tag.length == 2;
  }

  String _normalizeHeadingKeyword(String input) {
    final lower = input.toLowerCase();
    final buffer = StringBuffer();
    for (final rune in lower.runes) {
      final char = String.fromCharCode(rune);
      buffer.write(_diacriticMap[char] ?? char);
    }
    return buffer.toString();
  }

  Iterable<String?> _extractInstructionNode(Element element) sync* {
    final text = _clean(element.text);
    if (text != null) {
      yield text;
    }
    final items = element.querySelectorAll('[itemprop="itemListElement"]');
    if (items.isNotEmpty) {
      for (final item in items) {
        final value = _clean(item.text);
        if (value != null) {
          yield value;
        }
      }
    }
  }

  List<String> _collectListItems(List<Element> nodes) {
    return nodes.map((element) => _clean(element.text)).nonNulls.toList();
  }

  List<String> _extractIngredients(Map<String, Object?> node) {
    final ingredients = <String>[];
    final ingredientField = node['recipeIngredient'] ?? node['ingredients'];

    void addItem(Object? value) {
      if (value == null) return;
      if (value is String) {
        final normalized = _clean(value);
        if (normalized != null) {
          ingredients.add(normalized);
        }
      } else if (value is Map<String, Object?>) {
        addItem(value['text']);
      } else if (value is List) {
        for (final item in value) {
          addItem(item);
        }
      }
    }

    addItem(ingredientField);
    return ingredients;
  }

  List<String> _extractInstructions(Map<String, Object?> node) {
    final instructions = <String>[];

    void addInstruction(Object? value) {
      if (value == null) return;
      if (value is String) {
        final normalized = _clean(value);
        if (normalized != null) {
          instructions.add(normalized);
        }
      } else if (value is Map<String, Object?>) {
        addInstruction(value['text']);
        addInstruction(value['itemListElement']);
      } else if (value is List) {
        for (final item in value) {
          addInstruction(item);
        }
      }
    }

    addInstruction(node['recipeInstructions']);
    return instructions;
  }

  String? _extractAuthor(Object? authorField) {
    if (authorField == null) {
      return null;
    }
    if (authorField is String) {
      return _clean(authorField);
    }
    if (authorField is Map<String, Object?>) {
      return _clean(authorField['name']);
    }
    if (authorField is List) {
      return authorField.map(_extractAuthor).whereType<String>().firstOrNull;
    }
    return null;
  }

  String? _extractImage(Object? imageField, Uri? baseUri) {
    if (imageField == null) {
      return null;
    }
    if (imageField is String) {
      final cleaned = _clean(imageField);
      return cleaned == null ? null : _resolveUrl(cleaned, baseUri);
    }
    if (imageField is Map<String, Object?>) {
      final url = imageField['url'] ?? imageField['@id'];
      if (url is String) {
        final cleaned = _clean(url);
        return cleaned == null ? null : _resolveUrl(cleaned, baseUri);
      }
    }
    if (imageField is List) {
      for (final item in imageField) {
        final resolved = _extractImage(item, baseUri);
        if (resolved != null) {
          return resolved;
        }
      }
    }
    return null;
  }

  Duration? _parseIso8601Duration(Object? value) {
    if (value == null) {
      return null;
    }
    final text = value.toString().trim();
    if (text.isEmpty || !text.startsWith('P')) {
      return null;
    }
    final regex = RegExp(
      r'P(?:(\d+)Y)?(?:(\d+)M)?(?:(\d+)W)?(?:(\d+)D)?(?:T(?:(\d+)H)?(?:(\d+)M)?(?:(\d+(?:\.\d+)?)S)?)?',
    );
    final match = regex.firstMatch(text);
    if (match == null) {
      return null;
    }

    int parseGroup(int index) => int.tryParse(match.group(index) ?? '') ?? 0;
    final years = parseGroup(1);
    final months = parseGroup(2);
    final weeks = parseGroup(3);
    final days = parseGroup(4);
    final hours = parseGroup(5);
    final minutes = parseGroup(6);
    final seconds = double.tryParse(match.group(7) ?? '') ?? 0;

    final totalDays = days + weeks * 7 + months * 30 + years * 365;
    return Duration(
      days: totalDays,
      hours: hours,
      minutes: minutes,
      seconds: seconds.round(),
    );
  }

  String? _resolveUrl(String? value, Uri? baseUri) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (baseUri == null) {
      return value;
    }
    return baseUri.resolve(value).toString();
  }

  String _decodeBody(http.Response response) {
    final contentType = response.headers['content-type'];
    String? charset;
    if (contentType != null) {
      final match = RegExp(
        r'charset=([^\s;]+)',
        caseSensitive: false,
      ).firstMatch(contentType);
      charset = match?.group(1);
    }
    final encoding = charset != null ? Encoding.getByName(charset) : null;
    return encoding?.decode(response.bodyBytes) ??
        utf8.decode(response.bodyBytes);
  }

  dynamic _decodeJsonLd(String content, List<String> notes) {
    try {
      return jsonDecode(content);
    } on FormatException catch (error) {
      final sanitized = _sanitizeJsonLd(content);
      if (sanitized != content) {
        try {
          notes.add(
            'Recovered malformed JSON-LD with escaped control characters',
          );
          return jsonDecode(sanitized);
        } catch (innerError) {
          notes.add(
            'Failed to parse JSON-LD after sanitizing: ${innerError is FormatException ? innerError.message : innerError}',
          );
        }
      } else {
        notes.add('Invalid JSON-LD: ${error.message}');
      }
    } catch (error) {
      notes.add('Invalid JSON-LD: $error');
    }
    return null;
  }

  String _sanitizeJsonLd(String content) {
    final buffer = StringBuffer();
    var inString = false;
    var escape = false;

    for (var i = 0; i < content.length; i++) {
      final char = content[i];

      if (!inString) {
        if (char == '"') {
          inString = true;
        }
        buffer.write(char);
        continue;
      }

      if (escape) {
        buffer.write(char);
        escape = false;
        continue;
      }

      if (char == '\\') {
        buffer.write(char);
        escape = true;
        continue;
      }

      if (char == '"') {
        buffer.write(char);
        inString = false;
        continue;
      }

      final code = char.codeUnitAt(0);
      if (code < 0x20) {
        switch (char) {
          case '\n':
            buffer.write('\\n');
            break;
          case '\r':
            buffer.write('\\r');
            break;
          case '\t':
            buffer.write('\\t');
            break;
          default:
            buffer.write('\\u${code.toRadixString(16).padLeft(4, '0')}');
            break;
        }
        continue;
      }

      buffer.write(char);
    }

    return buffer.toString();
  }

  bool _listsBasicallyEqual(List<String> a, List<String> b) {
    if (a.isEmpty || b.isEmpty || a.length != b.length) {
      return false;
    }
    final normalizedA = a.map(_normalizeForComparison).toList()..sort();
    final normalizedB = b.map(_normalizeForComparison).toList()..sort();
    for (var i = 0; i < normalizedA.length; i++) {
      if (normalizedA[i] != normalizedB[i]) {
        return false;
      }
    }
    return true;
  }

  String _normalizeForComparison(String input) {
    final normalized = _normalizeHeadingKeyword(input);
    final buffer = StringBuffer();
    String? previous;
    for (final rune in normalized.runes) {
      final char = String.fromCharCode(rune);
      if (RegExp(r'[a-z0-9]').hasMatch(char)) {
        buffer.write(char);
        previous = char;
      } else if (char == ' ' && previous != ' ') {
        buffer.write(char);
        previous = char;
      }
    }
    return buffer.toString().trim();
  }
}

String? _clean(Object? value) {
  if (value == null) {
    return null;
  }
  final text = value.toString().trim();
  if (text.isEmpty) {
    return null;
  }
  return text;
}

String? _elementText(Element? element) => _clean(element?.text);

String? _elementAttr(Element? element, String attribute) =>
    _clean(element?.attributes[attribute]);

const Map<String, String> _diacriticMap = {
  'á': 'a',
  'à': 'a',
  'â': 'a',
  'ä': 'a',
  'ã': 'a',
  'å': 'a',
  'ā': 'a',
  'ă': 'a',
  'ą': 'a',
  'æ': 'ae',
  'ç': 'c',
  'ć': 'c',
  'č': 'c',
  'ď': 'd',
  'ð': 'd',
  'é': 'e',
  'è': 'e',
  'ê': 'e',
  'ë': 'e',
  'ě': 'e',
  'ę': 'e',
  'ğ': 'g',
  'í': 'i',
  'ì': 'i',
  'î': 'i',
  'ï': 'i',
  'ī': 'i',
  'į': 'i',
  'ł': 'l',
  'ń': 'n',
  'ñ': 'n',
  'ň': 'n',
  'ó': 'o',
  'ò': 'o',
  'ô': 'o',
  'ö': 'o',
  'õ': 'o',
  'ő': 'o',
  'ø': 'o',
  'œ': 'oe',
  'ß': 'ss',
  'ś': 's',
  'š': 's',
  'ú': 'u',
  'ù': 'u',
  'û': 'u',
  'ü': 'u',
  'ů': 'u',
  'ű': 'u',
  'ý': 'y',
  'ÿ': 'y',
  'ž': 'z',
  'ź': 'z',
  'ż': 'z',
};
