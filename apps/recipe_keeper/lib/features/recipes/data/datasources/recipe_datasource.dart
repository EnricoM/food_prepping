import 'dart:async';
import 'dart:convert';

import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/models/recipe_model.dart';

/// Data source for recipes
/// 
/// This adapts the existing RecipeStore to work with the new RecipeModel.
/// This allows gradual migration without breaking existing functionality.
class RecipeDataSource {
  RecipeDataSource(this._store);

  final RecipeStore _store;

  ValueListenable<Box<RecipeEntity>> get listenable => _store.listenable();

  /// Convert RecipeEntity to RecipeModel
  RecipeModel toModel(RecipeEntity entity) {
    return RecipeModel(
      id: entity.url,
      title: entity.title,
      ingredients: entity.ingredients,
      instructions: entity.instructions,
      description: entity.description,
      imageUrl: entity.imageUrl,
      author: entity.author,
      sourceUrl: entity.sourceUrl,
      servings: entity.yield,
      prepTimeMinutes: entity.prepTimeSeconds != null
          ? entity.prepTimeSeconds! ~/ 60
          : null,
      cookTimeMinutes: entity.cookTimeSeconds != null
          ? entity.cookTimeSeconds! ~/ 60
          : null,
      totalTimeMinutes: entity.totalTimeSeconds != null
          ? entity.totalTimeSeconds! ~/ 60
          : null,
      continent: entity.continent,
      country: entity.country,
      diet: entity.diet,
      course: entity.course,
      isFavorite: entity.isFavorite,
      cachedAt: entity.cachedAt,
      strategy: entity.strategy,
      categories: entity.normalizedCategories,
      metadata: entity.metadataJson != null
          ? Map<String, dynamic>.from(
              (jsonDecode(entity.metadataJson!) as Map<String, dynamic>))
          : {},
    );
  }

  /// Convert RecipeModel to RecipeEntity
  RecipeEntity toEntity(RecipeModel model) {
    final recipe = Recipe(
      title: model.title,
      ingredients: model.ingredients,
      instructions: model.instructions,
      description: model.description,
      imageUrl: model.imageUrl,
      author: model.author,
      sourceUrl: model.sourceUrl,
      yield: model.servings,
      prepTime: model.prepTimeMinutes != null
          ? Duration(minutes: model.prepTimeMinutes!)
          : null,
      cookTime: model.cookTimeMinutes != null
          ? Duration(minutes: model.cookTimeMinutes!)
          : null,
      totalTime: model.totalTimeMinutes != null
          ? Duration(minutes: model.totalTimeMinutes!)
          : null,
      metadata: model.metadata,
    );

    return RecipeEntity.fromRecipe(
      recipe,
      url: model.id,
      strategy: model.strategy ?? 'unknown',
    ).copyWith(
      isFavorite: model.isFavorite,
      continent: model.continent,
      country: model.country,
      diet: model.diet,
      course: model.course,
    );
  }

  List<RecipeModel> getAll() {
    return _store.allEntities().map(toModel).toList();
  }

  RecipeModel? getById(String id) {
    final entity = _store.entityFor(id);
    return entity != null ? toModel(entity) : null;
  }

  Future<void> save(RecipeModel model) async {
    // Use the existing store's save method
    // For now, we'll need to adapt this
    // TODO: Refactor RecipeStore to accept RecipeModel directly
    // The actual save logic is handled in RecipeRepositoryImpl
  }

  Future<void> delete(String id) async {
    await _store.delete(id);
  }

  Future<void> toggleFavorite(String id) async {
    await _store.toggleFavorite(id);
  }
}

