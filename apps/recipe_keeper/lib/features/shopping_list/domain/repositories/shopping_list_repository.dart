import 'dart:async';

import '../models/shopping_list_item_model.dart';

/// Repository interface for shopping list data operations
///
/// This defines the contract for shopping list data access.
/// Implementations will be in the data layer.
abstract class ShoppingListRepository {
  /// Stream of all shopping list items
  Stream<List<ShoppingListItemModel>> watchAll();

  /// Get all items synchronously
  List<ShoppingListItemModel> getAll();

  /// Add items to the shopping list
  Future<void> addItems(List<ShoppingListItemModel> items);

  /// Update checked status of an item
  Future<void> updateChecked(ShoppingListItemModel item, bool checked);

  /// Remove an item
  Future<void> remove(ShoppingListItemModel item);

  /// Clear all checked items
  Future<void> clearCompleted();

  /// Clear all items
  Future<void> clearAll();
}

