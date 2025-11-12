import 'shopping_list_entity.dart';

/// Categories for organizing shopping list items by store section
enum ShoppingCategory {
  produce,
  meat,
  seafood,
  dairy,
  deli,
  bakery,
  frozen,
  pantry,
  beverages,
  snacks,
  health,
  household,
  other,
}

/// Service for organizing and categorizing shopping list items
class ShoppingListOrganizer {
  /// Automatically categorize an ingredient based on its name
  static ShoppingCategory categorizeIngredient(String ingredient) {
    final lower = ingredient.toLowerCase();

    // Produce
    if (_matchesKeywords(lower, [
      'apple', 'banana', 'orange', 'lemon', 'lime', 'grape', 'berry',
      'tomato', 'onion', 'garlic', 'potato', 'carrot', 'lettuce', 'spinach',
      'broccoli', 'pepper', 'cucumber', 'zucchini', 'mushroom', 'celery',
      'corn', 'avocado', 'herb', 'basil', 'parsley', 'cilantro', 'ginger',
      'fruit', 'vegetable', 'greens', 'salad',
    ])) {
      return ShoppingCategory.produce;
    }

    // Meat
    if (_matchesKeywords(lower, [
      'chicken', 'beef', 'pork', 'lamb', 'turkey', 'ground', 'steak',
      'sausage', 'bacon', 'ham', 'rib', 'chop', 'cutlet',
    ])) {
      return ShoppingCategory.meat;
    }

    // Seafood
    if (_matchesKeywords(lower, [
      'fish', 'salmon', 'tuna', 'shrimp', 'crab', 'lobster', 'oyster',
      'mussel', 'clam', 'seafood', 'sushi',
    ])) {
      return ShoppingCategory.seafood;
    }

    // Dairy
    if (_matchesKeywords(lower, [
      'milk', 'cheese', 'butter', 'yogurt', 'cream', 'sour cream',
      'cottage cheese', 'cream cheese', 'mozzarella', 'cheddar',
    ])) {
      return ShoppingCategory.dairy;
    }

    // Deli
    if (_matchesKeywords(lower, [
      'deli', 'salami', 'prosciutto', 'cold cut', 'lunch meat',
    ])) {
      return ShoppingCategory.deli;
    }

    // Bakery
    if (_matchesKeywords(lower, [
      'bread', 'bagel', 'muffin', 'croissant', 'roll', 'bun', 'pita',
      'tortilla', 'wrap', 'pastry', 'cake', 'cookie',
    ])) {
      return ShoppingCategory.bakery;
    }

    // Frozen
    if (_matchesKeywords(lower, [
      'frozen', 'ice cream', 'frozen vegetable', 'frozen fruit',
    ])) {
      return ShoppingCategory.frozen;
    }

    // Pantry
    if (_matchesKeywords(lower, [
      'rice', 'pasta', 'noodle', 'flour', 'sugar', 'salt', 'pepper',
      'oil', 'vinegar', 'sauce', 'spice', 'herb', 'seasoning',
      'canned', 'bean', 'chickpea', 'lentil', 'quinoa', 'oats',
      'cereal', 'cracker', 'chip', 'nut', 'seed',
    ])) {
      return ShoppingCategory.pantry;
    }

    // Beverages
    if (_matchesKeywords(lower, [
      'juice', 'soda', 'water', 'coffee', 'tea', 'beer', 'wine',
      'drink', 'beverage',
    ])) {
      return ShoppingCategory.beverages;
    }

    // Snacks
    if (_matchesKeywords(lower, [
      'snack', 'chip', 'cracker', 'pretzel', 'popcorn', 'candy',
    ])) {
      return ShoppingCategory.snacks;
    }

    // Health & Personal Care
    if (_matchesKeywords(lower, [
      'vitamin', 'supplement', 'medicine', 'shampoo', 'soap', 'toothpaste',
    ])) {
      return ShoppingCategory.health;
    }

    // Household
    if (_matchesKeywords(lower, [
      'paper', 'towel', 'tissue', 'cleaning', 'detergent', 'trash bag',
      'battery', 'light bulb',
    ])) {
      return ShoppingCategory.household;
    }

    return ShoppingCategory.other;
  }

