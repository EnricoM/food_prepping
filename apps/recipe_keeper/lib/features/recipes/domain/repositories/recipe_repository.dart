import 'dart:async';

import '../models/recipe_model.dart';

/// Repository interface for recipe data operations
/// 
/// This defines the contract for recipe data access.
/// Implementations will be in the data layer.
abstract class RecipeRepository {
  /// Stream of all recipes
  Stream<List<RecipeModel>> watchAll();

  /// Stream of favorite recipes
  Stream<List<RecipeModel>> watchFavorites();

  /// Get all recipes synchronously
  List<RecipeModel> getAll();

  /// Get a recipe by ID
  RecipeModel? getById(String id);

  /// Save a recipe
  Future<void> save(RecipeModel recipe);

  /// Update a recipe
  Future<void> update(RecipeModel recipe);

  /// Delete a recipe
  Future<void> delete(String id);

  /// Toggle favorite status
  Future<void> toggleFavorite(String id);

  /// Update filter values for a recipe
  Future<void> updateFilters({
    required String id,
    String? continent,
    String? country,
    String? diet,
    String? course,
  });

  /// Get all unique values for filtering
  List<String> getAllContinents();
  List<String> getAllCountries();
  List<String> getAllDiets();
  List<String> getAllCourses();
}

