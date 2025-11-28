import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../../../app/di.dart';
import '../../../../src/navigation/app_drawer.dart';
import '../../../../src/screens/favorites_screen.dart';
import '../../../../src/screens/filter_recipes_screen.dart';
import '../../../../src/screens/visited_domains_screen.dart';
import '../../../../src/widgets/back_aware_app_bar.dart';
import '../../domain/models/recipe_model.dart';
import '../controllers/recipe_controller.dart';
import '../utils/recipe_navigation.dart';
import '../widgets/recipe_tile.dart';

/// Screen displaying all stored recipes
/// 
/// Uses Riverpod for state management and the new RecipeController.
class StoredRecipesScreen extends ConsumerWidget {
  const StoredRecipesScreen({
    super.key,
    this.drawer,
    required this.onRecipeTap,
  });

  static const routeName = '/stored';

  final Widget? drawer;
  final void Function(BuildContext context, RecipeModel recipe) onRecipeTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(recipeControllerProvider.notifier);
    final state = ref.watch(recipeControllerProvider);
    final inset = responsivePageInsets(context);

    return Scaffold(
      appBar: const BackAwareAppBar(title: Text('Stored recipes')),
      drawer: drawer ?? const AppDrawer(currentRoute: routeName),
      body: SafeArea(
        child: Padding(
          padding: inset,
          child: _buildBody(context, ref, state, controller),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    RecipeListState state,
    RecipeController controller,
  ) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return _buildError(context, state.error!);
    }

    if (state.recipes.isEmpty) {
      return _buildEmpty(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _RecipeStatsHeader(
          recipes: state.recipes,
          onNavigateToFavorites: () => Navigator.of(context).pushNamed(
            FavoritesScreen.routeName,
          ),
          onNavigateToDomains: () => Navigator.of(context).pushNamed(
            VisitedDomainsScreen.routeName,
          ),
          onNavigateToFilters: () => Navigator.of(context).pushNamed(
            FilterRecipesScreen.routeName,
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => controller.refresh(),
            child: ListView.separated(
              itemCount: state.recipes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final recipe = state.recipes[index];
                return RecipeTile(
                  recipe: recipe,
                  onTap: () {
                    // Use the navigation helper
                    RecipeNavigation.pushRecipeDetails(context, recipe);
                    // Also call the callback if provided (for compatibility)
                    onRecipeTap(context, recipe);
                  },
                  onToggleFavorite: () => controller.toggleFavorite(recipe.id),
                );
              },
            ),
          ),
        ),
      ],
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
                Icons.restaurant_menu_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No recipes yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Parse a recipe from a URL or create one manually to see it here.',
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

class _RecipeStatsHeader extends StatelessWidget {
  const _RecipeStatsHeader({
    required this.recipes,
    required this.onNavigateToFavorites,
    required this.onNavigateToDomains,
    required this.onNavigateToFilters,
  });

  final List<RecipeModel> recipes;
  final VoidCallback onNavigateToFavorites;
  final VoidCallback onNavigateToDomains;
  final VoidCallback onNavigateToFilters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = recipes.length;
    final favoriteCount = recipes.where((recipe) => recipe.isFavorite).length;
    final sources = recipes
        .map((recipe) => _hostFrom(recipe.sourceUrl ?? recipe.id))
        .whereType<String>()
        .where((host) => host.isNotEmpty)
        .toSet()
        .length;
    final diets = recipes
        .map((recipe) => recipe.diet?.trim())
        .whereType<String>()
        .where((diet) => diet.isNotEmpty)
        .toSet()
        .length;

    return Card(
      color: theme.colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your library at a glance',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                _StatChip(
                  icon: Icons.menu_book_outlined,
                  label: 'Saved recipes',
                  value: total.toString(),
                ),
                _StatChip(
                  icon: Icons.favorite_rounded,
                  label: 'Favorites',
                  value: favoriteCount.toString(),
                  iconColor: theme.colorScheme.error,
                  onTap: favoriteCount > 0 ? onNavigateToFavorites : null,
                ),
                _StatChip(
                  icon: Icons.public,
                  label: 'Unique sources',
                  value: sources.toString(),
                  onTap: sources > 0 ? onNavigateToDomains : null,
                ),
                _StatChip(
                  icon: Icons.eco_outlined,
                  label: 'Diet tags',
                  value: diets.toString(),
                  onTap: diets > 0 ? onNavigateToFilters : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String? _hostFrom(String? url) {
    if (url == null || url.isEmpty) {
      return null;
    }
    try {
      final uri = Uri.parse(url);
      var host = uri.host.toLowerCase();
      if (host.startsWith('www.')) {
        host = host.substring(4);
      }
      return host;
    } catch (_) {
      return null;
    }
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = theme.colorScheme.primaryContainer.withValues(alpha: 0.2);
    final borderRadius = BorderRadius.circular(16);
    return Material(
      color: background,
      borderRadius: borderRadius,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: iconColor ??
                    (onTap != null
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: onTap != null ? 0.7 : 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

