import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../app/di.dart';
import '../../../domain/models/shopping_list_item_model.dart';
import '../../models/shopping_list_enums.dart';

/// Helper to convert ShoppingListItemModel to ShoppingListItem for ShoppingListOrganizer
ShoppingListItem _toEntity(ShoppingListItemModel model) {
  return ShoppingListItem(
    ingredient: model.ingredient,
    note: model.note,
    recipeTitle: model.recipeTitle,
    recipeUrl: model.recipeUrl,
    addedAt: model.addedAt,
    isChecked: model.isChecked,
  );
}


class _ShoppingListTile extends StatelessWidget {
  const _ShoppingListTile({
    required this.item,
    required this.onToggle,
    required this.onRemove,
    this.showCategory = false,
  });

  final ShoppingListItemModel item;
  final ValueChanged<bool> onToggle;
  final VoidCallback onRemove;
  final bool showCategory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitleParts = <String>[];
    if (item.recipeTitle != null && item.recipeTitle!.isNotEmpty) {
      subtitleParts.add(item.recipeTitle!);
    }
    if (item.note != null && item.note!.isNotEmpty) {
      subtitleParts.add(item.note!);
    }
    final subtitle = subtitleParts.join(' • ');
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        color: theme.colorScheme.errorContainer,
        child: Icon(Icons.delete_outline, color: theme.colorScheme.error),
      ),
      onDismissed: (_) => onRemove(),
      child: CheckboxListTile(
        value: item.isChecked,
        onChanged: (value) => onToggle(value ?? false),
        title: Row(
          children: [
            if (showCategory) ...[
              Text(
                ShoppingListOrganizer.getCategoryIcon(
                  ShoppingListOrganizer.categorizeIngredient(item.ingredient),
                ),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(child: Text(item.ingredient)),
          ],
        ),
        subtitle: subtitle.isEmpty ? null : Text(subtitle),
        controlAffinity: ListTileControlAffinity.leading,
        secondary: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: onRemove,
        ),
      ),
    );
  }
}

class ShoppingListOrganizationControls extends StatelessWidget {
  const ShoppingListOrganizationControls({
    required this.groupBy,
    required this.sortBy,
    required this.mergeDuplicates,
    required this.onGroupByChanged,
    required this.onSortByChanged,
    required this.onMergeDuplicatesChanged,
  });

