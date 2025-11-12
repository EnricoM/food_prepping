import 'dart:async';

import '../inventory_item.dart';
import '../inventory_store.dart';

abstract class InventoryRepository {
  Stream<List<InventoryItem>> watchAll();
  List<InventoryItem> getAll();
  Future<void> addItem(InventoryItem item);
  Future<void> upsertItem({
    required InventoryItem item,
    String? name,
    double? quantity,
    String? unit,
    String? category,
    String? location,
    String? note,
    DateTime? expiry,
    double? costPerUnit,
    bool? isLowStock,
  });
  Future<void> adjustQuantity(InventoryItem item, double delta);
  Future<void> toggleLowStock(InventoryItem item);
  Future<void> remove(InventoryItem item);
  Future<void> clear();
}

class HiveInventoryRepository implements InventoryRepository {
  HiveInventoryRepository({InventoryStore? store})
      : _store = store ?? InventoryStore.instance;

  final InventoryStore _store;

  @override
  Stream<List<InventoryItem>> watchAll() {
    final listenable = _store.listenable();
    return Stream<List<InventoryItem>>.multi((controller) {
      void emit() => controller.add(
            _store.items().toList(growable: false),
          );
      emit();
      void listener() => emit();
      listenable.addListener(listener);
      controller.onCancel = () {
        listenable.removeListener(listener);
      };
    });
  }

  @override
  List<InventoryItem> getAll() => _store.items().toList(growable: false);

  @override
  Future<void> addItem(InventoryItem item) => _store.addItem(item);

  @override
  Future<void> upsertItem({
    required InventoryItem item,
    String? name,
    double? quantity,
    String? unit,
    String? category,
    String? location,
    String? note,
    DateTime? expiry,
    double? costPerUnit,
    bool? isLowStock,
  }) {
    return _store.upsertItem(
      item: item,
      name: name,
      quantity: quantity,
      unit: unit,
      category: category,
      location: location,
      note: note,
      expiry: expiry,
      costPerUnit: costPerUnit,
      isLowStock: isLowStock,
    );
  }

  @override
  Future<void> adjustQuantity(InventoryItem item, double delta) =>
      _store.adjustQuantity(item, delta);

  @override
  Future<void> toggleLowStock(InventoryItem item) =>
      _store.toggleLowStock(item);

  @override
  Future<void> remove(InventoryItem item) => _store.remove(item);

  @override
  Future<void> clear() => _store.clear();
}

