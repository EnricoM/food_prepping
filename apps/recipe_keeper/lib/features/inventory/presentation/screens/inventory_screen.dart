import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../../../app/di.dart';
import '../../../../src/navigation/app_drawer.dart';
import '../../../../src/widgets/back_aware_app_bar.dart';
import '../../../../src/screens/barcode_scan_screen.dart';
import '../../../../src/screens/receipt_scan_screen.dart';
import '../../domain/models/inventory_item_model.dart';
import '../controllers/inventory_controller.dart';
import 'widgets/inventory_widgets.dart' as widgets;

/// Screen for managing inventory
/// 
/// Uses Riverpod for state management and the new InventoryController.
class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  static const routeName = '/inventory';

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  @override
  Widget build(BuildContext context) {
    final inset = responsivePageInsets(context);
    final state = ref.watch(inventoryControllerProvider);
    final controller = ref.watch(inventoryControllerProvider.notifier);

    return Scaffold(
      appBar: const BackAwareAppBar(
        title: Text('Inventory'),
        actions: [widgets.InventoryMenu()],
      ),
      drawer: const AppDrawer(currentRoute: InventoryScreen.routeName),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMenu(context, controller),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Padding(
          padding: inset,
          child: _buildContent(state, controller),
        ),
      ),
    );
  }

  Widget _buildContent(InventoryState state, InventoryController controller) {
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
                'Error loading inventory',
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

    final items = controller.organizedItems;
    if (items.isEmpty) {
      return const widgets.InventoryEmptyState();
    }

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = items[index];
        return widgets.InventoryTile(
          item: item,
          onEdit: () => _openEditor(context, controller, item: item),
          onRemove: () => controller.remove(item),
          onToggleLowStock: () => controller.toggleLowStock(item),
          onDecreaseQuantity: () => controller.adjustQuantity(item, -1),
          onIncreaseQuantity: () => controller.adjustQuantity(item, 1),
        );
      },
    );
  }

  Future<void> _openEditor(
    BuildContext context,
    InventoryController controller, {
    InventoryItemModel? item,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => widgets.InventoryEditorSheet(
        item: item,
        controller: controller,
      ),
    );
  }

  void _showAddMenu(BuildContext context, InventoryController controller) {
    final navigator = Navigator.of(context);
    showModalBottomSheet<_InventoryAddAction>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit_note_outlined),
              title: const Text('Add item manually'),
              onTap: () =>
                  Navigator.of(sheetContext).pop(_InventoryAddAction.manual),
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: const Text('Scan receipt (batch add)'),
              onTap: () =>
                  Navigator.of(sheetContext).pop(_InventoryAddAction.receipt),
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner),
              title: const Text('Scan barcode'),
              onTap: () =>
                  Navigator.of(sheetContext).pop(_InventoryAddAction.barcode),
            ),
          ],
        ),
      ),
    ).then((action) {
      if (!mounted || !navigator.mounted || action == null) {
        return;
      }
      switch (action) {
        case _InventoryAddAction.manual:
          _openEditor(context, controller);
          break;
        case _InventoryAddAction.receipt:
          navigator.pushNamed(
            ReceiptScanScreen.routeName,
            arguments: ReceiptScanTarget.inventory,
          );
          break;
        case _InventoryAddAction.barcode:
          navigator.pushNamed(
            BarcodeScanScreen.routeName,
            arguments: BarcodeScanTarget.inventory,
          );
          break;
      }
    });
  }
}

enum _InventoryAddAction { manual, receipt, barcode }

