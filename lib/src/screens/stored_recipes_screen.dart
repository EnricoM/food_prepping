import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

import '../navigation/app_drawer.dart';
import '../widgets/back_aware_app_bar.dart';
import 'favorites_screen.dart';
import 'filter_recipes_screen.dart';
import 'visited_domains_screen.dart';
import 'widgets/recipe_tile.dart';

class StoredRecipesScreen extends StatelessWidget {
  const StoredRecipesScreen({
    super.key,
    this.drawer,
    required this.onRecipeTap,
  });

  static const routeName = '/stored';

  final Widget? drawer;
  final void Function(BuildContext context, RecipeEntity entity) onRecipeTap;

  @override
  Widget build(BuildContext context) {
    final inset = responsivePageInsets(context);
    return Scaffold(
      appBar: const BackAwareAppBar(title: Text('Stored recipes')),
      drawer: drawer ?? const AppDrawer(currentRoute: routeName),
      body: SafeArea(
        child: Padding(
          padding: inset,
          child: StreamBuilder<List<RecipeEntity>>(
            stream: AppRepositories.instance.recipes.watchAll(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
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
                          snapshot.error.toString(),
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
              
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              
              final recipes = List<RecipeEntity>.from(
                snapshot.data ?? const <RecipeEntity>[],
              )..sort(
                  (a, b) =>
                      a.title.toLowerCase().compareTo(b.title.toLowerCase()),
                );
              if (recipes.isEmpty) {
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
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _RecipeStatsHeader(recipes: recipes),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.separated(
                      itemCount: recipes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final entity = recipes[index];
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

class _RecipeStatsHeader extends StatelessWidget {
  const _RecipeStatsHeader({required this.recipes});

  final List<RecipeEntity> recipes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = recipes.length;
    final favoriteCount = recipes.where((recipe) => recipe.isFavorite).length;
    final sources = recipes
        .map((recipe) => _hostFrom(recipe.sourceUrl ?? recipe.url))
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
                  onTap: favoriteCount > 0
                      ? () => Navigator.of(context).pushNamed(
                            FavoritesScreen.routeName,
                          )
                      : null,
                ),
                _StatChip(
                  icon: Icons.public,
                  label: 'Unique sources',
                  value: sources.toString(),
                  onTap: sources > 0
                      ? () => Navigator.of(context).pushNamed(
                            VisitedDomainsScreen.routeName,
                          )
                      : null,
                ),
                _StatChip(
                  icon: Icons.eco_outlined,
                  label: 'Diet tags',
                  value: diets.toString(),
                  onTap: diets > 0
                      ? () => Navigator.of(context).pushNamed(
                            FilterRecipesScreen.routeName,
                          )
                      : null,
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
