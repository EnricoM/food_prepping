/// Default prices for common ingredients (per unit)
/// Prices are in USD and represent average market prices
/// These can be used as fallback estimates when inventory items don't have cost data
class DefaultIngredientPrices {
  static const Map<String, double> _defaultPrices = {
    // Proteins
    'chicken': 4.99,
    'chicken breast': 5.99,
    'chicken thigh': 3.99,
    'ground beef': 5.49,
    'beef': 8.99,
    'pork': 4.99,
    'salmon': 9.99,
    'fish': 7.99,
    'shrimp': 8.99,
    'eggs': 3.99,
    'tofu': 2.99,
    
    // Vegetables
    'tomato': 2.99,
    'tomatoes': 2.99,
    'onion': 1.49,
    'onions': 1.49,
    'garlic': 1.99,
    'potato': 1.99,
    'potatoes': 1.99,
    'carrot': 1.49,
    'carrots': 1.49,
    'bell pepper': 2.49,
    'bell peppers': 2.49,
    'black pepper': 2.99,
    'broccoli': 2.99,
    'spinach': 2.49,
    'lettuce': 1.99,
    'cucumber': 1.49,
    'zucchini': 2.49,
    'mushroom': 3.99,
    'mushrooms': 3.99,
    'celery': 1.99,
    'corn kernels': 1.99,
    
    // Fruits
    'apple': 1.99,
    'apples': 1.99,
    'banana': 1.49,
    'bananas': 1.49,
    'orange': 1.99,
    'oranges': 1.99,
    'lemon': 1.49,
    'lemons': 1.49,
    'lime': 1.49,
    'limes': 1.49,
    'avocado': 1.99,
    'avocados': 1.99,
    
    // Grains & Starches
    'rice': 2.99,
    'pasta': 1.99,
    'bread': 2.99,
    'flour': 2.49,
    'quinoa': 4.99,
    'oats': 2.99,
    
    // Dairy
    'milk': 3.49,
    'cheese': 4.99,
    'butter': 4.99,
    'yogurt': 3.99,
    'cream': 3.99,
    'sour cream': 2.99,
    
    // Pantry staples
    'olive oil': 7.99,
    'vegetable oil': 3.99,
    'salt': 0.99,
    'sugar': 2.49,
    'honey': 5.99,
    'vinegar': 2.99,
    'soy sauce': 2.99,
    'chicken broth': 2.99,
    'beef broth': 2.99,
    'vegetable broth': 2.99,
    
    // Herbs & Spices
    'basil': 2.99,
    'oregano': 2.99,
    'thyme': 2.99,
    'rosemary': 2.99,
    'parsley': 1.99,
    'cilantro': 1.99,
    'ginger': 2.99,
    'turmeric': 3.99,
    'cumin': 2.99,
    'paprika': 2.99,
    'cinnamon': 3.99,
    
    // Canned goods
    'tomato sauce': 1.99,
    'tomato paste': 1.49,
    'beans': 1.49,
    'chickpeas': 1.99,
    'canned corn': 1.49,
    
    // Nuts & Seeds
    'almonds': 8.99,
    'walnuts': 7.99,
    'peanuts': 4.99,
  };

  /// Get estimated price for an ingredient name
  /// Returns null if no default price is available
  static double? getPrice(String ingredientName) {
    final normalized = _normalize(ingredientName);
    
    // Try exact match first
    if (_defaultPrices.containsKey(normalized)) {
      return _defaultPrices[normalized];
    }
    
    // Try partial match (e.g., "chicken breast" matches "chicken")
    for (final entry in _defaultPrices.entries) {
      if (normalized.contains(entry.key) || entry.key.contains(normalized)) {
        return entry.value;
      }
    }
    
    return null;
  }

  /// Get all available default prices
  static Map<String, double> getAllPrices() => Map.unmodifiable(_defaultPrices);

  /// Normalize ingredient name for matching
  static String _normalize(String name) {
    return name
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Suggest price for an ingredient based on similar items
  static double? suggestPrice(String ingredientName) {
    final normalized = _normalize(ingredientName);
    
    // Try to find similar ingredients
    for (final entry in _defaultPrices.entries) {
      if (_isSimilar(normalized, entry.key)) {
        return entry.value;
      }
    }
    
    return null;
  }

  /// Check if two ingredient names are similar
  static bool _isSimilar(String name1, String name2) {
    final words1 = name1.split(' ');
    final words2 = name2.split(' ');
    
    // If they share a significant word, consider them similar
    for (final word1 in words1) {
      if (word1.length > 3 && words2.contains(word1)) {
        return true;
      }
    }
    
    return false;
  }
}

