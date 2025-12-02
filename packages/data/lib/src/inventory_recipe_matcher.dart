import 'inventory_item.dart';
import 'recipe_entity.dart';

class RecipeMatchResult {
  RecipeMatchResult({
    required this.recipe,
    required this.availableIngredients,
    required this.missingIngredients,
    required this.matchPercentage,
  });

  final RecipeEntity recipe;
  final List<String> availableIngredients;
  final List<String> missingIngredients;
  final double matchPercentage; // 0.0 to 1.0

  bool get canMake => missingIngredients.isEmpty;
  int get availableCount => availableIngredients.length;
  int get totalCount => availableIngredients.length + missingIngredients.length;
}

class InventoryRecipeMatcher {
  /// Match recipes against inventory items
  static List<RecipeMatchResult> matchRecipes({
    required List<RecipeEntity> recipes,
    required List<InventoryItem> inventoryItems,
  }) {
    // Normalize inventory item names for matching
    final inventoryNames = inventoryItems
        .map((item) => _normalizeIngredient(item.name))
        .toSet();

    final results = <RecipeMatchResult>[];

    for (final recipe in recipes) {
      final recipeIngredients = recipe.ingredients;
      final available = <String>[];
      final missing = <String>[];

      for (final ingredient in recipeIngredients) {
        final normalized = _normalizeIngredient(ingredient.displayString);
        if (_isAvailable(normalized, inventoryNames)) {
          available.add(ingredient.displayString);
        } else {
          missing.add(ingredient.displayString);
        }
      }

      final matchPercentage = recipeIngredients.isEmpty
          ? 0.0
          : available.length / recipeIngredients.length;

      results.add(RecipeMatchResult(
        recipe: recipe,
        availableIngredients: available,
        missingIngredients: missing,
        matchPercentage: matchPercentage,
      ));
    }

    // Sort by: can make first, then by match percentage (descending)
    results.sort((a, b) {
      if (a.canMake && !b.canMake) return -1;
      if (!a.canMake && b.canMake) return 1;
      return b.matchPercentage.compareTo(a.matchPercentage);
    });

    return results;
  }

  /// Normalize ingredient name for matching
  static String _normalizeIngredient(String ingredient) {
    // Remove quantities, units, and common prefixes
    String normalized = ingredient.toLowerCase().trim();
    
    // Remove common quantity patterns (e.g., "2 cups", "1/2 tsp", "250g")
    normalized = normalized.replaceAll(
      RegExp(r'^\d+(?:\.\d+)?\s*(?:/\s*\d+)?\s*(?:cup|tbsp|tsp|oz|lb|g|kg|ml|l|pcs?|pieces?|cloves?|slices?|stalks?|bunches?|heads?|leaves?)\s+', caseSensitive: false),
      '',
    );
    
    // Remove common prefixes
    normalized = normalized.replaceAll(RegExp(r'^(fresh|dried|frozen|canned|chopped|diced|sliced|minced|grated|shredded|whole|large|small|medium)\s+', caseSensitive: false), '');
    
    // Remove common suffixes in parentheses
    normalized = normalized.replaceAll(RegExp(r'\s*\([^)]*\)\s*$'), '');
    
    // Remove extra whitespace
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    // Remove common words that don't help matching
    final stopWords = ['and', 'or', 'plus', 'optional', 'to taste'];
    for (final word in stopWords) {
      normalized = normalized.replaceAll(RegExp('\\b$word\\b', caseSensitive: false), '');
    }
    
    return normalized.trim();
  }

  /// Check if an ingredient is available in inventory
  static bool _isAvailable(String normalizedIngredient, Set<String> inventoryNames) {
    if (inventoryNames.contains(normalizedIngredient)) {
      return true;
    }

    // Try partial matching (e.g., "tomato" matches "tomatoes", "chicken breast" matches "chicken")
    for (final inventoryName in inventoryNames) {
      if (_isPartialMatch(normalizedIngredient, inventoryName) ||
          _isPartialMatch(inventoryName, normalizedIngredient)) {
        return true;
      }
    }

    return false;
  }

  /// Check if one ingredient name partially matches another
  static bool _isPartialMatch(String ingredient1, String ingredient2) {
    final words1 = ingredient1.split(RegExp(r'\s+'));
    final words2 = ingredient2.split(RegExp(r'\s+'));

    // If one is a single word and it's contained in the other
    if (words1.length == 1 && words2.length > 1) {
      return words2.contains(words1.first);
    }
    if (words2.length == 1 && words1.length > 1) {
      return words1.contains(words2.first);
    }

    // Check if all words from the shorter one are in the longer one
    if (words1.length <= words2.length) {
      return words1.every((word) => words2.contains(word));
    } else {
      return words2.every((word) => words1.contains(word));
    }
  }
}

