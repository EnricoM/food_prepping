/// Structured representation of a recipe ingredient
class Ingredient {
  Ingredient({
    this.quantity,
    this.unit,
    required this.name,
    String? original,
  }) : original = original ?? _buildDisplayString(quantity, unit, name);

  /// Numeric quantity (e.g., 2.5, 1.5 for "1 1/2")
  final double? quantity;

  /// Unit of measurement (e.g., "cup", "tbsp", "g", "ml")
  final String? unit;

  /// Name of the ingredient (e.g., "flour", "salt")
  final String name;

  /// Original string representation (for backward compatibility and display)
  final String original;

  /// Get a display string for this ingredient
  String get displayString => original;

  /// Check if this ingredient has structured data (quantity and/or unit)
  bool get isStructured => quantity != null || unit != null;

  /// Get just the ingredient name (without quantity/unit)
  String get nameOnly => name;

  Ingredient copyWith({
    double? quantity,
    String? unit,
    String? name,
    String? original,
  }) {
    return Ingredient(
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      name: name ?? this.name,
      original: original ?? this.original,
    );
  }

  /// Scale this ingredient by a factor
  Ingredient scale(double factor) {
    if (quantity == null) {
      return this; // Can't scale without a quantity
    }
    final scaledQuantity = quantity! * factor;
    return copyWith(
      quantity: scaledQuantity,
      original: _buildDisplayString(scaledQuantity, unit, name),
    );
  }

  static String _buildDisplayString(double? quantity, String? unit, String name) {
    if (quantity == null && unit == null) {
      return name;
    }
    final parts = <String>[];
    if (quantity != null) {
      parts.add(_formatQuantity(quantity));
    }
    if (unit != null && unit.isNotEmpty) {
      parts.add(unit);
    }
    if (name.isNotEmpty) {
      parts.add(name);
    }
    return parts.join(' ');
  }

  static String _formatQuantity(double quantity) {
    if (quantity == quantity.truncateToDouble()) {
      return quantity.toInt().toString();
    }

    // Try to represent as a fraction
    final whole = quantity.truncate();
    final fraction = quantity - whole;

    // Common fractions
    const commonFractions = [
      (1 / 8, '1/8'),
      (1 / 4, '1/4'),
      (1 / 3, '1/3'),
      (3 / 8, '3/8'),
      (1 / 2, '1/2'),
      (5 / 8, '5/8'),
      (2 / 3, '2/3'),
      (3 / 4, '3/4'),
      (7 / 8, '7/8'),
    ];

    for (final (value, label) in commonFractions) {
      if ((fraction - value).abs() < 0.01) {
        if (whole > 0) {
          return '${whole.toInt()} $label';
        }
        return label;
      }
    }

    // If no common fraction matches, round to 1 decimal place
    final rounded = quantity.toStringAsFixed(1);
    if (rounded.endsWith('.0')) {
      return rounded.substring(0, rounded.length - 2);
    }
    return rounded;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ingredient &&
          runtimeType == other.runtimeType &&
          quantity == other.quantity &&
          unit == other.unit &&
          name == other.name;

  @override
  int get hashCode => quantity.hashCode ^ unit.hashCode ^ name.hashCode;

  @override
  String toString() => original;
}

