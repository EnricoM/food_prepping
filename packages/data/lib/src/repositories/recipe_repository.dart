import 'dart:async';

import 'package:core/core.dart';

import '../recipe_entity.dart';
import '../recipe_store.dart';

abstract class RecipeRepository {
  Stream<List<RecipeEntity>> watchAll();
  Stream<List<RecipeEntity>> watchFavorites();
  Future<void> saveParsedRecipe({
    required RecipeParseResult result,
    required String url,
  });
  Future<String> saveManualRecipe({
    required Recipe recipe,
    List<String> categories,
    bool isFavorite,
  });
  Future<RecipeParseResult?> getRecipe(String url);
  RecipeEntity? entityFor(String url);
  List<RecipeEntity> getAll();
  Set<String> allCategories();
  Future<void> toggleFavorite(String url);
  Future<void> delete(String url);
  Future<void> clear();
}

class HiveRecipeRepository implements RecipeRepository {
  HiveRecipeRepository({RecipeStore? store})
      : _store = store ?? RecipeStore.instance;

  final RecipeStore _store;

  @override
  Stream<List<RecipeEntity>> watchAll() => _watch(_store.allEntities);

  @override
  Stream<List<RecipeEntity>> watchFavorites() =>
      _watch(_store.favoriteEntities);

  Stream<List<RecipeEntity>> _watch(
    List<RecipeEntity> Function() read,
  ) {
    final listenable = _store.listenable();
    return Stream<List<RecipeEntity>>.multi((controller) {
      void emit() => controller.add(read());
      emit();
      void listener() => emit();
      listenable.addListener(listener);
      controller.onCancel = () {
        listenable.removeListener(listener);
      };
    });
  }

  @override
  Future<void> saveParsedRecipe({
    required RecipeParseResult result,
    required String url,
  }) {
    return _store.saveRecipe(result: result, url: url);
  }

  @override
  Future<String> saveManualRecipe({
    required Recipe recipe,
    List<String> categories = const [],
    bool isFavorite = false,
  }) {
    return _store.saveManualRecipe(
      recipe: recipe,
      categories: categories,
      isFavorite: isFavorite,
    );
  }

  @override
  Future<RecipeParseResult?> getRecipe(String url) async {
    return _store.getRecipe(url);
  }

  @override
  RecipeEntity? entityFor(String url) => _store.entityFor(url);

  @override
  List<RecipeEntity> getAll() => _store.allEntities();

  @override
  Set<String> allCategories() => _store.allCategories();

  @override
  Future<void> toggleFavorite(String url) => _store.toggleFavorite(url);

  @override
  Future<void> delete(String url) => _store.delete(url);

  @override
  Future<void> clear() => _store.clear();
}

