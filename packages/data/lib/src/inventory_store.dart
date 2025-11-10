import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'inventory_item.dart';

class InventoryStore {
  InventoryStore._();

  static const _boxName = 'inventory';
  static InventoryStore? _instance;

  static InventoryStore get instance {
    final instance = _instance;
    if (instance == null) {
      throw StateError('InventoryStore has not been initialized.');
    }
    return instance;
  }

  static Future<void> init() async {
    if (!Hive.isAdapterRegistered(InventoryItemAdapter().typeId)) {
      Hive.registerAdapter(InventoryItemAdapter());
    }
    await Hive.openBox<InventoryItem>(_boxName);
    _instance = InventoryStore._();
  }

  Box<InventoryItem> get _box => Hive.box<InventoryItem>(_boxName);

  ValueListenable<Box<InventoryItem>> listenable() => _box.listenable();

  Iterable<InventoryItem> items() => _box.values;

  Future<void> addItem(InventoryItem item) async {
    await _box.add(item);
  }

  Future<void> upsertItem({
    required InventoryItem item,
    String? name,
    double? quantity,
    String? unit,
    String? category,
    String? location,
    String? note,
    DateTime? expiry,
    bool? isLowStock,
  }) async {
    final updated = item.copyWith(
      name: name,
      quantity: quantity,
      unit: unit,
      category: category,
      location: location,
      note: note,
      expiry: expiry,
      updatedAt: DateTime.now(),
      isLowStock: isLowStock,
    );
    await _box.put(item.key, updated);
  }

  Future<void> adjustQuantity(InventoryItem item, double delta) async {
    final nextQuantity = (item.quantity + delta).clamp(0, double.infinity);
    await upsertItem(item: item, quantity: nextQuantity.toDouble());
  }

  Future<void> toggleLowStock(InventoryItem item) async {
    await upsertItem(item: item, isLowStock: !item.isLowStock);
  }

  Future<void> remove(InventoryItem item) async {
    await _box.delete(item.key);
  }

  Future<void> clear() => _box.clear();
}
