import '../models/recipe_model.dart';

/// Use cases for recipe operations
/// 
/// These define the business logic for recipe operations.
/// Use cases are pure functions that don't depend on UI or data sources.

/// Get all recipes
class GetAllRecipesUseCase {
  const GetAllRecipesUseCase();

  List<RecipeModel> call(List<RecipeModel> recipes) {
    return List<RecipeModel>.from(recipes)
      ..sort(
        (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      );
  }
}

/// Get favorite recipes
class GetFavoriteRecipesUseCase {
  const GetFavoriteRecipesUseCase();

  List<RecipeModel> call(List<RecipeModel> recipes) {
    return recipes.where((r) => r.isFavorite).toList()
      ..sort(
        (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      );
  }
}

/// Get recently added recipes
class GetRecentlyAddedRecipesUseCase {
  const GetRecentlyAddedRecipesUseCase();

  List<RecipeModel> call(List<RecipeModel> recipes, {int limit = 10}) {
    final sorted = List<RecipeModel>.from(recipes)
      ..sort((a, b) {
        final aDate = a.cachedAt ?? DateTime(1970);
        final bDate = b.cachedAt ?? DateTime(1970);
        return bDate.compareTo(aDate);
      });
    return sorted.take(limit).toList();
  }
}

/// Filter recipes by criteria
class FilterRecipesUseCase {
  const FilterRecipesUseCase();

  List<RecipeModel> call({
    required List<RecipeModel> recipes,
    String query = '',
    String? continent,
    String? country,
    String? diet,
    String? course,
  }) {
    return recipes.where((recipe) {
      // Text search
      if (query.isNotEmpty) {
        final searchText = query.toLowerCase();
        final matchesQuery = 
            recipe.title.toLowerCase().contains(searchText) ||
            recipe.description?.toLowerCase().contains(searchText) == true ||
            recipe.ingredientStrings.any((i) => i.toLowerCase().contains(searchText)) ||
            recipe.instructions.any((i) => i.toLowerCase().contains(searchText));
        if (!matchesQuery) return false;
      }

      // Filter by continent
      if (continent != null && recipe.continent != continent) {
        return false;
      }

      // Filter by country
      if (country != null && recipe.country != country) {
        return false;
      }

      // Filter by diet
      if (diet != null && recipe.diet != diet) {
        return false;
      }

      // Filter by course
      if (course != null && recipe.course != course) {
        return false;
      }

      return true;
    }).toList()
      ..sort(
        (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      );
  }
}

/// Toggle favorite status
class ToggleFavoriteUseCase {
  const ToggleFavoriteUseCase();

  RecipeModel call(RecipeModel recipe) {
    return recipe.copyWith(isFavorite: !recipe.isFavorite);
  }
}

