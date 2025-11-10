import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_ui/shared_ui.dart';

class RecipeDetailArgs {
  RecipeDetailArgs({required this.recipe, this.entity});

  final Recipe recipe;
  final RecipeEntity? entity;
}

class RecipeDetailScreen extends StatelessWidget {
  const RecipeDetailScreen({super.key, required this.args});

  static const routeName = '/recipe-detail';

  final RecipeDetailArgs args;

  @override
  Widget build(BuildContext context) {
    final recipe = args.recipe;
    final entity = args.entity;
    final tabs = const [
      Tab(icon: Icon(Icons.dashboard_outlined), text: 'Overview'),
      Tab(icon: Icon(Icons.list_alt_outlined), text: 'Ingredients'),
      Tab(icon: Icon(Icons.receipt_long_outlined), text: 'Preparation'),
    ];
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(recipe.title),
          actions: [
            if (recipe.sourceUrl != null)
              IconButton(
                tooltip: 'Copy recipe URL',
                icon: const Icon(Icons.copy),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: recipe.sourceUrl!));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Recipe URL copied.')),
                  );
                },
              ),
            if (entity != null)
              IconButton(
                tooltip:
                    entity.isFavorite ? 'Remove favourite' : 'Add to favourites',
                icon: Icon(
                  entity.isFavorite ? Icons.star : Icons.star_border,
                  color: entity.isFavorite
                      ? Theme.of(context).colorScheme.onPrimary
                      : null,
                ),
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final becomingFavorite = !entity.isFavorite;
                  await RecipeStore.instance.toggleFavorite(entity.url);
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        becomingFavorite
                            ? 'Added to favourites'
                            : 'Removed from favourites',
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
        body: TabBarView(
          children: [
            _OverviewTab(recipe: recipe, entity: entity),
            _IngredientsTab(ingredients: recipe.ingredients),
            _InstructionsTab(instructions: recipe.instructions),
          ],
        ),
        bottomNavigationBar: Material(
          elevation: 6,
          color: Theme.of(context).colorScheme.surface,
          child: SafeArea(
            top: false,
            child: TabBar(
              tabs: tabs,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor:
                  Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.recipe, this.entity});

  final Recipe recipe;
  final RecipeEntity? entity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                recipe.imageUrl!,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 16),
          Text(
            recipe.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (recipe.description != null && recipe.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(recipe.description!),
            ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              if (recipe.yield != null)
                _InfoChip(icon: Icons.restaurant, label: recipe.yield!),
              if (recipe.prepTime != null)
                _InfoChip(
                  icon: Icons.timer_outlined,
                  label: 'Prep ${recipe.prepTime!.inMinutes} min',
                ),
              if (recipe.cookTime != null)
                _InfoChip(
                  icon: Icons.local_fire_department_outlined,
                  label: 'Cook ${recipe.cookTime!.inMinutes} min',
                ),
              if (recipe.totalTime != null)
                _InfoChip(
                  icon: Icons.schedule,
                  label: 'Total ${recipe.totalTime!.inMinutes} min',
                ),
              if (entity?.country != null)
                _InfoChip(icon: Icons.public, label: entity!.country!),
              if (entity?.continent != null)
                _InfoChip(icon: Icons.map_outlined, label: entity!.continent!),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              await ShoppingListStore.instance.addIngredientsFromRecipe(recipe);
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Recipe ingredients added to shopping list.'),
                ),
              );
            },
            icon: const Icon(Icons.shopping_cart_outlined),
            label: const Text('Add ingredients to shopping list'),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Highlights', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Text(ingredientsPreview(recipe)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredientsTab extends StatelessWidget {
  const _IngredientsTab({required this.ingredients});

  final List<String> ingredients;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: ingredients.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Text('• ${ingredients[index]}');
      },
    );
  }
}

class _InstructionsTab extends StatelessWidget {
  const _InstructionsTab({required this.instructions});

  final List<String> instructions;

  @override
  Widget build(BuildContext context) {
    if (instructions.isEmpty) {
      return const Center(
        child: Text('Preparation steps were not provided for this recipe.'),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: instructions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${index + 1}. ', style: const TextStyle(fontWeight: FontWeight.w600)),
            Expanded(child: Text(instructions[index])),
          ],
        );
      },
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}
