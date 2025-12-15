import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'recipe_entity.dart';
import 'shopping_list_entity.dart';

class ShoppingListStore {
  ShoppingListStore._();

  static const _boxName = 'shoppingList';
  static ShoppingListStore? _instance;

  static ShoppingListStore get instance {
    final instance = _instance;
    if (instance == null) {
      throw StateError('ShoppingListStore has not been initialized.');
    }
    return instance;
  }

  static Future<void> init() async {
    if (!Hive.isAdapterRegistered(ShoppingListItemAdapter().typeId)) {
      Hive.registerAdapter(ShoppingListItemAdapter());
    }
    await Hive.openBox<ShoppingListItem>(_boxName);
    _instance = ShoppingListStore._();
  }

  Box<ShoppingListItem> get _box => Hive.box<ShoppingListItem>(_boxName);

  ValueListenable<Box<ShoppingListItem>> listenable() => _box.listenable();

  List<ShoppingListItem> allItems() => _box.values.toList(growable: false);

  Future<void> addItems(List<ShoppingListItem> items) async {
    if (items.isEmpty) {
      return;
    }
    final existing = _box.values.toList(growable: false);
    final normalizedExisting = existing
        .map((item) => item.ingredient.trim().toLowerCase())
        .toSet();
    final entries = <ShoppingListItem>[];
    for (final item in items) {
      final normalized = item.ingredient.trim().toLowerCase();
      if (normalized.isEmpty) {
        continue;
      }
      if (normalizedExisting.contains(normalized)) {
        continue;
      }
      normalizedExisting.add(normalized);
      entries.add(item);
    }
    if (entries.isEmpty) {
      return;
    }
    await _box.addAll(entries);
  }

  Future<void> addIngredientsFromRecipe(Recipe recipe) {
    return addItems(
      recipe.ingredientStrings
          .map(
            (ingredient) => ShoppingListItem(
              ingredient: ingredient.trim(),
              recipeTitle: recipe.title,
              recipeUrl: recipe.sourceUrl,
            ),
          )
          .toList(growable: false),
    );
  }

  Future<void> addIngredientsFromEntities(Iterable<RecipeEntity> entities) {
    final recipes = entities.map((entity) => entity.toRecipe());
    return addIngredientsFromRecipes(recipes);
  }

  Future<void> addIngredientsFromRecipes(Iterable<Recipe> recipes) async {
    final items = <ShoppingListItem>[];
    for (final recipe in recipes) {
      items.addAll(
        recipe.ingredientStrings
            .map(
              (ingredient) => ShoppingListItem(
                ingredient: ingredient.trim(),
                recipeTitle: recipe.title,
                recipeUrl: recipe.sourceUrl,
              ),
            )
            .toList(growable: false),
      );
    }
    await addItems(items);
  }

  Future<void> toggleChecked(ShoppingListItem item) async {
    await _box.put(
      item.key,
      item.copyWith(isChecked: !item.isChecked),
    );
  }

  Future<void> updateChecked(ShoppingListItem item, bool isChecked) async {
    await _box.put(item.key, item.copyWith(isChecked: isChecked));
  }

  Future<void> remove(ShoppingListItem item) async {
    await _box.delete(item.key);
  }

  Future<void> clearCompleted() async {
    final completedKeys = _box.values
        .where((item) => item.isChecked)
        .map((item) => item.key)
        .toList(growable: false);
    await _box.deleteAll(completedKeys);
  }

  Future<void> clearAll() => _box.clear();
}
