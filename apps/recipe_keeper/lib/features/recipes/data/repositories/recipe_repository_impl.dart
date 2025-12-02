import 'dart:async';

import 'package:core/core.dart';
import 'package:data/data.dart' hide RecipeRepository;

import '../../domain/models/recipe_model.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../datasources/recipe_datasource.dart';

/// Implementation of RecipeRepository
/// 
/// This bridges the old RecipeStore with the new RecipeModel-based architecture.
class RecipeRepositoryImpl implements RecipeRepository {
  RecipeRepositoryImpl(this._dataSource);

  final RecipeDataSource _dataSource;

  @override
  Stream<List<RecipeModel>> watchAll() {
    final listenable = _dataSource.listenable;
    return Stream<List<RecipeModel>>.multi((controller) {
      void emit() {
        final entities = listenable.value.values.cast<RecipeEntity>();
        final models = entities.map(_dataSource.toModel).toList();
        controller.add(models);
      }
      emit();
      void listener() => emit();
      listenable.addListener(listener);
      controller.onCancel = () {
        listenable.removeListener(listener);
      };
    });
  }

  @override
  Stream<List<RecipeModel>> watchFavorites() {
    return watchAll().map((recipes) {
      return recipes.where((r) => r.isFavorite).toList();
    });
  }

  @override
  List<RecipeModel> getAll() {
    return _dataSource.getAll();
  }

  @override
  RecipeModel? getById(String id) {
    return _dataSource.getById(id);
  }

  /// Helper to convert RecipeModel to Recipe (non-async to avoid yield keyword issue)
  Recipe _modelToCoreRecipe(RecipeModel recipe) {
    return Recipe(
      title: recipe.title,
      ingredients: recipe.ingredients,
      instructions: recipe.instructions,
      description: recipe.description,
      imageUrl: recipe.imageUrl,
      author: recipe.author,
      sourceUrl: recipe.sourceUrl,
      yield: recipe.servings,
      prepTime: recipe.prepTimeMinutes != null
          ? Duration(minutes: recipe.prepTimeMinutes!)
          : null,
      cookTime: recipe.cookTimeMinutes != null
          ? Duration(minutes: recipe.cookTimeMinutes!)
          : null,
      totalTime: recipe.totalTimeMinutes != null
          ? Duration(minutes: recipe.totalTimeMinutes!)
          : null,
      metadata: recipe.metadata,
    );
  }

  @override
  Future<void> save(RecipeModel recipe) async {
    // For now, we need to convert to the old format
    // TODO: Refactor RecipeStore to work directly with RecipeModel
    final store = RecipeStore.instance;
    
    // Check if it's a new recipe or update
    final existing = store.entityFor(recipe.id);
    if (existing == null) {
      // New recipe - need to create RecipeParseResult
      final coreRecipe = _modelToCoreRecipe(recipe);
      
      final parseResult = RecipeParseResult(
        recipe: coreRecipe,
        strategy: recipe.strategy ?? 'unknown',
      );
      
      await store.saveRecipe(
        result: parseResult,
        url: recipe.id,
      );
    } else {
      // Update existing
      final coreRecipe = _modelToCoreRecipe(recipe);
      
      await store.updateRecipe(
        url: recipe.id,
        recipe: coreRecipe,
      );
    }
    
    // Update favorite status if changed
    if (recipe.isFavorite != (existing?.isFavorite ?? false)) {
      await store.toggleFavorite(recipe.id);
    }
  }

  @override
  Future<void> update(RecipeModel recipe) async {
    await save(recipe);
  }

  @override
  Future<void> delete(String id) async {
    await _dataSource.delete(id);
  }

  @override
  Future<void> toggleFavorite(String id) async {
    await _dataSource.toggleFavorite(id);
  }

  @override
  Future<void> updateFilters({
    required String id,
    String? continent,
    String? country,
    String? diet,
    String? course,
  }) async {
    // Call the store's updateFilters directly to avoid going through updateRecipe
    // which would preserve old filter values
    final store = RecipeStore.instance;
    await store.updateFilters(
      url: id,
      continent: continent,
      country: country,
      diet: diet,
      course: course,
    );
  }

  @override
  List<String> getAllContinents() {
    final all = getAll();
    return all
        .map((r) => r.continent)
        .whereType<String>()
        .toSet()
        .toList()
      ..sort();
  }

  @override
  List<String> getAllCountries() {
    final all = getAll();
    return all
        .map((r) => r.country)
        .whereType<String>()
        .toSet()
        .toList()
      ..sort();
  }

  @override
  List<String> getAllDiets() {
    final all = getAll();
    return all
        .map((r) => r.diet)
        .whereType<String>()
        .toSet()
        .toList()
      ..sort();
  }

  @override
  List<String> getAllCourses() {
    final all = getAll();
    return all
        .map((r) => r.course)
        .whereType<String>()
        .toSet()
        .toList()
      ..sort();
  }
}

