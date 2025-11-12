import 'package:core/core.dart';

import 'default_ingredient_prices.dart';
import 'inventory_item.dart';
import 'recipe_entity.dart';

class IngredientCost {
  IngredientCost({
    required this.ingredient,
    required this.estimatedQuantity,
    this.unit,
    this.cost,
    this.inventoryItem,
  });

  final String ingredient;
  final double estimatedQuantity;
  final String? unit;
  final double? cost; // Cost for this ingredient
  final InventoryItem? inventoryItem; // Matched inventory item if available
}

class RecipeCostEstimate {
  RecipeCostEstimate({
    required this.recipe,
    required this.ingredientCosts,
    required this.totalCost,
    required this.servings,
    required this.costPerServing,
    required this.hasAllCosts,
    this.usesDefaultPrices = false,
  });

  final RecipeEntity recipe;
  final List<IngredientCost> ingredientCosts;
  final double? totalCost; // null if some costs are missing
  final int servings; // Estimated servings
  final double? costPerServing; // null if totalCost is null
  final bool hasAllCosts; // true if all ingredients have cost data
  final bool usesDefaultPrices; // true if any default prices were used
}

class MealPlanCostEstimate {
  MealPlanCostEstimate({
    required this.recipeCosts,
    required this.totalCost,
    required this.costPerDay,
    required this.hasAllCosts,
  });

  final List<RecipeCostEstimate> recipeCosts;
  final double? totalCost;
  final double? costPerDay;
  final bool hasAllCosts;
}

class CostEstimationService {
  /// Estimate cost for a single recipe
  /// 
  /// [useDefaultPrices] - If true, uses default ingredient prices when inventory items
  /// don't have cost data. Defaults to true.
  static RecipeCostEstimate estimateRecipeCost({
    required RecipeEntity recipe,
    required List<InventoryItem> inventoryItems,
    bool useDefaultPrices = true,
  }) {
    final recipeObj = recipe.toRecipe();
    final ingredientCosts = <IngredientCost>[];
    double? totalCost = 0.0;
    bool hasAllCosts = true;
    bool hasAnyCost = false;
    int defaultPriceCount = 0; // Track how many ingredients used default prices

    // Normalize inventory items by name for matching
    final inventoryMap = <String, InventoryItem>{};
    for (final item in inventoryItems) {
      final normalized = _normalizeIngredientName(item.name);
      inventoryMap[normalized] = item;
    }

    for (final ingredient in recipeObj.ingredients) {
      final normalized = _normalizeIngredientName(ingredient);
      final quantity = _extractQuantity(ingredient);
      final unit = _extractUnit(ingredient);
      
      InventoryItem? matchedItem;
      double? cost;

      // Try to find matching inventory item
      for (final entry in inventoryMap.entries) {
        if (_isIngredientMatch(normalized, entry.key)) {
          matchedItem = entry.value;
          final itemCostPerUnit = matchedItem.costPerUnit;
          if (itemCostPerUnit != null) {
            // Calculate cost based on quantity needed
            // For simplicity, assume 1 unit of recipe ingredient = 1 unit of inventory
            // This could be improved with better unit conversion
            cost = itemCostPerUnit * quantity;
            totalCost = totalCost! + cost;
            hasAnyCost = true;
          } else {
            hasAllCosts = false;
          }
          break;
        }
      }

      // If no inventory match found, try default prices (if enabled)
      if (matchedItem == null && cost == null) {
        if (useDefaultPrices) {
          final defaultPrice = DefaultIngredientPrices.getPrice(ingredient);
          if (defaultPrice != null) {
            cost = defaultPrice * quantity;
            totalCost = totalCost! + cost;
            hasAnyCost = true;
            defaultPriceCount++;
          } else {
            hasAllCosts = false;
          }
        } else {
          hasAllCosts = false;
        }
      } else if (matchedItem == null) {
        hasAllCosts = false;
      }

      ingredientCosts.add(IngredientCost(
        ingredient: ingredient,
        estimatedQuantity: quantity,
        unit: unit,
        cost: cost,
        inventoryItem: matchedItem,
      ));
    }
    
    // If no costs were found at all, set totalCost to null
    if (!hasAnyCost) {
      totalCost = null;
    }

    // Estimate servings (default to 4 if not specified)
    final servings = _estimateServings(recipeObj);

    return RecipeCostEstimate(
      recipe: recipe,
      ingredientCosts: ingredientCosts,
      totalCost: totalCost,
      servings: servings,
      costPerServing: totalCost != null ? totalCost / servings : null,
      hasAllCosts: hasAllCosts,
      usesDefaultPrices: defaultPriceCount > 0,
    );
  }

