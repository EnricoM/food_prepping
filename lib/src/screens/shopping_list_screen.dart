import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_ui/shared_ui.dart';

import '../navigation/app_drawer.dart';
import 'barcode_scan_screen.dart';
import 'receipt_scan_screen.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  static const routeName = '/shopping-list';

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  @override
  Widget build(BuildContext context) {
    final inset = responsivePageInsets(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping list'),
        actions: const [_ShoppingListMenu()],
      ),
      drawer: const AppDrawer(currentRoute: ShoppingListScreen.routeName),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMenu,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Padding(
          padding: inset,
          child: ValueListenableBuilder<Box<ShoppingListItem>>(
            valueListenable: ShoppingListStore.instance.listenable(),
            builder: (context, box, _) {
              final items = box.values.toList(growable: false)
                ..sort((a, b) => a.isChecked == b.isChecked
                    ? a.addedAt.compareTo(b.addedAt)
                    : (a.isChecked ? 1 : -1));
              if (items.isEmpty) {
                return const _EmptyState();
              }
              return ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _ShoppingListTile(
                    item: item,
                    onToggle: (checked) => _handleToggle(item, checked),
                  );
                },
              );
            },
          ),
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
                        await ShoppingListStore.instance.addItems([
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
    await ShoppingListStore.instance.updateChecked(item, checked);
    if (!checked) {
      return;
    }
    if (!mounted) return;
    final result = await _promptInventoryIntegration(item);
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    if (result is _InventoryAddRecord) {
      await InventoryStore.instance.addItem(
        InventoryItem(
          name: result.name,
          quantity: result.quantity,
          unit: result.unit,
          note: result.note ?? item.note,
        ),
      );
      await ShoppingListStore.instance.remove(item);
      messenger.showSnackBar(
        SnackBar(content: Text('Added ${result.name} to inventory.')),
      );
    } else if (result == _PostCheckAction.remove) {
      await ShoppingListStore.instance.remove(item);
      messenger.showSnackBar(
        SnackBar(content: Text('Removed "${item.ingredient}" from the list.')),
      );
    } else if (result == _PostCheckAction.undo) {
      await ShoppingListStore.instance.updateChecked(item, false);
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
  const _ShoppingListTile({required this.item, required this.onToggle});

  final ShoppingListItem item;
  final ValueChanged<bool> onToggle;

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
      onDismissed: (_) => ShoppingListStore.instance.remove(item),
      child: CheckboxListTile(
        value: item.isChecked,
        onChanged: (value) => onToggle(value ?? false),
        title: Text(item.ingredient),
        subtitle: subtitle.isEmpty ? null : Text(subtitle),
        controlAffinity: ListTileControlAffinity.leading,
        secondary: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () => ShoppingListStore.instance.remove(item),
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
            await ShoppingListStore.instance.clearCompleted();
            messenger.showSnackBar(
              const SnackBar(content: Text('Cleared checked items.')),
            );
            break;
          case _ShoppingMenuAction.clearAll:
            await ShoppingListStore.instance.clearAll();
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
