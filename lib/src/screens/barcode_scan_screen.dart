import 'dart:math' as math;

import 'package:capture/capture.dart';
import 'package:data/data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_ui/shared_ui.dart';

enum BarcodeScanTarget { inventory, shoppingList }

class BarcodeScanScreen extends StatefulWidget {
  const BarcodeScanScreen({super.key, required this.target});

  static const routeName = '/barcode-scan';

  final BarcodeScanTarget target;

  @override
  State<BarcodeScanScreen> createState() => _BarcodeScanScreenState();
}

class _BarcodeScanScreenState extends State<BarcodeScanScreen> {
  final _controller = MobileScannerController(returnImage: true);
  final _lookupService = BarcodeLookupService();
  BarcodeProduct? _product;
  String? _error;
  bool _isProcessing = false;

  bool get _isScanningSupported {
    if (kIsWeb) return false;
    const supportedPlatforms = {
      TargetPlatform.android,
      TargetPlatform.iOS,
      TargetPlatform.macOS,
    };
    return supportedPlatforms.contains(defaultTargetPlatform);
  }

  @override
  void dispose() {
    _controller.dispose();
    _lookupService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inset = responsivePageInsets(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Barcode scanner')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (!_isScanningSupported) {
              return Padding(
                padding: inset,
                child: _UnsupportedScanner(target: widget.target),
              );
            }

            final previewHeight = math.max(
              240.0,
              math.min(constraints.maxHeight * 0.6, 480.0),
            );

            return SingleChildScrollView(
              padding: inset,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: previewHeight,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: MobileScanner(
                          controller: _controller,
                          onDetect: _handleDetection,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_isProcessing)
                    const Center(child: CircularProgressIndicator())
                  else if (_product != null)
                    _ProductPreview(
                      product: _product!,
                      onAdd: _addProduct,
                      target: widget.target,
                    )
                  else if (_error != null)
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    )
                  else
                    Text(
                      'Align the barcode within the frame. Detected items will appear below.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () async {
                      await _controller.stop();
                      await _controller.start();
                      setState(() {
                        _product = null;
                        _error = null;
                      });
                    },
                    icon: const Icon(Icons.refresh_outlined),
                    label: const Text('Rescan'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleDetection(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final value = barcodes.first.rawValue;
    if (value == null || value.length < 6) {
      return;
    }
    setState(() {
      _isProcessing = true;
      _error = null;
    });
    try {
      await _controller.stop();
      final product = await _lookupService.lookup(value);
      if (!mounted) return;
      if (product == null) {
        setState(() {
          _error = 'No product found for $value. Try again or add manually.';
          _product = null;
        });
      } else {
        setState(() {
          _product = product;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Lookup failed: $e';
        _product = null;
      });
      await _controller.start();
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _addProduct(BarcodeProduct product) async {
    if (widget.target == BarcodeScanTarget.inventory) {
      await AppRepositories.instance.inventory.addItem(
        InventoryItem(
          name: product.displayTitle,
          quantity: 1,
          unit: product.quantity,
          note: product.categories?.isNotEmpty == true
              ? 'Categories: ${product.categories!.take(3).join(', ')}'
              : null,
        ),
      );
    } else {
      await AppRepositories.instance.shoppingList.addItems([
        ShoppingListItem(
          ingredient: product.displayTitle,
          note: product.quantity,
        ),
      ]);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.target == BarcodeScanTarget.inventory
              ? 'Added ${product.displayTitle} to inventory.'
              : 'Added ${product.displayTitle} to shopping list.',
        ),
      ),
    );
    Navigator.of(context).pop();
  }
}

class _ProductPreview extends StatelessWidget {
  const _ProductPreview({
    required this.product,
    required this.onAdd,
    required this.target,
  });

  final BarcodeProduct product;
  final ValueChanged<BarcodeProduct> onAdd;
  final BarcodeScanTarget target;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.displayTitle, style: theme.textTheme.titleMedium),
            if (product.quantity?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('Quantity: ${product.quantity}'),
              ),
            if (product.categories?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Categories: ${product.categories!.take(4).join(', ')}',
                ),
              ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => onAdd(product),
              icon: const Icon(Icons.add_circle_outline),
              label: Text(target == BarcodeScanTarget.inventory
                  ? 'Add to inventory'
                  : 'Add to shopping list'),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnsupportedScanner extends StatelessWidget {
  const _UnsupportedScanner({required this.target});

  final BarcodeScanTarget target;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_amber_outlined, size: 56, color: Colors.orange),
          const SizedBox(height: 16),
          Text(
            'Barcode scanning requires a mobile device camera.',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Open this feature on Android or iOS to scan barcodes and add items '
            'to your ${target == BarcodeScanTarget.inventory ? 'inventory' : 'shopping list'}.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
