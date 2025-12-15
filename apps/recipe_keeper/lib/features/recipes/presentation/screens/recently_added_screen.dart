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

/// Screen displaying recently added recipes
/// 
/// Uses Riverpod for state management and the new RecipeController.
class RecentlyAddedScreen extends ConsumerWidget {
  const RecentlyAddedScreen({
    super.key,
    this.drawer,
  });

  static const routeName = '/recent';

  final Widget? drawer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(recipeControllerProvider.notifier);
    final state = ref.watch(recipeControllerProvider);
    final inset = responsivePageInsets(context);

    // Get recently added recipes from the controller
    final recent = controller.getRecentlyAdded(limit: 50);

    return Scaffold(
      appBar: const BackAwareAppBar(title: Text('Recently added')),
      drawer: drawer ?? const AppDrawer(currentRoute: routeName),
      body: SafeArea(
        child: Padding(
          padding: inset,
          child: _buildBody(context, recent, state, controller),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    List<RecipeModel> recent,
    RecipeListState state,
    RecipeController controller,
  ) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return _buildError(context, state.error!);
    }

    if (recent.isEmpty) {
      return _buildEmpty(context);
    }

    return RefreshIndicator(
      onRefresh: () => controller.refresh(),
      child: ListView.separated(
        itemCount: recent.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final recipe = recent[index];
          return RecipeTile(
            recipe: recipe,
            onTap: () => RecipeNavigation.pushRecipeDetails(context, recipe),
            onToggleFavorite: () => controller.toggleFavorite(recipe.id),
          );
        },
      ),
    );
  }

  Widget _buildError(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              'Error loading recipes',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.history_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No recent recipes',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Recipes you add will appear here.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

