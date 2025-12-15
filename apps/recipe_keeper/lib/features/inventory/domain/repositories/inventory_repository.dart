import 'dart:async';

import '../models/inventory_item_model.dart';

/// Repository interface for inventory data operations
///
/// This defines the contract for inventory data access.
/// Implementations will be in the data layer.
abstract class InventoryRepository {
  /// Stream of all inventory items
  Stream<List<InventoryItemModel>> watchAll();

  /// Get all inventory items synchronously
  List<InventoryItemModel> getAll();

  /// Add a new inventory item
  Future<void> addItem(InventoryItemModel item);

  /// Update an existing inventory item
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
  });

  /// Adjust quantity of an inventory item
  Future<void> adjustQuantity(InventoryItemModel item, double delta);

  /// Toggle low stock status of an inventory item
  Future<void> toggleLowStock(InventoryItemModel item);

  /// Remove an inventory item
  Future<void> remove(InventoryItemModel item);

  /// Clear all inventory items
  Future<void> clear();
}

