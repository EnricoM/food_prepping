import 'dart:async';

import 'package:data/data.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/models/shopping_list_item_model.dart';

/// Data source for shopping list items
///
/// This adapts the existing ShoppingListStore to work with the new ShoppingListItemModel.
class ShoppingListDataSource {
  ShoppingListDataSource({ShoppingListStore? store})
      : _store = store ?? ShoppingListStore.instance;

  final ShoppingListStore _store;

  ValueListenable<Box<ShoppingListItem>> get listenable => _store.listenable();

  /// Convert ShoppingListItem to ShoppingListItemModel
  ShoppingListItemModel toModel(ShoppingListItem item) {
    return ShoppingListItemModel(
      id: item.key.toString(),
      ingredient: item.ingredient,
      note: item.note,
      recipeTitle: item.recipeTitle,
      recipeUrl: item.recipeUrl,
      addedAt: item.addedAt,
      isChecked: item.isChecked,
    );
  }

  /// Convert ShoppingListItemModel to ShoppingListItem
  ShoppingListItem toEntity(ShoppingListItemModel model) {
    return ShoppingListItem(
      ingredient: model.ingredient,
      note: model.note,
      recipeTitle: model.recipeTitle,
      recipeUrl: model.recipeUrl,
      addedAt: model.addedAt,
      isChecked: model.isChecked,
    );
  }

  List<ShoppingListItemModel> getAll() {
    return _store.allItems().map(toModel).toList();
  }

  Future<void> addItems(List<ShoppingListItemModel> models) async {
    final entities = models.map(toEntity).toList();
    await _store.addItems(entities);
  }

  Future<void> updateChecked(ShoppingListItemModel model, bool checked) async {
    // Find the entity by ID
    final allItems = _store.allItems();
    final entity = allItems.firstWhere(
      (item) => item.key.toString() == model.id,
      orElse: () => throw StateError('Item not found: ${model.id}'),
    );
    await _store.updateChecked(entity, checked);
  }

  Future<void> remove(ShoppingListItemModel model) async {
    // Find the entity by ID
    final allItems = _store.allItems();
    final entity = allItems.firstWhere(
      (item) => item.key.toString() == model.id,
      orElse: () => throw StateError('Item not found: ${model.id}'),
    );
    await _store.remove(entity);
  }

  Future<void> clearCompleted() async {
    await _store.clearCompleted();
  }

  Future<void> clearAll() async {
    await _store.clearAll();
  }
}