  final ShoppingListGroupBy groupBy;
  final ShoppingListSortBy sortBy;
  final bool mergeDuplicates;
  final ValueChanged<ShoppingListGroupBy> onGroupByChanged;
  final ValueChanged<ShoppingListSortBy> onSortByChanged;
  final ValueChanged<bool> onMergeDuplicatesChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.tune, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Organization',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Group by',
                        style: theme.textTheme.labelSmall,
                      ),
                      const SizedBox(height: 4),
                      SegmentedButton<ShoppingListGroupBy>(
                        segments: const [
                          ButtonSegment(
                            value: ShoppingListGroupBy.none,
                            label: Text('None'),
                            tooltip: 'No grouping',
                          ),
                          ButtonSegment(
                            value: ShoppingListGroupBy.category,
                            label: Text('Category'),
                            tooltip: 'Group by store category',
                          ),
                          ButtonSegment(
                            value: ShoppingListGroupBy.recipe,
                            label: Text('Recipe'),
                            tooltip: 'Group by recipe',
                          ),
                          ButtonSegment(
                            value: ShoppingListGroupBy.storeLayout,
                            label: Text('Store'),
                            tooltip: 'Group by store layout',
                          ),
                        ],
                        selected: {groupBy},
                        onSelectionChanged: (Set<ShoppingListGroupBy> selected) {
                          onGroupByChanged(selected.first);
                        },
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
                  child: Row(
                    children: [
                      Checkbox(
                        value: mergeDuplicates,
                        onChanged: (value) =>
                            onMergeDuplicatesChanged(value ?? false),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              onMergeDuplicatesChanged(!mergeDuplicates),
                          child: Text(
                            'Merge duplicates',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ShoppingListMenu extends ConsumerWidget {
  const ShoppingListMenu();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messenger = ScaffoldMessenger.of(context);
    final controller = ref.read(shoppingListControllerProvider.notifier);
    return PopupMenuButton<_ShoppingMenuAction>(
      onSelected: (action) async {
        switch (action) {
          case _ShoppingMenuAction.clearChecked:
            await controller.clearCompleted();
            messenger.showSnackBar(
              const SnackBar(content: Text('Cleared checked items.')),
            );
            break;
          case _ShoppingMenuAction.clearAll:
            await controller.clearAll();
            messenger.showSnackBar(
              const SnackBar(content: Text('Shopping list cleared.')),
            );
            break;
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem<_ShoppingMenuAction>(
          value: _ShoppingMenuAction.clearChecked,
          child: Text('Clear checked items'),
        ),
        PopupMenuItem<_ShoppingMenuAction>(
          value: _ShoppingMenuAction.clearAll,
          child: Text('Clear all items'),
        ),
      ],
    );
  }
}

enum _ShoppingMenuAction { clearChecked, clearAll }

// Grouped view implementations
class CategoryGroupedView extends StatelessWidget {
  const CategoryGroupedView({
    required this.unchecked,
    required this.checked,
    required this.onToggle,
    required this.onRemove,
  });

  final List<ShoppingListItemModel> unchecked;
  final List<ShoppingListItemModel> checked;
  final void Function(ShoppingListItemModel, bool) onToggle;
  final void Function(ShoppingListItemModel) onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Convert to entities for grouping
    final uncheckedEntities = unchecked.map(_toEntity).toList();
    final checkedEntities = checked.map(_toEntity).toList();
    final uncheckedGrouped = ShoppingListOrganizer.groupByCategory(uncheckedEntities);
    final checkedGrouped = ShoppingListOrganizer.groupByCategory(checkedEntities);

    return ListView(
      children: [
        // Unchecked items grouped by category
        ...uncheckedGrouped.entries.map(
          (entry) {
            // Convert back to models
            final models = entry.value.map((e) {
              final model = unchecked.firstWhere(
                (m) => m.ingredient.toLowerCase() == e.ingredient.toLowerCase(),
              );
              return model;
            }).toList();
            return _CategorySection(
              category: entry.key,
              items: models,
              onToggle: onToggle,
              onRemove: onRemove,
            );
          },
        ),
        if (checked.isNotEmpty) ...[
          const Divider(height: 32),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Completed',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          ...checkedGrouped.entries.map(
            (entry) {
              final models = entry.value.map((e) {
                final model = checked.firstWhere(
                  (m) => m.ingredient.toLowerCase() == e.ingredient.toLowerCase(),
                );
                return model;
              }).toList();
              return _CategorySection(
                category: entry.key,
                items: models,
                onToggle: onToggle,
                onRemove: onRemove,
                isChecked: true,
              );
            },
          ),
        ],
      ],
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.category,
    required this.items,
    required this.onToggle,
    required this.onRemove,
    this.isChecked = false,
  });

  final ShoppingCategory category;
  final List<ShoppingListItemModel> items;
  final void Function(ShoppingListItemModel, bool) onToggle;
  final void Function(ShoppingListItemModel) onRemove;
  final bool isChecked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (items.isEmpty) return const SizedBox.shrink();

    // Sort items alphabetically within category
    final sorted = List<ShoppingListItemModel>.from(items)
      ..sort((a, b) =>
          a.ingredient.toLowerCase().compareTo(b.ingredient.toLowerCase()));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Text(
                ShoppingListOrganizer.getCategoryIcon(category),
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Text(
                ShoppingListOrganizer.getCategoryName(category),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isChecked
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                      : theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Chip(
                label: Text('${items.length}'),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
        ...sorted.map((item) => _ShoppingListTile(
              item: item,
              onToggle: (checked) => onToggle(item, checked),
              onRemove: () => onRemove(item),
              showCategory: false,
            )),
        const SizedBox(height: 8),
      ],
    );
  }
}

class RecipeGroupedView extends StatelessWidget {
  const RecipeGroupedView({
    required this.unchecked,
    required this.checked,
    required this.onToggle,
    required this.onRemove,
  });

  final List<ShoppingListItemModel> unchecked;
  final List<ShoppingListItemModel> checked;
  final void Function(ShoppingListItemModel, bool) onToggle;
  final void Function(ShoppingListItemModel) onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uncheckedEntities = unchecked.map(_toEntity).toList();
    final checkedEntities = checked.map(_toEntity).toList();
    final uncheckedGrouped = ShoppingListOrganizer.groupByRecipe(uncheckedEntities);
    final checkedGrouped = ShoppingListOrganizer.groupByRecipe(checkedEntities);

    return ListView(
      children: [
        ...uncheckedGrouped.entries.map((entry) {
          final models = entry.value.map((e) {
            return unchecked.firstWhere(
              (m) => m.ingredient.toLowerCase() == e.ingredient.toLowerCase() &&
                  (m.recipeTitle ?? '') == (e.recipeTitle ?? ''),
            );
          }).toList();
          return _RecipeSection(
            recipeTitle: entry.key,
            items: models,
            onToggle: onToggle,
            onRemove: onRemove,
          );
        }),
        if (checked.isNotEmpty) ...[
          const Divider(height: 32),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Completed',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          ...checkedGrouped.entries.map((entry) {
            final models = entry.value.map((e) {
              return checked.firstWhere(
                (m) => m.ingredient.toLowerCase() == e.ingredient.toLowerCase() &&
                    (m.recipeTitle ?? '') == (e.recipeTitle ?? ''),
              );
            }).toList();
            return _RecipeSection(
              recipeTitle: entry.key,
              items: models,
              onToggle: onToggle,
              onRemove: onRemove,
              isChecked: true,
            );
          }),
        ],
      ],
    );
  }
}

