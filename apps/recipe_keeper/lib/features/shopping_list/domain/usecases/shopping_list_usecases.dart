import '../models/shopping_list_item_model.dart';

/// Use cases for shopping list operations
///
/// These define the business logic for shopping list operations.

/// Merge duplicate items in the shopping list
class MergeDuplicatesUseCase {
  const MergeDuplicatesUseCase();

  List<ShoppingListItemModel> call(List<ShoppingListItemModel> items) {
    final merged = <String, ShoppingListItemModel>{};
    
    for (final item in items) {
      final normalized = item.ingredient.trim().toLowerCase();
      final existing = merged[normalized];
      
      if (existing == null) {
        merged[normalized] = item;
      } else {
        // Merge notes if both have them
        final mergedNote = existing.note != null && item.note != null
            ? '${existing.note} • ${item.note}'
            : existing.note ?? item.note;
        
        merged[normalized] = existing.copyWith(
          note: mergedNote,
          recipeTitle: existing.recipeTitle ?? item.recipeTitle,
          recipeUrl: existing.recipeUrl ?? item.recipeUrl,
        );
      }
    }
    
    return merged.values.toList();
  }
}

/// Sort items alphabetically
class SortAlphabeticallyUseCase {
  const SortAlphabeticallyUseCase();

  List<ShoppingListItemModel> call(List<ShoppingListItemModel> items) {
    return List<ShoppingListItemModel>.from(items)
      ..sort((a, b) => a.ingredient.toLowerCase().compareTo(b.ingredient.toLowerCase()));
  }
}

/// Sort items by store layout
class SortByStoreLayoutUseCase {
  const SortByStoreLayoutUseCase();

  List<ShoppingListItemModel> call(List<ShoppingListItemModel> items) {
    // This would use ShoppingListOrganizer logic
    // For now, return items as-is (will be implemented in data layer)
    return List<ShoppingListItemModel>.from(items);
  }
}

