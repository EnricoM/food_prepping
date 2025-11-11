import 'dart:async';

import 'package:core/core.dart';

import '../recipe_entity.dart';
import '../shopping_list_entity.dart';
import '../shopping_list_store.dart';

abstract class ShoppingListRepository {
  Stream<List<ShoppingListItem>> watchAll();
  Future<void> addItems(List<ShoppingListItem> items);
  Future<void> addIngredientsFromRecipe(Recipe recipe);
  Future<void> addIngredientsFromEntities(Iterable<RecipeEntity> entities);
  Future<void> updateChecked(ShoppingListItem item, bool checked);
  Future<void> remove(ShoppingListItem item);
  Future<void> clearCompleted();
  Future<void> clearAll();
}

class HiveShoppingListRepository implements ShoppingListRepository {
  HiveShoppingListRepository({ShoppingListStore? store})
      : _store = store ?? ShoppingListStore.instance;

  final ShoppingListStore _store;

  @override
  Stream<List<ShoppingListItem>> watchAll() {
    final listenable = _store.listenable();
    return Stream<List<ShoppingListItem>>.multi((controller) {
      void emit() => controller.add(_store.allItems());
      emit();
      void listener() => emit();
      listenable.addListener(listener);
      controller.onCancel = () {
        listenable.removeListener(listener);
      };
    });
  }

  @override
  Future<void> addItems(List<ShoppingListItem> items) =>
      _store.addItems(items);

  @override
  Future<void> addIngredientsFromRecipe(Recipe recipe) =>
      _store.addIngredientsFromRecipe(recipe);

  @override
  Future<void> addIngredientsFromEntities(Iterable<RecipeEntity> entities) =>
      _store.addIngredientsFromEntities(entities);

  @override
  Future<void> updateChecked(ShoppingListItem item, bool checked) =>
      _store.updateChecked(item, checked);

  @override
  Future<void> remove(ShoppingListItem item) => _store.remove(item);

  @override
  Future<void> clearCompleted() => _store.clearCompleted();

  @override
  Future<void> clearAll() => _store.clearAll();
}

