import '../models/inventory_item_model.dart';

/// Use cases for inventory operations
///
/// These define the business logic for inventory operations.

/// Filter inventory items by category
class FilterInventoryByCategoryUseCase {
  const FilterInventoryByCategoryUseCase();

  List<InventoryItemModel> call({
    required List<InventoryItemModel> items,
    String? category,
  }) {
    if (category == null || category.isEmpty) {
      return items;
    }
    return items.where((item) => item.category == category).toList();
  }
}

/// Filter inventory items by low stock status
class FilterLowStockItemsUseCase {
  const FilterLowStockItemsUseCase();

  List<InventoryItemModel> call(List<InventoryItemModel> items) {
    return items.where((item) => item.isLowStock).toList();
  }
}

/// Sort inventory items
class SortInventoryItemsUseCase {
  const SortInventoryItemsUseCase();

  List<InventoryItemModel> call(
    List<InventoryItemModel> items,
    InventorySortBy sortBy,
  ) {
    final sorted = List<InventoryItemModel>.from(items);
    switch (sortBy) {
      case InventorySortBy.name:
        sorted.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case InventorySortBy.quantity:
        sorted.sort((a, b) => b.quantity.compareTo(a.quantity));
        break;
      case InventorySortBy.expiry:
        sorted.sort((a, b) {
          if (a.expiry == null && b.expiry == null) return 0;
          if (a.expiry == null) return 1;
          if (b.expiry == null) return -1;
          return a.expiry!.compareTo(b.expiry!);
        });
        break;
      case InventorySortBy.addedDate:
        sorted.sort((a, b) => b.addedAt.compareTo(a.addedAt));
        break;
      case InventorySortBy.category:
        sorted.sort((a, b) {
          final categoryA = a.category ?? '';
          final categoryB = b.category ?? '';
          if (categoryA != categoryB) {
            return categoryA.compareTo(categoryB);
          }
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
    }
    return sorted;
  }
}

enum InventorySortBy { name, quantity, expiry, addedDate, category }

