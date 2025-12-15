import 'dart:async';

import '../../domain/models/inventory_item_model.dart';
import '../../domain/repositories/inventory_repository.dart' as domain;
import '../datasources/inventory_datasource.dart';

/// Implementation of [domain.InventoryRepository] using [InventoryDataSource]
class InventoryRepositoryImpl implements domain.InventoryRepository {
  InventoryRepositoryImpl(this._dataSource);

  final InventoryDataSource _dataSource;

  @override
  Stream<List<InventoryItemModel>> watchAll() {
    final listenable = _dataSource.listenable;
    return Stream<List<InventoryItemModel>>.multi((controller) {
      void emit() {
        final box = listenable.value;
        controller.add(box.values.map(_dataSource.toModel).toList());
      }
      emit();
      void listener() => emit();
      listenable.addListener(listener);
      controller.onCancel = () {
        listenable.removeListener(listener);
      };
    });
  }

  @override
  List<InventoryItemModel> getAll() {
    return _dataSource.getAll();
  }

  @override
  Future<void> addItem(InventoryItemModel item) async {
    await _dataSource.addItem(item);
  }

  @override
  Future<void> updateItem({
    required InventoryItemModel item,
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
    await _dataSource.updateItem(
      model: item,
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
  Future<void> adjustQuantity(InventoryItemModel item, double delta) async {
    await _dataSource.adjustQuantity(item, delta);
  }

  @override
  Future<void> toggleLowStock(InventoryItemModel item) async {
    await _dataSource.toggleLowStock(item);
  }

  @override
  Future<void> remove(InventoryItemModel item) async {
    await _dataSource.remove(item);
  }

  @override
  Future<void> clear() async {
    await _dataSource.clear();
  }
}

