/// Domain model for a shopping list item
///
/// This is the core shopping list item model used throughout the shopping list feature.
class ShoppingListItemModel {
  const ShoppingListItemModel({
    required this.id,
    required this.ingredient,
    this.note,
    this.recipeTitle,
    this.recipeUrl,
    required this.addedAt,
    this.isChecked = false,
  });

  final String id; // Unique identifier (key from Hive)
  final String ingredient;
  final String? note;
  final String? recipeTitle;
  final String? recipeUrl;
  final DateTime addedAt;
  final bool isChecked;

  ShoppingListItemModel copyWith({
    String? id,
    String? ingredient,
    String? note,
    String? recipeTitle,
    String? recipeUrl,
    DateTime? addedAt,
    bool? isChecked,
  }) {
    return ShoppingListItemModel(
      id: id ?? this.id,
      ingredient: ingredient ?? this.ingredient,
      note: note ?? this.note,
      recipeTitle: recipeTitle ?? this.recipeTitle,
      recipeUrl: recipeUrl ?? this.recipeUrl,
      addedAt: addedAt ?? this.addedAt,
      isChecked: isChecked ?? this.isChecked,
    );
  }
}

