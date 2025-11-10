import 'dart:convert';

import 'package:http/http.dart' as http;

import 'models.dart';

class BarcodeLookupService {
  BarcodeLookupService({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Future<BarcodeProduct?> lookup(String barcode) async {
    final trimmed = barcode.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final url = Uri.https(
      'world.openfoodfacts.org',
      '/api/v0/product/$trimmed.json',
    );
    final response = await _client
        .get(url)
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      return null;
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>?;
    if (decoded == null || decoded['status'] != 1) {
      return null;
    }
    final product = decoded['product'];
    if (product is! Map<String, dynamic>) {
      return null;
    }
    final name = (product['product_name'] as String?)?.trim();
    if (name == null || name.isEmpty) {
      return null;
    }
    final brands = (product['brands'] as String?)
        ?.split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .join(', ');
    final categoriesTags = (product['categories_tags'] as List?)
        ?.whereType<String>()
        .map((e) => e.replaceAll('en:', '').replaceAll('-', ' '))
        .toList();

    return BarcodeProduct(
      code: trimmed,
      name: name,
      brands: brands,
      quantity: (product['quantity'] as String?)?.trim(),
      imageUrl:
          (product['image_small_url'] as String?) ??
          (product['image_front_small_url'] as String?),
      categories: categoriesTags,
    );
  }

  void dispose() => _client.close();
}
