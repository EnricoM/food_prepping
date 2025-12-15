/// Domain model for an inventory item
///
/// Represents an item in the inventory with quantity, cost, and metadata.
class InventoryItemModel {
  const InventoryItemModel({
    required this.id,
    required this.name,
    this.quantity = 1,
    this.unit,
    this.category,
    this.location,
    this.note,
    this.expiry,
    this.costPerUnit,
    required this.addedAt,
    required this.updatedAt,
    this.isLowStock = false,
  });

  final String id; // Unique identifier (Hive key)
  final String name;
  final double quantity;
  final String? unit;
  final String? category;
  final String? location;
  final String? note;
  final DateTime? expiry;
  final double? costPerUnit; // Cost per unit (e.g., per kg, per item)
  final DateTime addedAt;
  final DateTime updatedAt;
  final bool isLowStock;

  /// Total cost for this inventory item
  double? get totalCost => costPerUnit != null ? costPerUnit! * quantity : null;

  InventoryItemModel copyWith({
    String? id,
    String? name,
    double? quantity,
    String? unit,
    String? category,
    String? location,
    String? note,
    DateTime? expiry,
    double? costPerUnit,
    DateTime? addedAt,
    DateTime? updatedAt,
    bool? isLowStock,
  }) {
    return InventoryItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      location: location ?? this.location,
      note: note ?? this.note,
      expiry: expiry ?? this.expiry,
      costPerUnit: costPerUnit ?? this.costPerUnit,
      addedAt: addedAt ?? this.addedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isLowStock: isLowStock ?? this.isLowStock,
    );
  }
}

