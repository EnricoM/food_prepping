import 'ingredient.dart';

/// Parser for converting ingredient strings into structured Ingredient objects
class IngredientParser {
  /// Parse an ingredient string into a structured Ingredient
  /// 
  /// Handles various formats:
  /// - "2 cups flour"
  /// - "1/2 tsp salt"
  /// - "250g butter"
  /// - "salt" (no quantity/unit)
  /// - "a pinch of salt"
  /// - "to taste"
  static Ingredient parse(String ingredientString) {
    final trimmed = ingredientString.trim();
    if (trimmed.isEmpty) {
      return Ingredient(name: '', original: trimmed);
    }

    // Try to parse structured format: quantity unit name
    final structured = _parseStructured(trimmed);
    if (structured != null) {
      return structured;
    }

    // Try to parse with common prefixes like "a", "an", "some"
    final withPrefix = _parseWithPrefix(trimmed);
    if (withPrefix != null) {
      return withPrefix;
    }

    // Fallback: treat entire string as name
    return Ingredient(name: trimmed, original: trimmed);
  }

  /// Parse structured format: "quantity unit name" or "quantity name"
  static Ingredient? _parseStructured(String text) {
    // Pattern to match: optional whole number, optional fraction, optional unit, ingredient name
    // Examples: "2 cups flour", "1/2 tsp salt", "250g butter", "2-3 cloves garlic"
    final pattern = RegExp(
      r'^(?:(?<whole>\d+)\s*(?:-\s*(?<whole2>\d+))?\s*)?(?:(?<num>\d+)\s*/\s*(?<den>\d+)\s*)?(?<unit>[a-zA-Z]+(?:\.|s)?)\s+(?<name>.+)$',
      caseSensitive: false,
    );

    final match = pattern.firstMatch(text);
    if (match == null) {
      // Try without unit: "2 eggs", "1/2 onion"
      final noUnitPattern = RegExp(
        r'^(?:(?<whole>\d+)\s*(?:-\s*(?<whole2>\d+))?\s*)?(?:(?<num>\d+)\s*/\s*(?<den>\d+)\s*)?(?<name>.+)$',
        caseSensitive: false,
      );
      final noUnitMatch = noUnitPattern.firstMatch(text);
      if (noUnitMatch != null) {
        final quantity = _extractQuantity(noUnitMatch);
        final name = noUnitMatch.namedGroup('name')?.trim() ?? text;
        if (quantity != null && name.isNotEmpty && name != text) {
          return Ingredient(
            quantity: quantity,
            name: name,
            original: text,
          );
        }
      }
      return null;
    }

    final quantity = _extractQuantity(match);
    final unit = match.namedGroup('unit')?.trim().toLowerCase();
    final name = match.namedGroup('name')?.trim();

    if (name == null || name.isEmpty) {
      return null;
    }

    // Validate unit - check if it's actually a unit or part of the name
    final validUnit = _isValidUnit(unit);
    if (!validUnit && quantity == null) {
      // If we can't parse quantity and unit doesn't look valid, treat as name
      return null;
    }

    return Ingredient(
      quantity: quantity,
      unit: validUnit ? unit : null,
      name: validUnit ? name : (unit != null ? '$unit $name' : name),
      original: text,
    );
  }

  /// Extract quantity from regex match (handles whole numbers, fractions, and ranges)
  static double? _extractQuantity(RegExpMatch match) {
    final whole = match.namedGroup('whole');
    final whole2 = match.namedGroup('whole2');
    final num = match.namedGroup('num');
    final den = match.namedGroup('den');

    double? quantity;

    if (whole != null) {
      quantity = double.tryParse(whole);
      if (whole2 != null) {
        // Range like "2-3" - use average
        final qty2 = double.tryParse(whole2);
        if (qty2 != null && quantity != null) {
          quantity = (quantity + qty2) / 2;
        }
      }
    }

    if (num != null && den != null) {
      final numerator = double.tryParse(num);
      final denominator = double.tryParse(den);
      if (numerator != null && denominator != null && denominator != 0) {
        final fraction = numerator / denominator;
        quantity = (quantity ?? 0) + fraction;
      }
    }

    return quantity;
  }

  /// Check if a string is a valid unit of measurement
  static bool _isValidUnit(String? unit) {
    if (unit == null || unit.isEmpty) {
      return false;
    }

    final normalized = unit.toLowerCase().replaceAll('.', '').replaceAll('s', '');
    
    const validUnits = {
      // Volume
      'cup', 'c', 'tablespoon', 'tbsp', 't', 'teaspoon', 'tsp', 'pint', 'pt',
      'quart', 'qt', 'gallon', 'gal', 'fluid ounce', 'fl oz', 'milliliter', 'ml',
      'liter', 'l', 'litre',
      // Weight
      'ounce', 'oz', 'pound', 'lb', 'gram', 'g', 'kilogram', 'kg',
      // Count/Other
      'piece', 'pc', 'pcs', 'clove', 'slice', 'stalk', 'bunch', 'head', 'leaf',
      'leaves', 'can', 'package', 'pkg', 'pack', 'bottle', 'btl', 'container',
      // Length
      'inch', 'in', 'foot', 'ft', 'centimeter', 'cm', 'meter', 'm',
    };

    return validUnits.contains(normalized);
  }

  /// Parse ingredients with common prefixes like "a", "an", "some"
  static Ingredient? _parseWithPrefix(String text) {
    final lower = text.toLowerCase();
    
    // Handle "a pinch of", "a dash of", etc.
    final pinchPattern = RegExp(r'^a\s+(pinch|dash|sprinkle|drop)\s+of\s+(.+)$', caseSensitive: false);
    final pinchMatch = pinchPattern.firstMatch(text);
    if (pinchMatch != null) {
      final name = pinchMatch.group(2)?.trim() ?? '';
      return Ingredient(
        name: name,
        original: text,
      );
    }

    // Handle "a cup of", "an ounce of", etc.
    final aUnitPattern = RegExp(
      r'^a\s+(cup|tablespoon|teaspoon|pint|quart|gallon|ounce|pound|gram|kilogram|piece|clove|slice|stalk|bunch|head|can|package|bottle)\s+of\s+(.+)$',
      caseSensitive: false,
    );
    final aUnitMatch = aUnitPattern.firstMatch(text);
    if (aUnitMatch != null) {
      final unit = aUnitMatch.group(1)?.trim().toLowerCase();
      final name = aUnitMatch.group(2)?.trim() ?? '';
      if (_isValidUnit(unit) && name.isNotEmpty) {
        return Ingredient(
          quantity: 1.0,
          unit: unit,
          name: name,
          original: text,
        );
      }
    }

    // Handle "to taste", "as needed", etc.
    if (lower.contains('to taste') || lower.contains('as needed') || lower.contains('optional')) {
      return Ingredient(
        name: text,
        original: text,
      );
    }

    return null;
  }

  /// Parse a list of ingredient strings
  static List<Ingredient> parseList(List<String> ingredientStrings) {
    return ingredientStrings
        .map((s) => parse(s))
        .where((ing) => ing.name.isNotEmpty)
        .toList(growable: false);
  }
}

