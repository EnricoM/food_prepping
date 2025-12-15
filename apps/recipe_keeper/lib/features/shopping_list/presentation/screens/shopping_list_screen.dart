import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../../../app/di.dart';
import '../../../../src/navigation/app_drawer.dart';
import '../../../../src/widgets/back_aware_app_bar.dart';
import '../../../../src/screens/barcode_scan_screen.dart';
import '../../../../src/screens/receipt_scan_screen.dart';
import '../../domain/models/shopping_list_item_model.dart';
import '../controllers/shopping_list_controller.dart';
import '../models/shopping_list_enums.dart';
import 'widgets/shopping_list_widgets.dart' as widgets;

/// Screen for managing the shopping list
/// 
/// Uses Riverpod for state management and the new ShoppingListController.
class ShoppingListScreen extends ConsumerStatefulWidget {
  const ShoppingListScreen({super.key});

  static const routeName = '/shopping-list';

  @override
  ConsumerState<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends ConsumerState<ShoppingListScreen> {
  ShoppingListGroupBy _groupBy = ShoppingListGroupBy.category;
  ShoppingListSortBy _sortBy = ShoppingListSortBy.category;
  bool _mergeDuplicates = true;

  @override
  Widget build(BuildContext context) {
    final inset = responsivePageInsets(context);
    final state = ref.watch(shoppingListControllerProvider);
    final controller = ref.watch(shoppingListControllerProvider.notifier);

    return Scaffold(
      appBar: const BackAwareAppBar(
        title: Text('Shopping list'),
        actions: [widgets.ShoppingListMenu()],
      ),
      drawer: const AppDrawer(currentRoute: ShoppingListScreen.routeName),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMenu,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
            widgets.ShoppingListOrganizationControls(
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
                child: _buildContent(state, controller),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ShoppingListState state, ShoppingListController controller) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
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
                'Error loading shopping list',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                state.error!,
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

    var items = List<ShoppingListItemModel>.from(state.items);

    // Merge duplicates if enabled
    if (_mergeDuplicates) {
      items = controller.mergeDuplicates(items);
    }

    // Sort items
    switch (_sortBy) {
      case ShoppingListSortBy.category:
        items = controller.sortByStoreLayout(items);
        break;
      case ShoppingListSortBy.alphabetical:
        items = controller.sortAlphabetically(items);
        break;
      case ShoppingListSortBy.added:
        items.sort((a, b) => a.addedAt.compareTo(b.addedAt));
        break;
    }

    // Separate checked and unchecked
    final unchecked = items.where((i) => !i.isChecked).toList();
    final checked = items.where((i) => i.isChecked).toList();

    if (items.isEmpty) {
      return const widgets.EmptyState();
    }

    // Group items based on selected mode
    switch (_groupBy) {
      case ShoppingListGroupBy.category:
        return widgets.CategoryGroupedView(
          unchecked: unchecked,
          checked: checked,
          onToggle: (item, checked) => controller.updateChecked(item, checked),
          onRemove: (item) => controller.remove(item),
        );
      case ShoppingListGroupBy.recipe:
        return widgets.RecipeGroupedView(
          unchecked: unchecked,
          checked: checked,
          onToggle: (item, checked) => controller.updateChecked(item, checked),
          onRemove: (item) => controller.remove(item),
        );
      case ShoppingListGroupBy.storeLayout:
        return widgets.StoreLayoutView(
          unchecked: unchecked,
          checked: checked,
          onToggle: (item, checked) => controller.updateChecked(item, checked),
          onRemove: (item) => controller.remove(item),
        );
      case ShoppingListGroupBy.none:
        return widgets.SimpleListView(
          unchecked: unchecked,
          checked: checked,
          onToggle: (item, checked) => controller.updateChecked(item, checked),
          onRemove: (item) => controller.remove(item),
        );
    }
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
          await _showAddManualDialog();
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

  Future<void> _showAddManualDialog() async {
    final controller = ref.read(shoppingListControllerProvider.notifier);
    final textController = TextEditingController();
    
    await showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('Add item'),
          content: TextField(
            controller: textController,
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
                final value = textController.text.trim();
                if (value.isNotEmpty) {
                  final item = ShoppingListItemModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    ingredient: value,
                    addedAt: DateTime.now(),
                  );
                  await controller.addItems([item]);
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
  }

  // TODO: Re-implement inventory integration when Inventory feature is migrated
  // The inventory prompt functionality will be restored when InventoryRepository is available
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

// Widget implementations are in shopping_list_widgets.dart