  static bool _matchesKeywords(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword));
  }

  /// Get display name for a category
  static String getCategoryName(ShoppingCategory category) {
    switch (category) {
      case ShoppingCategory.produce:
        return 'Produce';
      case ShoppingCategory.meat:
        return 'Meat';
      case ShoppingCategory.seafood:
        return 'Seafood';
      case ShoppingCategory.dairy:
        return 'Dairy';
      case ShoppingCategory.deli:
        return 'Deli';
      case ShoppingCategory.bakery:
        return 'Bakery';
      case ShoppingCategory.frozen:
        return 'Frozen';
      case ShoppingCategory.pantry:
        return 'Pantry';
      case ShoppingCategory.beverages:
        return 'Beverages';
      case ShoppingCategory.snacks:
        return 'Snacks';
      case ShoppingCategory.health:
        return 'Health & Personal Care';
      case ShoppingCategory.household:
        return 'Household';
      case ShoppingCategory.other:
        return 'Other';
    }
  }

  /// Get icon for a category
  static String getCategoryIcon(ShoppingCategory category) {
    switch (category) {
      case ShoppingCategory.produce:
        return '🥬';
      case ShoppingCategory.meat:
        return '🥩';
      case ShoppingCategory.seafood:
        return '🐟';
      case ShoppingCategory.dairy:
        return '🥛';
      case ShoppingCategory.deli:
        return '🥓';
      case ShoppingCategory.bakery:
        return '🍞';
      case ShoppingCategory.frozen:
        return '🧊';
      case ShoppingCategory.pantry:
        return '🥫';
      case ShoppingCategory.beverages:
        return '🥤';
      case ShoppingCategory.snacks:
        return '🍿';
      case ShoppingCategory.health:
        return '💊';
      case ShoppingCategory.household:
        return '🧹';
      case ShoppingCategory.other:
        return '📦';
    }
  }

  /// Get typical store order for categories (for store layout optimization)
  static int getCategoryOrder(ShoppingCategory category) {
    switch (category) {
      case ShoppingCategory.produce:
        return 1;
      case ShoppingCategory.meat:
        return 2;
      case ShoppingCategory.seafood:
        return 3;
      case ShoppingCategory.dairy:
        return 4;
      case ShoppingCategory.deli:
        return 5;
      case ShoppingCategory.bakery:
        return 6;
      case ShoppingCategory.frozen:
        return 7;
      case ShoppingCategory.pantry:
        return 8;
      case ShoppingCategory.beverages:
        return 9;
      case ShoppingCategory.snacks:
        return 10;
      case ShoppingCategory.health:
        return 11;
      case ShoppingCategory.household:
        return 12;
      case ShoppingCategory.other:
        return 13;
    }
  }

  /// Group items by category
  static Map<ShoppingCategory, List<ShoppingListItem>> groupByCategory(
    List<ShoppingListItem> items,
  ) {
    final grouped = <ShoppingCategory, List<ShoppingListItem>>{};
    for (final item in items) {
      final category = categorizeIngredient(item.ingredient);
      grouped.putIfAbsent(category, () => []).add(item);
    }
    return grouped;
  }

  /// Group items by recipe
  static Map<String, List<ShoppingListItem>> groupByRecipe(
    List<ShoppingListItem> items,
  ) {
    final grouped = <String, List<ShoppingListItem>>{};
    for (final item in items) {
      final key = item.recipeTitle ?? 'Other items';
      grouped.putIfAbsent(key, () => []).add(item);
    }
    return grouped;
  }

  /// Merge duplicate items (same ingredient name, case-insensitive)
  static List<ShoppingListItem> mergeDuplicates(
    List<ShoppingListItem> items,
  ) {
    final merged = <String, ShoppingListItem>{};
    for (final item in items) {
      final key = item.ingredient.toLowerCase().trim();
      if (merged.containsKey(key)) {
        // Merge: combine notes and recipe titles
        final existing = merged[key]!;
        final notes = [
          if (existing.note != null && existing.note!.isNotEmpty)
            existing.note!,
          if (item.note != null && item.note!.isNotEmpty) item.note!,
        ];
        final recipes = [
          if (existing.recipeTitle != null && existing.recipeTitle!.isNotEmpty)
            existing.recipeTitle!,
          if (item.recipeTitle != null && item.recipeTitle!.isNotEmpty)
            item.recipeTitle!,
        ];
        merged[key] = existing.copyWith(
          note: notes.join('; '),
          recipeTitle: recipes.join(', '),
        );
      } else {
        merged[key] = item;
      }
    }
    return merged.values.toList();
  }

  /// Sort items by category order (store layout)
  static List<ShoppingListItem> sortByStoreLayout(
    List<ShoppingListItem> items,
  ) {
    final sorted = List<ShoppingListItem>.from(items);
    sorted.sort((a, b) {
      final categoryA = categorizeIngredient(a.ingredient);
      final categoryB = categorizeIngredient(b.ingredient);
      final orderA = getCategoryOrder(categoryA);
      final orderB = getCategoryOrder(categoryB);
      if (orderA != orderB) {
        return orderA.compareTo(orderB);
      }
      // Within same category, sort alphabetically
      return a.ingredient.toLowerCase().compareTo(b.ingredient.toLowerCase());
    });
    return sorted;
  }

  /// Sort items alphabetically
  static List<ShoppingListItem> sortAlphabetically(
    List<ShoppingListItem> items,
  ) {
    final sorted = List<ShoppingListItem>.from(items);
    sorted.sort((a, b) =>
        a.ingredient.toLowerCase().compareTo(b.ingredient.toLowerCase()));
    return sorted;
  }
}