  /// Estimate cost for a meal plan day
  /// 
  /// [useDefaultPrices] - If true, uses default ingredient prices when inventory items
  /// don't have cost data. Defaults to true.
  static MealPlanCostEstimate estimateMealPlanCost({
    required List<RecipeEntity> recipes,
    required List<InventoryItem> inventoryItems,
    bool useDefaultPrices = true,
  }) {
    final recipeCosts = recipes
        .map((recipe) => estimateRecipeCost(
              recipe: recipe,
              inventoryItems: inventoryItems,
              useDefaultPrices: useDefaultPrices,
            ))
        .toList();

    double? totalCost = 0.0;
    bool hasAllCosts = true;

    for (final recipeCost in recipeCosts) {
      if (recipeCost.totalCost != null) {
        totalCost = (totalCost ?? 0.0) + recipeCost.totalCost!;
      } else {
        hasAllCosts = false;
        totalCost = null;
      }
    }

    return MealPlanCostEstimate(
      recipeCosts: recipeCosts,
      totalCost: totalCost,
      costPerDay: totalCost,
      hasAllCosts: hasAllCosts,
    );
  }

  /// Estimate cost for a week
  static double? estimateWeeklyCost({
    required List<MealPlanCostEstimate> dailyCosts,
  }) {
    double? total = 0.0;
    for (final dailyCost in dailyCosts) {
      if (dailyCost.totalCost != null) {
        total = (total ?? 0.0) + dailyCost.totalCost!;
      } else {
        return null; // Can't calculate if any day is missing costs
      }
    }
    return total;
  }

  static String _normalizeIngredientName(String ingredient) {
    // Remove quantities and units, similar to InventoryRecipeMatcher
    String normalized = ingredient.toLowerCase().trim();
    normalized = normalized.replaceAll(
      RegExp(r'^\d+(?:\.\d+)?\s*(?:/\s*\d+)?\s*(?:cup|tbsp|tsp|oz|lb|g|kg|ml|l|pcs?|pieces?|cloves?|slices?|stalks?|bunches?|heads?|leaves?)\s+',
          caseSensitive: false),
      '',
    );
    normalized = normalized.replaceAll(
      RegExp(r'^(fresh|dried|frozen|canned|chopped|diced|sliced|minced|grated|shredded|whole|large|small|medium)\s+',
          caseSensitive: false),
      '',
    );
    normalized = normalized.replaceAll(RegExp(r'\s*\([^)]*\)\s*$'), '');
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ').trim();
    return normalized;
  }

  static double _extractQuantity(String ingredient) {
    // Try to extract quantity from ingredient string
    final match = RegExp(r'^(\d+(?:\.\d+)?)\s*(?:/\s*(\d+))?').firstMatch(ingredient);
    if (match != null) {
      final whole = double.tryParse(match.group(1) ?? '1') ?? 1.0;
      final fraction = match.group(2);
      if (fraction != null) {
        final denom = double.tryParse(fraction) ?? 1.0;
        return whole / denom;
      }
      return whole;
    }
    return 1.0; // Default to 1 if no quantity found
  }

  static String? _extractUnit(String ingredient) {
    final match = RegExp(
      r'(?:cup|tbsp|tsp|oz|lb|g|kg|ml|l|pcs?|pieces?|cloves?|slices?|stalks?|bunches?|heads?|leaves?)',
      caseSensitive: false,
    ).firstMatch(ingredient);
    return match?.group(0);
  }

  static bool _isIngredientMatch(String ingredient1, String ingredient2) {
    // Use similar matching logic as InventoryRecipeMatcher
    if (ingredient1 == ingredient2) return true;
    
    final words1 = ingredient1.split(RegExp(r'\s+'));
    final words2 = ingredient2.split(RegExp(r'\s+'));

    if (words1.length == 1 && words2.length > 1) {
      return words2.contains(words1.first);
    }
    if (words2.length == 1 && words1.length > 1) {
      return words1.contains(words2.first);
    }

    if (words1.length <= words2.length) {
      return words1.every((word) => words2.contains(word));
    } else {
      return words2.every((word) => words1.contains(word));
    }
  }

  static int _estimateServings(Recipe recipe) {
    // Try to extract servings from recipe
    if (recipe.servings != null) {
      final match = RegExp(r'(\d+)').firstMatch(recipe.servings!);
      if (match != null) {
        return int.tryParse(match.group(1) ?? '4') ?? 4;
      }
    }
    if (recipe.yield != null) {
      final match = RegExp(r'(\d+)').firstMatch(recipe.yield!);
      if (match != null) {
        return int.tryParse(match.group(1) ?? '4') ?? 4;
      }
    }
    return 4; // Default to 4 servings
  }
}

