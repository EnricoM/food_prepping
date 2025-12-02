import 'ingredient.dart';
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
        .map((ingredient) => ingredient.scale(scaleFactor))
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
    final ingredients = recipe.ingredientStrings.join(' ').toLowerCase();

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
  final List<Ingredient> scaledIngredients;
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

