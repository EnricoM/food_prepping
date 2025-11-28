import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../domain/models/recipe_model.dart';
import '../screens/recipe_detail_screen.dart' as new_detail;

/// Navigation utilities for recipes
/// 
/// Bridges between the new RecipeModel and the existing/new RecipeDetailScreen.
class RecipeNavigation {
  RecipeNavigation._();

  /// Convert RecipeModel to Recipe for compatibility with existing utilities
  static Recipe toRecipe(RecipeModel model) {
    return Recipe(
      title: model.title,
      ingredients: model.ingredients,
      instructions: model.instructions,
      description: model.description,
      imageUrl: model.imageUrl,
      author: model.author,
      sourceUrl: model.sourceUrl ?? model.id,
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
  }

  /// Navigate to recipe details from a RecipeModel
  static void pushRecipeDetails(
    BuildContext context,
    RecipeModel recipeModel,
  ) {
    // Use MaterialPageRoute directly to avoid routing complexity
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => new_detail.RecipeDetailScreen(
          args: new_detail.RecipeDetailArgs(recipe: recipeModel),
        ),
      ),
    );
  }
}

