import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/recipe_model.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../../domain/usecases/recipe_usecases.dart';

/// State for recipe list
class RecipeListState {
  const RecipeListState({
    this.recipes = const [],
    this.isLoading = false,
    this.error,
  });

  final List<RecipeModel> recipes;
  final bool isLoading;
  final String? error;

  RecipeListState copyWith({
    List<RecipeModel>? recipes,
    bool? isLoading,
    String? error,
  }) {
    return RecipeListState(
      recipes: recipes ?? this.recipes,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Controller for recipe operations
class RecipeController extends StateNotifier<RecipeListState> {
  RecipeController(
    this._repository, {
    GetAllRecipesUseCase? getAllRecipesUseCase,
    GetFavoriteRecipesUseCase? getFavoriteRecipesUseCase,
    GetRecentlyAddedRecipesUseCase? getRecentlyAddedRecipesUseCase,
    FilterRecipesUseCase? filterRecipesUseCase,
  })  : _getAllRecipesUseCase = getAllRecipesUseCase ?? const GetAllRecipesUseCase(),
        _getFavoriteRecipesUseCase = getFavoriteRecipesUseCase ?? const GetFavoriteRecipesUseCase(),
        _getRecentlyAddedRecipesUseCase = getRecentlyAddedRecipesUseCase ?? const GetRecentlyAddedRecipesUseCase(),
        _filterRecipesUseCase = filterRecipesUseCase ?? const FilterRecipesUseCase(),
        super(const RecipeListState(isLoading: true)) {
    _subscribeToRecipes();
  }

  final RecipeRepository _repository;
  final GetAllRecipesUseCase _getAllRecipesUseCase;
  final GetFavoriteRecipesUseCase _getFavoriteRecipesUseCase;
  final GetRecentlyAddedRecipesUseCase _getRecentlyAddedRecipesUseCase;
  final FilterRecipesUseCase _filterRecipesUseCase;

  StreamSubscription<List<RecipeModel>>? _subscription;

  void _subscribeToRecipes() {
    _subscription?.cancel();
    _subscription = _repository.watchAll().listen(
      (recipes) {
        final sorted = _getAllRecipesUseCase(recipes);
        state = state.copyWith(
          recipes: sorted,
          isLoading: false,
          error: null,
        );
      },
      onError: (error) {
        state = state.copyWith(
          error: error.toString(),
          isLoading: false,
        );
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> refresh() async {
    // Trigger reload by re-subscribing
    _subscribeToRecipes();
  }

  Future<void> toggleFavorite(String id) async {
    try {
      await _repository.toggleFavorite(id);
      // Stream will automatically update
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> delete(String id) async {
    try {
      await _repository.delete(id);
      // Stream will automatically update
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  List<RecipeModel> getFavorites() {
    return _getFavoriteRecipesUseCase(state.recipes);
  }

  List<RecipeModel> getRecentlyAdded({int limit = 10}) {
    return _getRecentlyAddedRecipesUseCase(state.recipes, limit: limit);
  }

  List<RecipeModel> filter({
    String query = '',
    String? continent,
    String? country,
    String? diet,
    String? course,
  }) {
    return _filterRecipesUseCase(
      recipes: state.recipes,
      query: query,
      continent: continent,
      country: country,
      diet: diet,
      course: course,
    );
  }
}

