import 'package:hive/hive.dart';

class InventoryItem extends HiveObject {
  InventoryItem({
    required this.name,
    this.quantity = 1,
    this.unit,
    this.category,
    this.location,
    this.note,
    this.expiry,
    DateTime? addedAt,
    DateTime? updatedAt,
    this.isLowStock = false,
  })  : addedAt = addedAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  final String name;
  final double quantity;
  final String? unit;
  final String? category;
  final String? location;
  final String? note;
  final DateTime? expiry;
  final DateTime addedAt;
  final DateTime updatedAt;
  final bool isLowStock;

  InventoryItem copyWith({
    String? name,
    double? quantity,
    String? unit,
    String? category,
    String? location,
    String? note,
    DateTime? expiry,
    DateTime? addedAt,
    DateTime? updatedAt,
    bool? isLowStock,
  }) {
    return InventoryItem(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      location: location ?? this.location,
      note: note ?? this.note,
      expiry: expiry ?? this.expiry,
      addedAt: addedAt ?? this.addedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isLowStock: isLowStock ?? this.isLowStock,
    );
  }
}

class InventoryItemAdapter extends TypeAdapter<InventoryItem> {
  @override
  final int typeId = 5;

  @override
  InventoryItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      fields[key] = reader.read();
    }
    return InventoryItem(
      name: fields[0] as String? ?? '',
      quantity: (fields[1] as num?)?.toDouble() ?? 1,
      unit: fields[2] as String?,
      category: fields[3] as String?,
      location: fields[4] as String?,
      note: fields[5] as String?,
      expiry: fields[6] as DateTime?,
      addedAt: fields[7] as DateTime? ?? DateTime.now(),
      updatedAt: fields[8] as DateTime? ?? DateTime.now(),
      isLowStock: fields[9] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, InventoryItem obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.quantity)
      ..writeByte(2)
      ..write(obj.unit)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.location)
      ..writeByte(5)
      ..write(obj.note)
      ..writeByte(6)
      ..write(obj.expiry)
      ..writeByte(7)
      ..write(obj.addedAt)
      ..writeByte(8)
      ..write(obj.updatedAt)
      ..writeByte(9)
      ..write(obj.isLowStock);
  }
}
