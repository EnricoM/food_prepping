import 'package:hive/hive.dart';

enum MealSlot { breakfast, lunch, dinner, snack }

class MealPlanDayEntity extends HiveObject {
  MealPlanDayEntity({
    required this.date,
    Map<MealSlot, List<String>>? meals,
    this.notes,
  }) : meals = meals ?? <MealSlot, List<String>>{};

  final DateTime date;
  final Map<MealSlot, List<String>> meals;
  final String? notes;

  MealPlanDayEntity copyWith({
    Map<MealSlot, List<String>>? meals,
    String? notes,
  }) {
    return MealPlanDayEntity(
      date: date,
      meals: meals ?? _cloneMeals(this.meals),
      notes: notes ?? this.notes,
    );
  }

  List<String> recipesFor(MealSlot slot) =>
      List.unmodifiable(meals[slot] ?? const []);

  MealPlanDayEntity updatedMeals(MealSlot slot, List<String> recipeUrls) {
    final normalized = recipeUrls.where((url) => url.isNotEmpty).toList();
    final updatedMeals = _cloneMeals(meals);
    if (normalized.isEmpty) {
      updatedMeals.remove(slot);
    } else {
      updatedMeals[slot] = normalized;
    }
    return copyWith(meals: updatedMeals);
  }

  MealPlanDayEntity addMeal(MealSlot slot, String recipeUrl) {
    if (recipeUrl.isEmpty) return this;
    final updatedMeals = _cloneMeals(meals);
    final list = updatedMeals.putIfAbsent(slot, () => <String>[]);
    if (!list.contains(recipeUrl)) {
      list.add(recipeUrl);
    }
    return copyWith(meals: updatedMeals);
  }

  MealPlanDayEntity removeMeal(MealSlot slot, String recipeUrl) {
    final updatedMeals = _cloneMeals(meals);
    final list = updatedMeals[slot];
    if (list == null) {
      return this;
    }
    list.remove(recipeUrl);
    if (list.isEmpty) {
      updatedMeals.remove(slot);
    }
    return copyWith(meals: updatedMeals);
  }

  MealPlanDayEntity updatedNotes(String? value) => copyWith(notes: value);

  bool get isEmpty {
    if (meals.isEmpty && (notes == null || notes!.isEmpty)) {
      return true;
    }
    for (final list in meals.values) {
      if (list.isNotEmpty) {
        return false;
      }
    }
    return notes == null || notes!.isEmpty;
  }

  static Map<MealSlot, List<String>> _cloneMeals(
    Map<MealSlot, List<String>> source,
  ) {
    final copy = <MealSlot, List<String>>{};
    for (final entry in source.entries) {
      copy[entry.key] = List<String>.from(entry.value);
    }
    return copy;
  }
}

class MealSlotAdapter extends TypeAdapter<MealSlot> {
  @override
  final int typeId = 2;

  @override
  MealSlot read(BinaryReader reader) {
    final value = reader.readByte();
    return MealSlot.values[value];
  }

  @override
  void write(BinaryWriter writer, MealSlot obj) {
    writer.writeByte(obj.index);
  }
}

class MealPlanDayEntityAdapter extends TypeAdapter<MealPlanDayEntity> {
  @override
  final int typeId = 3;

  @override
  MealPlanDayEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      fields[key] = reader.read();
    }

    final meals = <MealSlot, List<String>>{};
    final rawMeals = fields[1];
    if (rawMeals is Map) {
      rawMeals.forEach((key, value) {
        if (key is! MealSlot) {
          return;
        }
        if (value is String) {
          meals[key] = [value];
        } else if (value is Iterable) {
          final list =
              value.whereType<String>().where((e) => e.isNotEmpty).toList();
          if (list.isNotEmpty) {
            meals[key] = list;
          }
        }
      });
    }

    return MealPlanDayEntity(
      date: (fields[0] as DateTime?) ?? DateTime.now(),
      meals: meals,
      notes: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MealPlanDayEntity obj) {
    final filteredMeals = <MealSlot, List<String>>{};
    for (final entry in obj.meals.entries) {
      if (entry.value.isNotEmpty) {
        filteredMeals[entry.key] = entry.value;
      }
    }
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(filteredMeals)
      ..writeByte(2)
      ..write(obj.notes);
  }
}
