import 'package:flutter/material.dart';

import '../navigation/app_drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.openAddRecipe,
    required this.openManualRecipe,
    required this.openStoredRecipes,
    required this.openShoppingList,
    required this.openInventory,
  });

  static const routeName = '/home';

  final VoidCallback openAddRecipe;
  final VoidCallback openManualRecipe;
  final VoidCallback openStoredRecipes;
  final VoidCallback openShoppingList;
  final VoidCallback openInventory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Recipe Parser')),
      drawer: const AppDrawer(currentRoute: routeName),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Hi there! 👋',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Parse new recipes, build your collection and plan meals with ease.',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Get started',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: openAddRecipe,
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('Add a recipe from URL'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: openManualRecipe,
                        icon: const Icon(Icons.create_outlined),
                        label: const Text('Create manual recipe'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: openStoredRecipes,
                        icon: const Icon(Icons.book_outlined),
                        label: const Text('Browse stored recipes'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: openShoppingList,
                        icon: const Icon(Icons.shopping_cart_outlined),
                        label: const Text('Open shopping list'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: openInventory,
                        icon: const Icon(Icons.inventory_2_outlined),
                        label: const Text('Manage inventory'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tips',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const _TipBullet(
                        icon: Icons.domain,
                        text:
                            'Use domain discovery to pull whole recipe libraries.',
                      ),
                      const _TipBullet(
                        icon: Icons.star_border,
                        text:
                            'Favourite recipes to surface them in filters and the meal planner.',
                      ),
                      const _TipBullet(
                        icon: Icons.calendar_month,
                        text:
                            'Fill the meal planner to reuse ingredients efficiently.',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TipBullet extends StatelessWidget {
  const _TipBullet({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