class _RecipeSection extends StatelessWidget {
  const _RecipeSection({
    required this.recipeTitle,
    required this.items,
    required this.onToggle,
    required this.onRemove,
    this.isChecked = false,
  });

  final String recipeTitle;
  final List<ShoppingListItemModel> items;
  final void Function(ShoppingListItemModel, bool) onToggle;
  final void Function(ShoppingListItemModel) onRemove;
  final bool isChecked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Icon(
                Icons.restaurant_menu,
                size: 20,
                color: isChecked
                    ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                    : theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  recipeTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isChecked
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                        : theme.colorScheme.primary,
                  ),
                ),
              ),
              Chip(
                label: Text('${items.length}'),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
        ...items.map((item) => _ShoppingListTile(
              item: item,
              onToggle: (checked) => onToggle(item, checked),
              onRemove: () => onRemove(item),
              showCategory: false,
            )),
        const SizedBox(height: 8),
      ],
    );
  }
}

class StoreLayoutView extends StatelessWidget {
  const StoreLayoutView({
    required this.unchecked,
    required this.checked,
    required this.onToggle,
    required this.onRemove,
  });

  final List<ShoppingListItemModel> unchecked;
  final List<ShoppingListItemModel> checked;
  final void Function(ShoppingListItemModel, bool) onToggle;
  final void Function(ShoppingListItemModel) onRemove;

  @override
  Widget build(BuildContext context) {
    // Sort by store layout order
    final uncheckedEntities = unchecked.map(_toEntity).toList();
    final checkedEntities = checked.map(_toEntity).toList();
    final sortedUnchecked = ShoppingListOrganizer.sortByStoreLayout(uncheckedEntities);
    final sortedChecked = ShoppingListOrganizer.sortByStoreLayout(checkedEntities);
    
    // Convert back to models maintaining order
    final sortedUncheckedModels = sortedUnchecked.map((e) {
      return unchecked.firstWhere(
        (m) => m.ingredient.toLowerCase() == e.ingredient.toLowerCase(),
      );
    }).toList();
    final sortedCheckedModels = sortedChecked.map((e) {
      return checked.firstWhere(
        (m) => m.ingredient.toLowerCase() == e.ingredient.toLowerCase(),
      );
    }).toList();

    return SimpleListView(
      unchecked: sortedUncheckedModels,
      checked: sortedCheckedModels,
      onToggle: onToggle,
      onRemove: onRemove,
    );
  }
}

class SimpleListView extends StatelessWidget {
  const SimpleListView({
    required this.unchecked,
    required this.checked,
    required this.onToggle,
    required this.onRemove,
  });

  final List<ShoppingListItemModel> unchecked;
  final List<ShoppingListItemModel> checked;
  final void Function(ShoppingListItemModel, bool) onToggle;
  final void Function(ShoppingListItemModel) onRemove;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: unchecked.length + (checked.isEmpty ? 0 : checked.length + 1),
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        if (index < unchecked.length) {
          return _ShoppingListTile(
            item: unchecked[index],
            onToggle: (checked) => onToggle(unchecked[index], checked),
            onRemove: () => onRemove(unchecked[index]),
            showCategory: true,
          );
        }
        if (index == unchecked.length && checked.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Completed',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
            ),
          );
        }
        final checkedIndex = index - unchecked.length - 1;
        return _ShoppingListTile(
          item: checked[checkedIndex],
          onToggle: (checked) => onToggle(this.checked[checkedIndex], checked),
          onRemove: () => onRemove(checked[checkedIndex]),
          showCategory: true,
        );
      },
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.shopping_bag_outlined, size: 48, color: Colors.black26),
          SizedBox(height: 12),
          Text('Your shopping list is empty for now.'),
          SizedBox(height: 8),
          Text('Add ingredients from the meal planner or recipe details.'),
        ],
      ),
    );
  }
}

