import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../../../app/di.dart';
import '../../../../src/navigation/app_drawer.dart';
import '../../../../src/widgets/back_aware_app_bar.dart';
import '../../domain/models/recipe_model.dart';
import '../controllers/recipe_controller.dart';
import '../utils/recipe_navigation.dart';
import '../widgets/recipe_tile.dart';

/// Screen displaying recipes suitable for batch cooking
/// 
/// Uses Riverpod for state management and the new RecipeController.
class BatchCookingScreen extends ConsumerWidget {
  const BatchCookingScreen({
    super.key,
    this.drawer,
  });

  static const routeName = '/batch-cooking';

  final Widget? drawer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(recipeControllerProvider.notifier);
    final state = ref.watch(recipeControllerProvider);
    final inset = responsivePageInsets(context);
    final theme = Theme.of(context);

    // Filter recipes good for batch cooking
    final allRecipes = state.recipes;
    final batchRecipes = allRecipes
        .where((recipeModel) {
          // Convert to Recipe for compatibility with RecipeScaler
          final recipe = RecipeNavigation.toRecipe(recipeModel);
          return RecipeScaler.isGoodForBatchCooking(recipe);
        })
        .toList()
      ..sort(
        (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      );

    return Scaffold(
      appBar: const BackAwareAppBar(
        title: Text('Batch Cooking'),
      ),
      drawer: drawer ?? const AppDrawer(currentRoute: routeName),
      body: SafeArea(
        child: Padding(
          padding: inset,
          child: _buildBody(context, state, batchRecipes, controller, theme),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    RecipeListState state,
    List<RecipeModel> batchRecipes,
    RecipeController controller,
    ThemeData theme,
  ) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                'Error loading recipes',
                style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                state.error!,
                style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (batchRecipes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.batch_prediction_outlined,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No batch cooking recipes yet',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Recipes like soups, stews, casseroles, and sauces are great for batch cooking.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Batch Cooking Tips',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'These recipes are great for making in large batches and storing for later.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => controller.refresh(),
            child: ListView.separated(
              itemCount: batchRecipes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final recipe = batchRecipes[index];
                return RecipeTile(
                  recipe: recipe,
                  onTap: () => RecipeNavigation.pushRecipeDetails(context, recipe),
                  onToggleFavorite: () => controller.toggleFavorite(recipe.id),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

