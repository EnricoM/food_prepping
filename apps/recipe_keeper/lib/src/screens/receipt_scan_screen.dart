import 'package:capture/capture.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../i18n/strings.g.dart';
import '../widgets/back_aware_app_bar.dart';

enum ReceiptScanTarget { inventory, shoppingList }

class ReceiptScanScreen extends StatefulWidget {
  const ReceiptScanScreen({super.key, required this.target});

  static const routeName = '/receipt-scan';

  final ReceiptScanTarget target;

  @override
  State<ReceiptScanScreen> createState() => _ReceiptScanScreenState();
}

class _ReceiptScanScreenState extends State<ReceiptScanScreen> {
  final _picker = ImagePicker();
  final _ocrService = ReceiptOcrService();
  final List<_EditableSuggestion> _suggestions = [];
  bool _isLoading = false;
  XFile? _image;
  String? _error;

  @override
  void dispose() {
    for (final suggestion in _suggestions) {
      suggestion.dispose();
    }
    _ocrService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inset = responsivePageInsets(context);
    final title = widget.target == ReceiptScanTarget.inventory
        ? context.t.receiptScan.scanToInventory
        : context.t.receiptScan.scanToShoppingList;

    return Scaffold(
      appBar: BackAwareAppBar(title: Text(context.t.receiptScan.title)),
      body: SafeArea(
        child: Padding(
          padding: inset,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Text(
                context.t.receiptScan.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    onPressed: _isLoading ? null : _capturePhoto,
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: Text(context.t.receiptScan.capturePhoto),
                  ),
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : _pickFromGallery,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: Text(context.t.receiptScan.pickFromGallery),
                  ),
                  if (_image != null)
                    OutlinedButton.icon(
                      onPressed: _isLoading ? null : _clearImage,
                      icon: const Icon(Icons.delete_outline),
                      label: Text(context.t.receiptScan.clearSelection),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (_error != null)
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (_image != null && !_isLoading)
                Expanded(child: _buildReviewList(context))
              else if (_image == null)
                Expanded(
                  child: Center(
                    child: Text(
                      'No receipt scanned yet.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
              if (_suggestions.isNotEmpty && !_isLoading)
                FilledButton.icon(
                  onPressed: _commitSuggestions,
                  icon: const Icon(Icons.playlist_add_check),
                  label: Text(widget.target == ReceiptScanTarget.inventory
                      ? 'Add selected to inventory'
                      : 'Add selected to shopping list'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewList(BuildContext context) {
    if (_suggestions.isEmpty) {
      return Center(
        child: Text(
          'No items detected. Try another photo or adjust lighting.',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      );
    }
    return ListView.builder(
      itemCount: _suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = _suggestions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CheckboxListTile(
                  value: suggestion.selected,
                  onChanged: (value) => setState(() {
                    suggestion.selected = value ?? false;
                  }),
                  title: TextField(
                    controller: suggestion.nameController,
                    decoration: const InputDecoration(labelText: 'Item name'),
                  ),
                  subtitle: Text(
                    'Confidence: ${(suggestion.base.confidence * 100).toStringAsFixed(0)}%',
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: suggestion.quantityController,
                        decoration: const InputDecoration(
                          labelText: 'Quantity',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: suggestion.unitController,
                        decoration:
                            const InputDecoration(labelText: 'Unit (optional)'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: suggestion.priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price (optional)',
                    prefixText: '€ ',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _capturePhoto() async {
    try {
      final captured = await _picker.pickImage(source: ImageSource.camera);
      if (captured == null) return;
      await _processImage(captured);
    } catch (e) {
      setState(() => _error = 'Failed to capture photo: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;
      await _processImage(picked);
    } catch (e) {
      setState(() => _error = 'Failed to pick image: $e');
    }
  }

  Future<void> _processImage(XFile file) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final result = await _ocrService.parseReceipt(file);
      for (final suggestion in _suggestions) {
        suggestion.dispose();
      }
      _suggestions
        ..clear()
        ..addAll(result.map(_EditableSuggestion.fromSuggestion));
      setState(() {
        _image = file;
      });
    } catch (e) {
      setState(() {
        _error = 'Could not read receipt: $e';
        _suggestions.clear();
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _clearImage() {
    for (final suggestion in _suggestions) {
      suggestion.dispose();
    }
    setState(() {
      _image = null;
      _suggestions.clear();
    });
  }

  Future<void> _commitSuggestions() async {
    final selected = _suggestions
        .where((suggestion) => suggestion.selected)
        .where((suggestion) =>
            suggestion.nameController.text.trim().isNotEmpty)
        .toList();
    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.t.receiptScan.selectAtLeastOne)),
      );
      return;
    }

    if (widget.target == ReceiptScanTarget.inventory) {
      for (final entry in selected) {
        final quantity = double.tryParse(
              entry.quantityController.text.trim().replaceAll(',', '.'),
            ) ??
            1;
        await AppRepositories.instance.inventory.addItem(
          InventoryItem(
            name: entry.nameController.text.trim(),
            quantity: quantity,
            unit: entry.unitController.text.trim().isEmpty
                ? null
                : entry.unitController.text.trim(),
            note: entry.priceController.text.trim().isEmpty
                ? null
                : 'Price ${entry.priceController.text.trim()}',
          ),
        );
      }
    } else {
      final items = selected
          .map(
            (entry) => ShoppingListItem(
              ingredient: entry.nameController.text.trim(),
              note: entry.priceController.text.trim().isEmpty
                  ? null
                  : 'Price ${entry.priceController.text.trim()}',
            ),
          )
          .toList(growable: false);
      await AppRepositories.instance.shoppingList.addItems(items);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.target == ReceiptScanTarget.inventory
              ? 'Added ${selected.length} items to inventory.'
              : 'Added ${selected.length} items to shopping list.',
        ),
      ),
    );
    Navigator.of(context).pop();
  }
}

class _EditableSuggestion {
  _EditableSuggestion({
    required this.base,
    required this.selected,
    required this.nameController,
    required this.quantityController,
    required this.unitController,
    required this.priceController,
  });

  final ReceiptItemSuggestion base;
  bool selected;
  final TextEditingController nameController;
  final TextEditingController quantityController;
  final TextEditingController unitController;
  final TextEditingController priceController;

  factory _EditableSuggestion.fromSuggestion(ReceiptItemSuggestion suggestion) {
    return _EditableSuggestion(
      base: suggestion,
      selected: true,
      nameController: TextEditingController(text: suggestion.label),
      quantityController: TextEditingController(
        text: suggestion.quantity?.toString() ?? '',
      ),
      unitController: TextEditingController(text: suggestion.unit ?? ''),
      priceController: TextEditingController(
        text: suggestion.price?.toStringAsFixed(2) ?? '',
      ),
    );
  }

  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    unitController.dispose();
    priceController.dispose();
  }
}
