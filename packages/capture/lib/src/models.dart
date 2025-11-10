import 'package:intl/intl.dart';

class ReceiptItemSuggestion {
  ReceiptItemSuggestion({
    required this.label,
    required this.confidence,
    this.quantity,
    this.unit,
    this.price,
  });

  final String label;
  final double confidence;
  final double? quantity;
  final String? unit;
  final double? price;

  ReceiptItemSuggestion copyWith({
    String? label,
    double? confidence,
    double? quantity,
    String? unit,
    double? price,
  }) {
    return ReceiptItemSuggestion(
      label: label ?? this.label,
      confidence: confidence ?? this.confidence,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      price: price ?? this.price,
    );
  }

  @override
  String toString() {
    final formattedPrice =
        price == null ? null : NumberFormat.simpleCurrency().format(price);
    final parts = <String>[label];
    if (quantity != null) {
      final qtyText =
          unit == null || unit!.isEmpty ? '${quantity!}' : '${quantity!} $unit';
      parts.add(qtyText);
    }
    if (formattedPrice != null) {
      parts.add(formattedPrice);
    }
    return parts.join(' • ');
  }
}

class BarcodeProduct {
  BarcodeProduct({
    required this.code,
    required this.name,
    this.brands,
    this.quantity,
    this.imageUrl,
    this.categories,
  });

  final String code;
  final String name;
  final String? brands;
  final String? quantity;
  final String? imageUrl;
  final List<String>? categories;

  String get displayTitle =>
      brands == null || brands!.isEmpty ? name : '$name — $brands';
}
