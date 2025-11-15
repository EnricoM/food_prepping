import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

import '../navigation/app_drawer.dart';
import '../widgets/back_aware_app_bar.dart';
import 'barcode_scan_screen.dart';
import 'receipt_scan_screen.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  static const routeName = '/shopping-list';

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

enum _GroupBy { none, category, recipe, storeLayout }

enum _SortBy { added, alphabetical, category }

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  _GroupBy _groupBy = _GroupBy.category;
  _SortBy _sortBy = _SortBy.category;
  bool _mergeDuplicates = true;

  @override
  Widget build(BuildContext context) {
    final inset = responsivePageInsets(context);
    return Scaffold(
      appBar: const BackAwareAppBar(
        title: Text('Shopping list'),
        actions: [_ShoppingListMenu()],
      ),
      drawer: const AppDrawer(currentRoute: ShoppingListScreen.routeName),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMenu,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _OrganizationControls(
              groupBy: _groupBy,
              sortBy: _sortBy,
              mergeDuplicates: _mergeDuplicates,
              onGroupByChanged: (value) => setState(() => _groupBy = value),
              onSortByChanged: (value) => setState(() => _sortBy = value),
              onMergeDuplicatesChanged: (value) =>
                  setState(() => _mergeDuplicates = value),
            ),
            Expanded(
              child: Padding(
                padding: inset,
                child: StreamBuilder<List<ShoppingListItem>>(
                  stream: AppRepositories.instance.shoppingList.watchAll(),
                  builder: (context, snapshot) {
                    var items = List<ShoppingListItem>.from(
                      snapshot.data ?? const <ShoppingListItem>[],
                    );

                    // Merge duplicates if enabled
                    if (_mergeDuplicates) {
                      items = ShoppingListOrganizer.mergeDuplicates(items);
                    }

                    // Sort items
                    switch (_sortBy) {
                      case _SortBy.category:
                        items = ShoppingListOrganizer.sortByStoreLayout(items);
                        break;
                      case _SortBy.alphabetical:
                        items = ShoppingListOrganizer.sortAlphabetically(items);
                        break;
                      case _SortBy.added:
                        items.sort((a, b) => a.addedAt.compareTo(b.addedAt));
                        break;
                    }

                    // Separate checked and unchecked
                    final unchecked = items.where((i) => !i.isChecked).toList();
                    final checked = items.where((i) => i.isChecked).toList();

                    if (items.isEmpty) {
                      return const _EmptyState();
                    }

                    // Group items based on selected mode
                    switch (_groupBy) {
                      case _GroupBy.category:
                        return _CategoryGroupedView(
                          unchecked: unchecked,
                          checked: checked,
                          onToggle: _handleToggle,
                        );
                      case _GroupBy.recipe:
                        return _RecipeGroupedView(
                          unchecked: unchecked,
                          checked: checked,
                          onToggle: _handleToggle,
                        );
                      case _GroupBy.storeLayout:
                        return _StoreLayoutView(
                          unchecked: unchecked,
                          checked: checked,
                          onToggle: _handleToggle,
                        );
                      case _GroupBy.none:
                        return _SimpleListView(
                          unchecked: unchecked,
                          checked: checked,
                          onToggle: _handleToggle,
                        );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMenu() {
    final navigator = Navigator.of(context);
    showModalBottomSheet<_AddMenuAction>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.add_outlined),
              title: const Text('Add manual item'),
              onTap: () =>
                  Navigator.of(sheetContext).pop(_AddMenuAction.manual),
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: const Text('Scan receipt (batch add)'),
              onTap: () =>
                  Navigator.of(sheetContext).pop(_AddMenuAction.receipt),
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner),
              title: const Text('Scan barcode'),
              onTap: () =>
                  Navigator.of(sheetContext).pop(_AddMenuAction.barcode),
            ),
          ],
        ),
      ),
    ).then((action) async {
      if (!mounted || !navigator.mounted || action == null) {
        return;
      }
      switch (action) {
        case _AddMenuAction.manual:
          await showDialog<void>(
            context: context,
            builder: (dialogCtx) {
              final controller = TextEditingController();
              return AlertDialog(
                title: const Text('Add item'),
                content: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: 'Item name',
                  ),
                  autofocus: true,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogCtx).pop(),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () async {
                      final value = controller.text.trim();
                      if (value.isNotEmpty) {
                        await AppRepositories.instance.shoppingList.addItems([
                          ShoppingListItem(ingredient: value),
                        ]);
                      }
                      if (!dialogCtx.mounted) return;
                      Navigator.of(dialogCtx).pop();
                    },
                    child: const Text('Add'),
                  ),
                ],
              );
            },
          );
          break;
        case _AddMenuAction.receipt:
          navigator.pushNamed(
            ReceiptScanScreen.routeName,
            arguments: ReceiptScanTarget.shoppingList,
          );
          break;
        case _AddMenuAction.barcode:
          navigator.pushNamed(
            BarcodeScanScreen.routeName,
            arguments: BarcodeScanTarget.shoppingList,
          );
          break;
      }
    });
  }

  Future<void> _handleToggle(ShoppingListItem item, bool checked) async {
    await AppRepositories.instance.shoppingList.updateChecked(item, checked);
    if (!checked) {
      return;
    }
    if (!mounted) return;
    final result = await _promptInventoryIntegration(item);
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    if (result is _InventoryAddRecord) {
      await AppRepositories.instance.inventory.addItem(
        InventoryItem(
          name: result.name,
          quantity: result.quantity,
          unit: result.unit,
          note: result.note ?? item.note,
        ),
      );
      await AppRepositories.instance.shoppingList.remove(item);
      messenger.showSnackBar(
        SnackBar(content: Text('Added ${result.name} to inventory.')),
      );
    } else if (result == _PostCheckAction.remove) {
      await AppRepositories.instance.shoppingList.remove(item);
      messenger.showSnackBar(
        SnackBar(
          content: Text('Removed "${item.ingredient}" from the list.'),
        ),
      );
    } else if (result == _PostCheckAction.undo) {
      await AppRepositories.instance.shoppingList.updateChecked(item, false);
    }
  }

  Future<dynamic> _promptInventoryIntegration(ShoppingListItem item) {
    final nameController = TextEditingController(text: item.ingredient);
    final quantityController = TextEditingController(text: '1');
    final unitController = TextEditingController();
    return showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final bottomInset = MediaQuery.of(sheetContext).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: bottomInset + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add to inventory?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Item name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: quantityController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: unitController,
                      decoration: const InputDecoration(
                        labelText: 'Unit (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () {
                  final name = nameController.text.trim().isEmpty
                      ? item.ingredient
                      : nameController.text.trim();
                  final quantity = double.tryParse(
                        quantityController.text
                            .trim()
                            .replaceAll(',', '.'),
                      ) ??
                      1;
                  final unit = unitController.text.trim().isEmpty
                      ? null
                      : unitController.text.trim();
                  Navigator.of(sheetContext).pop(
                    _InventoryAddRecord(
                      name: name,
                      quantity: quantity,
                      unit: unit,
                      note: item.note,
                    ),
                  );
                },
                icon: const Icon(Icons.inventory_2_outlined),
                label: const Text('Add to inventory & remove'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(sheetContext)
                    .pop(_PostCheckAction.remove),
                icon: const Icon(Icons.remove_circle_outline),
                label: const Text('Remove from list'),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.of(sheetContext).pop(_PostCheckAction.keep),
                child: const Text('Keep checked'),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.of(sheetContext).pop(_PostCheckAction.undo),
                child: const Text('Undo check'),
              ),
            ],
          ),
        );
      },
    );
  }
}

