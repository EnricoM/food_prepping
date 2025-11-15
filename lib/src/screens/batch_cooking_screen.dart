import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

import '../navigation/app_drawer.dart';
import '../widgets/back_aware_app_bar.dart';
import 'widgets/recipe_tile.dart';

class BatchCookingScreen extends StatelessWidget {
  const BatchCookingScreen({
    super.key,
    this.drawer,
    required this.onRecipeTap,
  });

  static const routeName = '/batch-cooking';

  final Widget? drawer;
  final void Function(BuildContext context, RecipeEntity entity) onRecipeTap;

  @override
  Widget build(BuildContext context) {
    final inset = responsivePageInsets(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: const BackAwareAppBar(
        title: Text('Batch Cooking'),
      ),
      drawer: drawer ?? const AppDrawer(currentRoute: routeName),
      body: SafeArea(
        child: Padding(
          padding: inset,
          child: StreamBuilder<List<RecipeEntity>>(
            stream: AppRepositories.instance.recipes.watchAll(),
            builder: (context, snapshot) {
              final allRecipes = snapshot.data ?? const <RecipeEntity>[];
              
              // Filter recipes good for batch cooking
              final batchRecipes = allRecipes.where((entity) {
                final recipe = entity.toRecipe();
                return RecipeScaler.isGoodForBatchCooking(recipe);
              }).toList()
                ..sort(
                  (a, b) =>
                      a.title.toLowerCase().compareTo(b.title.toLowerCase()),
                );

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
                            color: theme.colorScheme.primaryContainer
                                .withValues(alpha: 0.2),
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
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
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
                    child: ListView.separated(
                      itemCount: batchRecipes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final entity = batchRecipes[index];
                        return RecipeListTile(
                          entity: entity,
                          onTap: () => onRecipeTap(context, entity),
                          onToggleFavorite: () =>
                              AppRepositories.instance.recipes
                                  .toggleFavorite(entity.url),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

