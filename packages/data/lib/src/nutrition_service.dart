import 'package:core/core.dart';

import 'nutrition_info.dart';
import 'recipe_entity.dart';

/// Service for estimating and managing nutrition information
class NutritionService {
  /// Extract nutrition info from recipe metadata
  static NutritionInfo? extractFromMetadata(Recipe recipe) {
    final metadata = recipe.metadata;
    if (metadata.isEmpty) return null;

    // Try to extract from JSON-LD nutrition schema
    final nutrition = metadata['nutrition'] as Map<String, dynamic>?;
    if (nutrition != null) {
      return _parseNutritionMap(nutrition, recipe);
    }

    // Try common metadata keys
    final calories = _parseDouble(metadata['calories']) ??
        _parseDouble(metadata['nutrition.calories']);
    final protein = _parseDouble(metadata['protein']) ??
        _parseDouble(metadata['nutrition.protein']);
    final carbs = _parseDouble(metadata['carbohydrates']) ??
        _parseDouble(metadata['nutrition.carbohydrates']) ??
        _parseDouble(metadata['carbs']);
    final fat = _parseDouble(metadata['fat']) ??
        _parseDouble(metadata['nutrition.fat']);

    if (calories == null && protein == null && carbs == null && fat == null) {
      return null;
    }

    final servings = _extractServings(recipe);
    return NutritionInfo(
      calories: calories,
      protein: protein,
      carbohydrates: carbs,
      fat: fat,
      servings: servings,
    );
  }

  /// Estimate nutrition from ingredients (basic estimation)
  /// This is a simplified estimation - for accurate data, use actual nutrition APIs
  static NutritionInfo? estimateFromIngredients(Recipe recipe) {
    final ingredients = recipe.ingredients;
    if (ingredients.isEmpty) return null;

    // Basic estimation based on common ingredients
    // This is a simplified approach - real implementation would use a nutrition database
    double? estimatedCalories;
    double? estimatedProtein;
    double? estimatedCarbs;
    double? estimatedFat;

    for (final ingredient in ingredients) {
      final lower = ingredient.toLowerCase();
      final quantity = _extractQuantity(ingredient);

      // Very basic estimation (would need a proper database in production)
      if (lower.contains('chicken') || lower.contains('beef') || lower.contains('pork')) {
        estimatedCalories = (estimatedCalories ?? 0) + (200 * quantity);
        estimatedProtein = (estimatedProtein ?? 0) + (25 * quantity);
        estimatedFat = (estimatedFat ?? 0) + (10 * quantity);
      } else if (lower.contains('rice') || lower.contains('pasta')) {
        estimatedCalories = (estimatedCalories ?? 0) + (130 * quantity);
        estimatedCarbs = (estimatedCarbs ?? 0) + (28 * quantity);
      } else if (lower.contains('vegetable') || lower.contains('tomato') || lower.contains('onion')) {
        estimatedCalories = (estimatedCalories ?? 0) + (20 * quantity);
        estimatedCarbs = (estimatedCarbs ?? 0) + (5 * quantity);
      } else if (lower.contains('cheese') || lower.contains('milk') || lower.contains('cream')) {
        estimatedCalories = (estimatedCalories ?? 0) + (100 * quantity);
        estimatedFat = (estimatedFat ?? 0) + (8 * quantity);
        estimatedProtein = (estimatedProtein ?? 0) + (6 * quantity);
      } else if (lower.contains('oil') || lower.contains('butter')) {
        estimatedCalories = (estimatedCalories ?? 0) + (120 * quantity);
        estimatedFat = (estimatedFat ?? 0) + (14 * quantity);
      }
    }

    if (estimatedCalories == null &&
        estimatedProtein == null &&
        estimatedCarbs == null &&
        estimatedFat == null) {
      return null;
    }

    final servings = _extractServings(recipe);
    return NutritionInfo(
      calories: estimatedCalories,
      protein: estimatedProtein,
      carbohydrates: estimatedCarbs,
      fat: estimatedFat,
      servings: servings,
    );
  }

  /// Get nutrition info for a recipe (tries metadata first, then estimation)
  static NutritionInfo? getNutritionInfo(Recipe recipe) {
    // Try to extract from metadata first
    final fromMetadata = extractFromMetadata(recipe);
    if (fromMetadata != null && fromMetadata.hasCompleteData) {
      return fromMetadata;
    }

    // Fall back to estimation
    return estimateFromIngredients(recipe);
  }

  /// Get nutrition info for a recipe entity
  static NutritionInfo? getNutritionInfoForEntity(RecipeEntity entity) {
    final recipe = entity.toRecipe();
    return getNutritionInfo(recipe);
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      // Try to extract number from string
      final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(value);
      if (match != null) {
        return double.tryParse(match.group(1)!);
      }
    }
    return null;
  }

  static NutritionInfo? _parseNutritionMap(
    Map<String, dynamic> nutrition,
    Recipe recipe,
  ) {
    final servings = _extractServings(recipe);
    return NutritionInfo(
      calories: _parseDouble(nutrition['calories']) ??
          _parseDouble(nutrition['@type'] == 'NutritionInformation'
              ? nutrition['calories']
              : null),
      protein: _parseDouble(nutrition['protein']),
      carbohydrates: _parseDouble(nutrition['carbohydrates']) ??
          _parseDouble(nutrition['carbohydrateContent']),
      fat: _parseDouble(nutrition['fat']) ?? _parseDouble(nutrition['fatContent']),
      fiber: _parseDouble(nutrition['fiber']) ?? _parseDouble(nutrition['fiberContent']),
      sugar: _parseDouble(nutrition['sugar']) ?? _parseDouble(nutrition['sugarContent']),
      sodium: _parseDouble(nutrition['sodium']) ?? _parseDouble(nutrition['sodiumContent']),
      servings: servings,
    );
  }

  static int? _extractServings(Recipe recipe) {
    final servingsText = recipe.servings;
    if (servingsText == null) return null;
    final match = RegExp(r'(\d+)').firstMatch(servingsText);
    return int.tryParse(match?.group(1) ?? '');
  }

  static double _extractQuantity(String ingredient) {
    final match = RegExp(r'^(\d+(?:\.\d+)?)\s*').firstMatch(ingredient);
    return double.tryParse(match?.group(1) ?? '') ?? 1.0;
  }
}

