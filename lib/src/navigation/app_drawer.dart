import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, required this.currentRoute});

  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const _DrawerHeader(),
            _DrawerSection(
              title: 'Recipes',
              entries: _DrawerEntry.recipeEntries,
              currentRoute: currentRoute,
            ),
            _DrawerSection(
              title: 'Inventory & Shopping',
              entries: _DrawerEntry.inventoryShoppingEntries,
              currentRoute: currentRoute,
            ),
            _DrawerSection(
              title: 'Meal Planning',
              entries: _DrawerEntry.mealPlanningEntries,
              currentRoute: currentRoute,
            ),
            _DrawerSection(
              title: 'App',
              entries: _DrawerEntry.appEntries,
              currentRoute: currentRoute,
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Recipe Parser',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerEntry {
  const _DrawerEntry({
    required this.icon,
    required this.label,
    required this.routeName,
  });

  final IconData icon;
  final String label;
  final String routeName;

  // Recipe related entries
  static final recipeEntries = <_DrawerEntry>[
    const _DrawerEntry(
      icon: Icons.home_outlined,
      label: 'Home',
      routeName: '/home',
    ),
    const _DrawerEntry(
      icon: Icons.add_circle_outline,
      label: 'Add recipe',
      routeName: '/add',
    ),
    const _DrawerEntry(
      icon: Icons.create_outlined,
      label: 'Create manual recipe',
      routeName: '/manual',
    ),
    const _DrawerEntry(
      icon: Icons.book_outlined,
      label: 'Stored recipes',
      routeName: '/stored',
    ),
    const _DrawerEntry(
      icon: Icons.filter_alt_outlined,
      label: 'Filter recipes',
      routeName: '/filter',
    ),
    const _DrawerEntry(
      icon: Icons.star_outline,
      label: 'Favourites',
      routeName: '/favorites',
    ),
    const _DrawerEntry(
      icon: Icons.history,
      label: 'Recently added',
      routeName: '/recent',
    ),
    const _DrawerEntry(
      icon: Icons.explore_outlined,
      label: 'Discover domain',
      routeName: '/discover',
    ),
    const _DrawerEntry(
      icon: Icons.history_outlined,
      label: 'Visited domains',
      routeName: '/visited-domains',
    ),
    const _DrawerEntry(
      icon: Icons.batch_prediction_outlined,
      label: 'Batch cooking',
      routeName: '/batch-cooking',
    ),
  ];

  // Inventory & Shopping related entries
  static final inventoryShoppingEntries = <_DrawerEntry>[
    const _DrawerEntry(
      icon: Icons.inventory_2_outlined,
      label: 'Inventory',
      routeName: '/inventory',
    ),
    const _DrawerEntry(
      icon: Icons.restaurant_menu,
      label: 'What can I make?',
      routeName: '/inventory-recipes',
    ),
    const _DrawerEntry(
      icon: Icons.shopping_cart_outlined,
      label: 'Shopping list',
      routeName: '/shopping-list',
    ),
  ];

  // Meal planning related entries
  static final mealPlanningEntries = <_DrawerEntry>[
    const _DrawerEntry(
      icon: Icons.calendar_month_outlined,
      label: 'Meal planner',
      routeName: '/meal-plan',
    ),
  ];

  static final appEntries = <_DrawerEntry>[
    const _DrawerEntry(
      icon: Icons.settings_outlined,
      label: 'Settings',
      routeName: '/settings',
    ),
    const _DrawerEntry(
      icon: Icons.workspace_premium_outlined,
      label: 'Upgrade to Premium',
      routeName: '/upgrade',
    ),
  ];
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: theme.colorScheme.onPrimary.withValues(alpha: 0.2),
            child: Icon(
              Icons.restaurant_menu,
              color: theme.colorScheme.onPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Recipe Parser',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Cook smarter, plan easier',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerSection extends StatelessWidget {
  const _DrawerSection({
    required this.title,
    required this.entries,
    required this.currentRoute,
  });

  final String title;
  final List<_DrawerEntry> entries;
  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        for (final entry in entries)
          _DrawerTile(
            icon: entry.icon,
            label: entry.label,
            routeName: entry.routeName,
            currentRoute: currentRoute,
          ),
      ],
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.routeName,
    required this.currentRoute,
  });

  final IconData icon;
  final String label;
  final String routeName;
  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    final isSelected = currentRoute == routeName;
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: isSelected ? theme.colorScheme.primary : null),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected ? theme.colorScheme.primary : null,
        ),
      ),
      selected: isSelected,
      onTap: () {
        Navigator.of(context).pop();
        if (isSelected) {
          return;
        }
        if (routeName == '/home') {
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else {
          Navigator.of(context).pushNamed(routeName);
        }
      },
    );
  }
}
