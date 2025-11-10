import 'dart:convert';

import 'package:http/http.dart' as http;

class IngredientSuggestion {
  IngredientSuggestion({required this.name, this.brand});

  final String name;
  final String? brand;

  String get label => brand == null || brand!.isEmpty ? name : '$name — $brand';
}

class IngredientSearchService {
  IngredientSearchService({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<IngredientSuggestion>> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) {
      return const [];
    }

    final uri = Uri.https('world.openfoodfacts.org', '/cgi/search.pl', {
      'search_terms': trimmed,
      'search_simple': '1',
      'json': '1',
      'page_size': '15',
      'fields': 'product_name,brands',
    });

    try {
      final response =
          await _client.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) {
        return const [];
      }
      final decoded = jsonDecode(response.body) as Map<String, dynamic>?;
      final products = decoded?['products'];
      if (products is! List) {
        return const [];
      }
      final suggestions = <IngredientSuggestion>[];
      for (final product in products) {
        if (product is! Map<String, dynamic>) continue;
        final name = (product['product_name'] as String?)?.trim();
        if (name == null || name.isEmpty) continue;
        final brand = (product['brands'] as String?)?.split(',').first.trim();
        suggestions.add(IngredientSuggestion(name: name, brand: brand));
      }
      return suggestions;
    } catch (_) {
      return const [];
    }
  }

  void dispose() {
    _client.close();
  }
}
