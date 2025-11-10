import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, required this.currentRoute});

  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    final entries = _DrawerEntry.entries;
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const _DrawerHeader(),
            for (final entry in entries)
              _DrawerTile(
                icon: entry.icon,
                label: entry.label,
                routeName: entry.routeName,
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

  static final entries = <_DrawerEntry>[
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
      icon: Icons.inventory_2_outlined,
      label: 'Inventory',
      routeName: '/inventory',
    ),
    const _DrawerEntry(
      icon: Icons.shopping_cart_outlined,
      label: 'Shopping list',
      routeName: '/shopping-list',
    ),
    const _DrawerEntry(
      icon: Icons.calendar_month_outlined,
      label: 'Meal planner',
      routeName: '/meal-plan',
    ),
    const _DrawerEntry(
      icon: Icons.history,
      label: 'Recently added',
      routeName: '/recent',
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
      icon: Icons.explore_outlined,
      label: 'Discover domain',
      routeName: '/discover',
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
        if (!isSelected) {
          Navigator.of(context).pushReplacementNamed(routeName);
        }
      },
    );
  }
}
