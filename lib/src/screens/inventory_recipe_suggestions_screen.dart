import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

import '../navigation/app_drawer.dart';
import 'recipe_detail_screen.dart';

class InventoryRecipeSuggestionsScreen extends StatelessWidget {
  const InventoryRecipeSuggestionsScreen({super.key, this.drawer});

  static const routeName = '/inventory-recipes';

  final Widget? drawer;

  @override
  Widget build(BuildContext context) {
    final inset = responsivePageInsets(context);
    return Scaffold(
      appBar: AppBar(title: const Text('What Can I Make?')),
      drawer: drawer ?? const AppDrawer(currentRoute: InventoryRecipeSuggestionsScreen.routeName),
      body: SafeArea(
        child: StreamBuilder<List<InventoryItem>>(
          stream: _watchInventory(),
          builder: (context, inventorySnapshot) {
            if (!inventorySnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final inventoryItems = inventorySnapshot.data!;
            if (inventoryItems.isEmpty) {
              return Center(
                child: Padding(
                  padding: inset,
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
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No items in inventory',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add items to your inventory to see recipe suggestions.',
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

            return StreamBuilder<List<RecipeEntity>>(
              stream: AppRepositories.instance.recipes.watchAll(),
              builder: (context, recipeSnapshot) {
                if (!recipeSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final recipes = recipeSnapshot.data!;
                if (recipes.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: inset,
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
                            'No recipes available',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add some recipes to see what you can make with your inventory.',
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

                final matches = InventoryRecipeMatcher.matchRecipes(
                  recipes: recipes,
                  inventoryItems: inventoryItems,
                );

                if (matches.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: inset,
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
                              Icons.search_off_outlined,
                              size: 64,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'No matches found',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adding more items to your inventory or more recipes to your collection.',
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

                // Group by match status
                final canMake = matches.where((m) => m.canMake).toList();
                final partialMatches = matches.where((m) => !m.canMake).toList();

                return CustomScrollView(
                  slivers: [
                    if (canMake.isNotEmpty) ...[
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          inset.left,
                          inset.top,
                          inset.right,
                          0,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: _SectionHeader(
                            title: 'You Can Make These!',
                            count: canMake.length,
                            icon: Icons.check_circle_outline,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          inset.left,
                          8,
                          inset.right,
                          0,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final match = canMake[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _RecipeMatchCard(
                                  match: match,
                                  onTap: () => _showRecipe(context, match.recipe),
                                ),
                              );
                            },
                            childCount: canMake.length,
                          ),
                        ),
                      ),
                    ],
                    if (partialMatches.isNotEmpty) ...[
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          inset.left,
                          canMake.isNotEmpty ? 24 : inset.top,
                          inset.right,
                          0,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: _SectionHeader(
                            title: 'Almost There',
                            subtitle: 'Missing a few ingredients',
                            count: partialMatches.length,
                            icon: Icons.info_outline,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          inset.left,
                          8,
                          inset.right,
                          inset.bottom,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final match = partialMatches[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _RecipeMatchCard(
                                  match: match,
                                  onTap: () => _showRecipe(context, match.recipe),
                                ),
                              );
                            },
                            childCount: partialMatches.length,
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Stream<List<InventoryItem>> _watchInventory() {
    final listenable = InventoryStore.instance.listenable();
    return Stream<List<InventoryItem>>.multi((controller) {
      void emit() => controller.add(InventoryStore.instance.items().toList());
      emit();
      void listener() => emit();
      listenable.addListener(listener);
      controller.onCancel = () {
        listenable.removeListener(listener);
      };
    });
  }

  void _showRecipe(BuildContext context, RecipeEntity entity) {
    Navigator.of(context).pushNamed(
      RecipeDetailScreen.routeName,
      arguments: RecipeDetailArgs(
        recipe: entity.toRecipe(),
        entity: entity,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final int count;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ),
        Chip(
          label: Text('$count'),
          backgroundColor: color.withValues(alpha: 0.1),
        ),
      ],
    );
  }
}

class _RecipeMatchCard extends StatelessWidget {
  const _RecipeMatchCard({
    required this.match,
    required this.onTap,
  });

  final RecipeMatchResult match;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recipe = match.recipe.toRecipe();
    
    return Card(
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (recipe.description != null && recipe.description!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              recipe.description!,
                              style: theme.textTheme.bodySmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (match.canMake)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, size: 16, color: Colors.green),
                          const SizedBox(width: 4),
                          Text(
                            'Ready',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _IngredientStatus(
                      label: 'Available',
                      count: match.availableCount,
                      total: match.totalCount,
                      color: Colors.green,
                    ),
                  ),
                  if (match.missingIngredients.isNotEmpty) ...[
                    const SizedBox(width: 16),
                    Expanded(
                      child: _IngredientStatus(
                        label: 'Missing',
                        count: match.missingIngredients.length,
                        total: match.totalCount,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ],
              ),
              if (match.missingIngredients.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: match.missingIngredients.take(5).map((ingredient) {
                    return Chip(
                      label: Text(
                        ingredient,
                        style: const TextStyle(fontSize: 11),
                      ),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      backgroundColor: Colors.orange.withValues(alpha: 0.1),
                      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                    );
                  }).toList(),
                ),
                if (match.missingIngredients.length > 5)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '+ ${match.missingIngredients.length - 5} more',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
      ),
    );
  }
}

class _IngredientStatus extends StatelessWidget {
  const _IngredientStatus({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  final String label;
  final int count;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(color == Colors.green ? Icons.check_circle_outline : Icons.remove_circle_outline,
                size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: count / total,
                backgroundColor: color.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$count/$total',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}

