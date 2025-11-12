import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_ui/shared_ui.dart';

// ignore_for_file: use_build_context_synchronously

import '../navigation/app_drawer.dart';
import 'barcode_scan_screen.dart';
import 'receipt_scan_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  static const routeName = '/inventory';

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  @override
  Widget build(BuildContext context) {
    final inset = responsivePageInsets(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        actions: const [_InventoryMenu()],
      ),
      drawer: const AppDrawer(currentRoute: InventoryScreen.routeName),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMenu(context),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Padding(
          padding: inset,
          child: StreamBuilder<List<InventoryItem>>(
            stream: AppRepositories.instance.inventory.watchAll(),
            builder: (context, snapshot) {
              final items = List<InventoryItem>.from(
                snapshot.data ?? const <InventoryItem>[],
              )
                ..sort((a, b) => a.isLowStock == b.isLowStock
                    ? a.name.toLowerCase().compareTo(b.name.toLowerCase())
                    : (a.isLowStock ? -1 : 1));
              if (items.isEmpty) {
                return const _InventoryEmptyState();
              }
              return ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _InventoryTile(
                    item: item,
                    onEdit: () => _openEditor(context, item: item),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _openEditor(BuildContext context, {InventoryItem? item}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => InventoryEditorSheet(item: item),
    );
  }

  void _showAddMenu(BuildContext context) {
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
          _openEditor(context);
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

class _InventoryTile extends StatelessWidget {
  const _InventoryTile({required this.item, required this.onEdit});

  final InventoryItem item;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expiryText = item.expiry == null
        ? null
        : 'Expires ${DateFormat.yMMMd().format(item.expiry!)}';
    final subtitleParts = <String>[];
    if (item.category?.isNotEmpty ?? false) subtitleParts.add(item.category!);
    if (item.location?.isNotEmpty ?? false) subtitleParts.add(item.location!);
    if (expiryText != null) subtitleParts.add(expiryText);
    final subtitle = subtitleParts.join(' • ');
    final quantityText = item.unit == null || item.unit!.isEmpty
        ? item.quantity.toStringAsFixed(item.quantity.truncateToDouble() ==
                item.quantity
            ? 0
            : 2)
        : '${item.quantity} ${item.unit}';
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
          AppRepositories.instance.inventory.remove(item),
      child: InkWell(
        onTap: onEdit,
        onLongPress: () =>
            AppRepositories.instance.inventory.toggleLowStock(item),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: item.isLowStock
                    ? theme.colorScheme.errorContainer
                    : theme.colorScheme.primaryContainer,
                child: Icon(
                  item.isLowStock
                      ? Icons.warning_amber_rounded
                      : Icons.inventory_2,
                  color: item.isLowStock
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.name,
                      style: theme.textTheme.titleMedium,
                    ),
                    if (subtitle.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          subtitle,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    if (item.note?.isNotEmpty ?? false)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          item.note!,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 160),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          quantityText,
                          style: theme.textTheme.titleMedium,
                        ),
                        if (item.costPerUnit != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            '\$${(item.costPerUnit! * item.quantity).toStringAsFixed(2)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      children: [
                        IconButton(
                          tooltip: 'Decrease quantity',
                          constraints: const BoxConstraints.tightFor(
                            width: 36,
                            height: 36,
                          ),
                          padding: EdgeInsets.zero,
                          iconSize: 20,
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => AppRepositories.instance.inventory
                            .adjustQuantity(item, -1),
                        ),
                        IconButton(
                          tooltip: 'Increase quantity',
                          constraints: const BoxConstraints.tightFor(
                            width: 36,
                            height: 36,
                          ),
                          padding: EdgeInsets.zero,
                          iconSize: 20,
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.add_circle_outline),
                        onPressed: () =>
                            AppRepositories.instance.inventory.adjustQuantity(
                              item,
                              1,
                            ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InventoryEditorSheet extends StatefulWidget {
  const InventoryEditorSheet({super.key, this.item});

  final InventoryItem? item;

  @override
  State<InventoryEditorSheet> createState() => _InventoryEditorSheetState();
}

class _InventoryEditorSheetState extends State<InventoryEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _unitController;
  late final TextEditingController _categoryController;
  late final TextEditingController _locationController;
  late final TextEditingController _noteController;
  late final TextEditingController _costController;
  DateTime? _expiry;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _nameController = TextEditingController(text: item?.name ?? '');
    _quantityController = TextEditingController(
      text: (item?.quantity ?? 1).toString(),
    );
    _unitController = TextEditingController(text: item?.unit ?? '');
    _categoryController = TextEditingController(text: item?.category ?? '');
    _locationController = TextEditingController(text: item?.location ?? '');
    _noteController = TextEditingController(text: item?.note ?? '');
    _costController = TextEditingController(
      text: item?.costPerUnit?.toStringAsFixed(2) ?? '',
    );
    _expiry = item?.expiry;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _categoryController.dispose();
    _locationController.dispose();
    _noteController.dispose();
    _costController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.item == null ? 'Add inventory item' : 'Edit item',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Item name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter quantity';
                        }
                        final number = double.tryParse(value.trim());
                        if (number == null || number <= 0) {
                          return 'Quantity must be positive';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _unitController,
                      decoration: const InputDecoration(
                        labelText: 'Unit (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location (optional)',
                  hintText: 'Fridge, pantry, freezer…',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _costController,
                      decoration: const InputDecoration(
                        labelText: 'Cost per unit (optional)',
                        hintText: 'e.g., 2.50',
                        prefixText: '\$ ',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty) {
                          final number = double.tryParse(value.trim());
                          if (number == null || number < 0) {
                            return 'Cost must be a positive number';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Tooltip(
                    message: 'Suggest cost from default prices',
                    child: OutlinedButton(
                      onPressed: () => _suggestCost(),
                      child: const Icon(Icons.auto_awesome_outlined, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickExpiry,
                      icon: const Icon(Icons.event_outlined),
                      label: Text(
                        _expiry == null
                            ? 'Set expiry'
                            : DateFormat.yMMMd().format(_expiry!),
                      ),
                    ),
                  ),
                  if (_expiry != null) ...[
                    const SizedBox(width: 12),
                    IconButton(
                      tooltip: 'Clear expiry',
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() => _expiry = null),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.save_outlined),
                label: Text(widget.item == null ? 'Add item' : 'Save changes'),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  void _suggestCost() {
    final itemName = _nameController.text.trim();
    if (itemName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an item name first')),
      );
      return;
    }
    
    final suggestedPrice = DefaultIngredientPrices.getPrice(itemName);
    if (suggestedPrice != null) {
      setState(() {
        _costController.text = suggestedPrice.toStringAsFixed(2);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Suggested price: \$${suggestedPrice.toStringAsFixed(2)} per unit'),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No default price available for this item'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _pickExpiry() async {
    final now = DateTime.now();
    final current = _expiry ?? now;
    final selected = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (selected != null) {
      setState(() => _expiry = selected);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final quantity = double.tryParse(_quantityController.text.trim()) ?? 1;
    final costPerUnit = _costController.text.trim().isEmpty
        ? null
        : double.tryParse(_costController.text.trim());
    final item = widget.item;
    if (item == null) {
      await AppRepositories.instance.inventory.addItem(
        InventoryItem(
          name: _nameController.text.trim(),
          quantity: quantity,
          unit: _unitController.text.trim().isEmpty
              ? null
              : _unitController.text.trim(),
          category: _categoryController.text.trim().isEmpty
              ? null
              : _categoryController.text.trim(),
          location: _locationController.text.trim().isEmpty
              ? null
              : _locationController.text.trim(),
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
          expiry: _expiry,
          costPerUnit: costPerUnit,
        ),
      );
    } else {
      await AppRepositories.instance.inventory.upsertItem(
        item: item,
        name: _nameController.text.trim(),
        quantity: quantity,
        unit: _unitController.text.trim().isEmpty
            ? null
            : _unitController.text.trim(),
        category: _categoryController.text.trim().isEmpty
            ? null
            : _categoryController.text.trim(),
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        expiry: _expiry,
        costPerUnit: costPerUnit,
      );
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }
}

class _InventoryMenu extends StatelessWidget {
  const _InventoryMenu();

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_InventoryMenuAction>(
      onSelected: (action) async {
        switch (action) {
          case _InventoryMenuAction.markLowStock:
            final messenger = ScaffoldMessenger.of(context);
            await _markLowStockAll();
            messenger.showSnackBar(
              const SnackBar(content: Text('Marked low stock items.')),
            );
            break;
          case _InventoryMenuAction.clearAll:
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Clear inventory'),
                content: const Text(
                    'Are you sure you want to remove all inventory items?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Clear'),
                  ),
                ],
              ),
            );
            if (confirmed == true) {
              await AppRepositories.instance.inventory.clear();
            }
            break;
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem<_InventoryMenuAction>(
          value: _InventoryMenuAction.markLowStock,
          child: Text('Mark low stock (qty ≤ 1)'),
        ),
        PopupMenuItem<_InventoryMenuAction>(
          value: _InventoryMenuAction.clearAll,
          child: Text('Clear all items'),
        ),
      ],
    );
  }

  Future<void> _markLowStockAll() async {
    final repository = AppRepositories.instance.inventory;
    for (final item in repository.getAll()) {
      if (item.quantity <= 1 && !item.isLowStock) {
        await repository.toggleLowStock(item);
      }
    }
  }
}

enum _InventoryMenuAction { markLowStock, clearAll }

class _InventoryEmptyState extends StatelessWidget {
  const _InventoryEmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No inventory items yet',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add products you have on hand to track what is available.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

enum _InventoryAddAction { manual, receipt, barcode }