enum _AddMenuAction { manual, receipt, barcode }

enum _PostCheckAction { keep, remove, undo }

class _InventoryAddRecord {
  _InventoryAddRecord({
    required this.name,
    required this.quantity,
    this.unit,
    this.note,
  });

  final String name;
  final double quantity;
  final String? unit;
  final String? note;
}

class _ShoppingListTile extends StatelessWidget {
  const _ShoppingListTile({
    required this.item,
    required this.onToggle,
    this.showCategory = false,
  });

  final ShoppingListItem item;
  final ValueChanged<bool> onToggle;
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
      key: ValueKey(item.key),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        color: theme.colorScheme.errorContainer,
        child: Icon(Icons.delete_outline, color: theme.colorScheme.error),
      ),
      onDismissed: (_) =>
          AppRepositories.instance.shoppingList.remove(item),
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
          onPressed: () =>
              AppRepositories.instance.shoppingList.remove(item),
        ),
      ),
    );
  }
}

class _OrganizationControls extends StatelessWidget {
  const _OrganizationControls({
    required this.groupBy,
    required this.sortBy,
    required this.mergeDuplicates,
    required this.onGroupByChanged,
    required this.onSortByChanged,
    required this.onMergeDuplicatesChanged,
  });

  final _GroupBy groupBy;
  final _SortBy sortBy;
  final bool mergeDuplicates;
  final ValueChanged<_GroupBy> onGroupByChanged;
  final ValueChanged<_SortBy> onSortByChanged;
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
                      SegmentedButton<_GroupBy>(
                        segments: const [
                          ButtonSegment(
                            value: _GroupBy.none,
                            label: Text('None'),
                            tooltip: 'No grouping',
                          ),
                          ButtonSegment(
                            value: _GroupBy.category,
                            label: Text('Category'),
                            tooltip: 'Group by store category',
                          ),
                          ButtonSegment(
                            value: _GroupBy.recipe,
                            label: Text('Recipe'),
                            tooltip: 'Group by recipe',
                          ),
                          ButtonSegment(
                            value: _GroupBy.storeLayout,
                            label: Text('Store'),
                            tooltip: 'Group by store layout',
                          ),
                        ],
                        selected: {groupBy},
                        onSelectionChanged: (Set<_GroupBy> selected) {
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

class _ShoppingListMenu extends StatelessWidget {
  const _ShoppingListMenu();

  @override
  Widget build(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    return PopupMenuButton<_ShoppingMenuAction>(
      onSelected: (action) async {
        switch (action) {
          case _ShoppingMenuAction.clearChecked:
            await AppRepositories.instance.shoppingList.clearCompleted();
            messenger.showSnackBar(
              const SnackBar(content: Text('Cleared checked items.')),
            );
            break;
          case _ShoppingMenuAction.clearAll:
            await AppRepositories.instance.shoppingList.clearAll();
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
class _CategoryGroupedView extends StatelessWidget {
  const _CategoryGroupedView({
    required this.unchecked,
    required this.checked,
    required this.onToggle,
  });

  final List<ShoppingListItem> unchecked;
  final List<ShoppingListItem> checked;
  final void Function(ShoppingListItem, bool) onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uncheckedGrouped =
        ShoppingListOrganizer.groupByCategory(unchecked);
    final checkedGrouped = ShoppingListOrganizer.groupByCategory(checked);

    return ListView(
      children: [
        // Unchecked items grouped by category
        ...uncheckedGrouped.entries
            .map((entry) => _CategorySection(
                  category: entry.key,
                  items: entry.value,
                  onToggle: onToggle,
                ))
            .toList(),
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
          ...checkedGrouped.entries
              .map((entry) => _CategorySection(
                    category: entry.key,
                    items: entry.value,
                    onToggle: onToggle,
                    isChecked: true,
                  ))
              .toList(),
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
    this.isChecked = false,
  });

  final ShoppingCategory category;
  final List<ShoppingListItem> items;
  final void Function(ShoppingListItem, bool) onToggle;
  final bool isChecked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (items.isEmpty) return const SizedBox.shrink();

    // Sort items alphabetically within category
    final sorted = List<ShoppingListItem>.from(items)
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
              showCategory: false,
            )),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _RecipeGroupedView extends StatelessWidget {
  const _RecipeGroupedView({
    required this.unchecked,
    required this.checked,
    required this.onToggle,
  });

  final List<ShoppingListItem> unchecked;
  final List<ShoppingListItem> checked;
  final void Function(ShoppingListItem, bool) onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uncheckedGrouped = ShoppingListOrganizer.groupByRecipe(unchecked);
    final checkedGrouped = ShoppingListOrganizer.groupByRecipe(checked);

    return ListView(
      children: [
        ...uncheckedGrouped.entries.map((entry) => _RecipeSection(
              recipeTitle: entry.key,
              items: entry.value,
              onToggle: onToggle,
            )),
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
          ...checkedGrouped.entries.map((entry) => _RecipeSection(
                recipeTitle: entry.key,
                items: entry.value,
                onToggle: onToggle,
                isChecked: true,
              )),
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
    this.isChecked = false,
  });

  final String recipeTitle;
  final List<ShoppingListItem> items;
  final void Function(ShoppingListItem, bool) onToggle;
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
              showCategory: false,
            )),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _StoreLayoutView extends StatelessWidget {
  const _StoreLayoutView({
    required this.unchecked,
    required this.checked,
    required this.onToggle,
  });

  final List<ShoppingListItem> unchecked;
  final List<ShoppingListItem> checked;
  final void Function(ShoppingListItem, bool) onToggle;

  @override
  Widget build(BuildContext context) {
    // Sort by store layout order
    final sortedUnchecked =
        ShoppingListOrganizer.sortByStoreLayout(unchecked);
    final sortedChecked = ShoppingListOrganizer.sortByStoreLayout(checked);

    return _SimpleListView(
      unchecked: sortedUnchecked,
      checked: sortedChecked,
      onToggle: onToggle,
    );
  }
}

class _SimpleListView extends StatelessWidget {
  const _SimpleListView({
    required this.unchecked,
    required this.checked,
    required this.onToggle,
  });

  final List<ShoppingListItem> unchecked;
  final List<ShoppingListItem> checked;
  final void Function(ShoppingListItem, bool) onToggle;

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
          showCategory: true,
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

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
