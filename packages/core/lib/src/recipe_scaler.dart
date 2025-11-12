import 'recipe.dart';

/// Service for scaling recipes to different serving sizes
class RecipeScaler {
  /// Scale a recipe to a target number of servings
  /// 
  /// [recipe] - The original recipe
  /// [targetServings] - Desired number of servings
  /// [originalServings] - Original number of servings (if null, will try to extract from recipe)
  /// 
  /// Returns a scaled recipe with adjusted ingredients and serving information
  static ScaledRecipe scaleRecipe({
    required Recipe recipe,
    required int targetServings,
    int? originalServings,
  }) {
    final original = originalServings ?? _extractServings(recipe) ?? 4;
    final scaleFactor = targetServings / original;

    final scaledIngredients = recipe.ingredients
        .map((ingredient) => _scaleIngredient(ingredient, scaleFactor))
        .toList();

    final scaledPrepTime = recipe.prepTime != null
        ? Duration(
            milliseconds: (recipe.prepTime!.inMilliseconds * scaleFactor).round(),
          )
        : null;

    final scaledCookTime = recipe.cookTime != null
        ? Duration(
            milliseconds: (recipe.cookTime!.inMilliseconds * scaleFactor).round(),
          )
        : null;

    final scaledTotalTime = recipe.totalTime != null
        ? Duration(
            milliseconds: (recipe.totalTime!.inMilliseconds * scaleFactor).round(),
          )
        : null;

    return ScaledRecipe(
      recipe: recipe,
      originalServings: original,
      targetServings: targetServings,
      scaleFactor: scaleFactor,
      scaledIngredients: scaledIngredients,
      scaledPrepTime: scaledPrepTime,
      scaledCookTime: scaledCookTime,
      scaledTotalTime: scaledTotalTime,
    );
  }

  /// Scale an ingredient string by a factor
  static String _scaleIngredient(String ingredient, double factor) {
    // Pattern to match quantities at the start: "2 cups", "1/2 tsp", "250g", etc.
    final quantityPattern = RegExp(
      r'^(\d+(?:\.\d+)?)\s*(?:/\s*(\d+))?\s*([a-zA-Z]+)?\s*(.*)$',
      caseSensitive: false,
    );

    final match = quantityPattern.firstMatch(ingredient.trim());
    if (match == null) {
      // No quantity found, return as-is
      return ingredient;
    }

    final wholePart = double.tryParse(match.group(1) ?? '') ?? 0.0;
    final fractionPart = match.group(2);
    final unit = match.group(3)?.trim() ?? '';
    final ingredientName = match.group(4)?.trim() ?? '';

    // Calculate original quantity
    double originalQuantity = wholePart;
    if (fractionPart != null) {
      final denominator = double.tryParse(fractionPart) ?? 1.0;
      originalQuantity = wholePart + (1.0 / denominator);
    }

    // Scale the quantity
    final scaledQuantity = originalQuantity * factor;

    // Format the scaled quantity nicely
    final formattedQuantity = _formatQuantity(scaledQuantity);

    // Reconstruct the ingredient string
    if (unit.isNotEmpty && ingredientName.isNotEmpty) {
      return '$formattedQuantity $unit $ingredientName';
    } else if (unit.isNotEmpty) {
      return '$formattedQuantity $unit';
    } else if (ingredientName.isNotEmpty) {
      return '$formattedQuantity $ingredientName';
    } else {
      return formattedQuantity;
    }
  }

  /// Format a quantity nicely (e.g., 1.5 -> "1 1/2", 2.0 -> "2", 0.75 -> "3/4")
  static String _formatQuantity(double quantity) {
    if (quantity == quantity.truncateToDouble()) {
      return quantity.toInt().toString();
    }

    // Try to represent as a fraction
    final whole = quantity.truncate();
    final fraction = quantity - whole;

    // Common fractions
    final commonFractions = [
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

  /// Extract number of servings from recipe
  static int? _extractServings(Recipe recipe) {
    // Try servings from metadata
    if (recipe.servings != null) {
      final match = RegExp(r'(\d+)').firstMatch(recipe.servings!);
      if (match != null) {
        return int.tryParse(match.group(1) ?? '');
      }
    }

    // Try yield field
    if (recipe.yield != null) {
      final match = RegExp(r'(\d+)').firstMatch(recipe.yield!);
      if (match != null) {
        return int.tryParse(match.group(1) ?? '');
      }
    }

    return null;
  }

  /// Check if a recipe is good for batch cooking
  /// Recipes that freeze well, reheat well, or scale easily are good candidates
  static bool isGoodForBatchCooking(Recipe recipe) {
    final title = recipe.title.toLowerCase();
    final description = (recipe.description ?? '').toLowerCase();
    final ingredients = recipe.ingredients.join(' ').toLowerCase();

    final batchCookingKeywords = [
      'soup',
      'stew',
      'casserole',
      'lasagna',
      'pasta',
      'sauce',
      'curry',
      'chili',
      'marinade',
      'dressing',
      'bread',
      'muffin',
      'cookie',
      'freeze',
      'freezer',
      'meal prep',
      'batch',
      'make ahead',
    ];

    final text = '$title $description $ingredients';
    return batchCookingKeywords.any((keyword) => text.contains(keyword));
  }
}

/// Result of scaling a recipe
class ScaledRecipe {
  ScaledRecipe({
    required this.recipe,
    required this.originalServings,
    required this.targetServings,
    required this.scaleFactor,
    required this.scaledIngredients,
    this.scaledPrepTime,
    this.scaledCookTime,
    this.scaledTotalTime,
  });

  final Recipe recipe;
  final int originalServings;
  final int targetServings;
  final double scaleFactor;
  final List<String> scaledIngredients;
  final Duration? scaledPrepTime;
  final Duration? scaledCookTime;
  final Duration? scaledTotalTime;

  /// Get formatted scale factor (e.g., "2x", "1.5x", "0.5x")
  String get scaleFactorLabel {
    if (scaleFactor == scaleFactor.truncateToDouble()) {
      return '${scaleFactor.toInt()}x';
    }
    return '${scaleFactor.toStringAsFixed(1)}x';
  }
}

