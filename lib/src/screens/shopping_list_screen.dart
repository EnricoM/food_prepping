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
                  return _ShoppingListTile(item: item);
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
}

enum _AddMenuAction { manual, receipt, barcode }

class _ShoppingListTile extends StatelessWidget {
  const _ShoppingListTile({required this.item});

  final ShoppingListItem item;

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
        onChanged: (value) {
          ShoppingListStore.instance.updateChecked(item, value ?? false);
        },
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
