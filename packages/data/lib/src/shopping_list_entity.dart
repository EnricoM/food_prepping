import 'package:hive/hive.dart';

class ShoppingListItem extends HiveObject {
  ShoppingListItem({
    required this.ingredient,
    this.note,
    this.recipeTitle,
    this.recipeUrl,
    DateTime? addedAt,
    this.isChecked = false,
  }) : addedAt = addedAt ?? DateTime.now();

  final String ingredient;
  final String? note;
  final String? recipeTitle;
  final String? recipeUrl;
  final DateTime addedAt;
  final bool isChecked;

  ShoppingListItem copyWith({
    String? ingredient,
    String? note,
    String? recipeTitle,
    String? recipeUrl,
    DateTime? addedAt,
    bool? isChecked,
  }) {
    return ShoppingListItem(
      ingredient: ingredient ?? this.ingredient,
      note: note ?? this.note,
      recipeTitle: recipeTitle ?? this.recipeTitle,
      recipeUrl: recipeUrl ?? this.recipeUrl,
      addedAt: addedAt ?? this.addedAt,
      isChecked: isChecked ?? this.isChecked,
    );
  }
}

class ShoppingListItemAdapter extends TypeAdapter<ShoppingListItem> {
  @override
  final int typeId = 4;

  @override
  ShoppingListItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      fields[key] = reader.read();
    }
    return ShoppingListItem(
      ingredient: fields[0] as String? ?? '',
      note: fields[1] as String?,
      recipeTitle: fields[2] as String?,
      recipeUrl: fields[3] as String?,
      addedAt: fields[4] as DateTime?,
      isChecked: fields[5] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, ShoppingListItem obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.ingredient)
      ..writeByte(1)
      ..write(obj.note)
      ..writeByte(2)
      ..write(obj.recipeTitle)
      ..writeByte(3)
      ..write(obj.recipeUrl)
      ..writeByte(4)
      ..write(obj.addedAt)
      ..writeByte(5)
      ..write(obj.isChecked);
  }
}
