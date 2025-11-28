import 'package:data/data.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/models/inventory_item_model.dart';

/// Data source for inventory items
///
/// This adapts the existing InventoryStore to work with the new InventoryItemModel.
class InventoryDataSource {
  InventoryDataSource({InventoryStore? store})
      : _store = store ?? InventoryStore.instance;

  final InventoryStore _store;

  ValueListenable<Box<InventoryItem>> get listenable => _store.listenable();

  /// Convert InventoryItem to InventoryItemModel
  InventoryItemModel toModel(InventoryItem entity) {
    return InventoryItemModel(
      id: entity.key.toString(), // Use Hive key as ID
      name: entity.name,
      quantity: entity.quantity,
      unit: entity.unit,
      category: entity.category,
      location: entity.location,
      note: entity.note,
      expiry: entity.expiry,
      costPerUnit: entity.costPerUnit,
      addedAt: entity.addedAt,
      updatedAt: entity.updatedAt,
      isLowStock: entity.isLowStock,
    );
  }

  /// Convert InventoryItemModel to InventoryItem
  InventoryItem toEntity(InventoryItemModel model) {
    return InventoryItem(
      name: model.name,
      quantity: model.quantity,
      unit: model.unit,
      category: model.category,
      location: model.location,
      note: model.note,
      expiry: model.expiry,
      costPerUnit: model.costPerUnit,
      addedAt: model.addedAt,
      updatedAt: model.updatedAt,
      isLowStock: model.isLowStock,
    );
  }

  List<InventoryItemModel> getAll() {
    return _store.items().map(toModel).toList();
  }

  InventoryItemModel? getById(String id) {
    final entity = _store.items().firstWhere(
      (item) => item.key.toString() == id,
      orElse: () => throw StateError('Item not found'),
    );
    return toModel(entity);
  }

  Future<void> addItem(InventoryItemModel model) async {
    final entity = toEntity(model);
    await _store.addItem(entity);
  }

  Future<void> updateItem({
    required InventoryItemModel model,
    String? name,
    double? quantity,
    String? unit,
    String? category,
    String? location,
    String? note,
    DateTime? expiry,
    double? costPerUnit,
    bool? isLowStock,
  }) async {
    final entity = _store.items().firstWhere(
      (item) => item.key.toString() == model.id,
      orElse: () => throw StateError('Item not found'),
    );
    await _store.upsertItem(
      item: entity,
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

  Future<void> adjustQuantity(InventoryItemModel model, double delta) async {
    final entity = _store.items().firstWhere(
      (item) => item.key.toString() == model.id,
      orElse: () => throw StateError('Item not found'),
    );
    await _store.adjustQuantity(entity, delta);
  }

  Future<void> toggleLowStock(InventoryItemModel model) async {
    final entity = _store.items().firstWhere(
      (item) => item.key.toString() == model.id,
      orElse: () => throw StateError('Item not found'),
    );
    await _store.toggleLowStock(entity);
  }

  Future<void> remove(InventoryItemModel model) async {
    final entity = _store.items().firstWhere(
      (item) => item.key.toString() == model.id,
      orElse: () => throw StateError('Item not found'),
    );
    await _store.remove(entity);
  }

  Future<void> clear() async {
    await _store.clear();
  }
}

