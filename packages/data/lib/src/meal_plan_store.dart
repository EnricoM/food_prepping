import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:core/core.dart';
import 'meal_plan_entity.dart';
import 'recipe_store.dart';

class MealPlanStore {
  MealPlanStore._();

  static const _boxName = 'mealPlans';
  static MealPlanStore? _instance;

  static MealPlanStore get instance {
    final instance = _instance;
    if (instance == null) {
      throw StateError('MealPlanStore has not been initialized.');
    }
    return instance;
  }

  static Future<void> init() async {
    if (!Hive.isAdapterRegistered(MealSlotAdapter().typeId)) {
      Hive.registerAdapter(MealSlotAdapter());
    }
    if (!Hive.isAdapterRegistered(MealPlanDayEntityAdapter().typeId)) {
      Hive.registerAdapter(MealPlanDayEntityAdapter());
    }
    await Hive.openBox<MealPlanDayEntity>(_boxName);
    _instance = MealPlanStore._();
  }

  Box<MealPlanDayEntity> get _box => Hive.box<MealPlanDayEntity>(_boxName);

  ValueListenable<Box<MealPlanDayEntity>> listenable() => _box.listenable();

  MealPlanDayEntity? _getRaw(DateTime date) {
    final normalized = _normalize(date);
    return _box.get(_keyForDate(normalized));
  }

  MealPlanDayEntity dayFor(DateTime date) {
    final normalized = _normalize(date);
    final existing = _getRaw(normalized);
    return existing ?? MealPlanDayEntity(date: normalized);
  }

  Future<void> setMeal({
    required DateTime date,
    required MealSlot slot,
    String? recipeUrl,
  }) async {
    final normalized = _normalize(date);
    final existing = dayFor(normalized);
    final updated = existing.updatedMeals(
      slot,
      recipeUrl == null || recipeUrl.isEmpty ? const [] : [recipeUrl],
    );
    await _putOrDelete(updated);
  }

  Future<void> addMeal({
    required DateTime date,
    required MealSlot slot,
    required String recipeUrl,
  }) async {
    if (recipeUrl.isEmpty) return;
    final normalized = _normalize(date);
    final existing = dayFor(normalized);
    final updated = existing.addMeal(slot, recipeUrl);
    await _putOrDelete(updated);
  }

  Future<void> removeMeal({
    required DateTime date,
    required MealSlot slot,
    required String recipeUrl,
  }) async {
    final normalized = _normalize(date);
    final existing = dayFor(normalized);
    final updated = existing.removeMeal(slot, recipeUrl);
    await _putOrDelete(updated);
  }

  Future<void> setMeals({
    required DateTime date,
    required Map<MealSlot, List<String>> meals,
  }) async {
    final normalized = _normalize(date);
    final sanitized = <MealSlot, List<String>>{};
    for (final entry in meals.entries) {
      final list = entry.value.where((url) => url.isNotEmpty).toList();
      if (list.isNotEmpty) {
        sanitized[entry.key] = list;
      }
    }
    final updated = MealPlanDayEntity(date: normalized, meals: sanitized);
    await _putOrDelete(updated);
  }

  Future<void> setNotes({required DateTime date, String? notes}) async {
    final normalized = _normalize(date);
    final existing = dayFor(normalized);
    final updated = existing.updatedNotes(notes);
    await _putOrDelete(updated);
  }

  List<MealPlanDayEntity> between(DateTime start, DateTime end) {
    final days = <MealPlanDayEntity>[];
    final normalizedStart = _normalize(start);
    final normalizedEnd = _normalize(end);
    for (final entity in _box.values) {
      final date = _normalize(entity.date);
      if (!date.isBefore(normalizedStart) && !date.isAfter(normalizedEnd)) {
        days.add(entity);
      }
    }
    return days..sort((a, b) => a.date.compareTo(b.date));
  }

  Map<DateTime, MealPlanDayEntity> asMap() {
    final map = <DateTime, MealPlanDayEntity>{};
    for (final entity in _box.values) {
      map[_normalize(entity.date)] = entity;
    }
    return map;
  }

  MealPlanDayEntity copyPreviousAvailable(DateTime date) {
    final normalized = _normalize(date);
    final sorted = _box.values.toList(growable: false)
      ..sort((a, b) => b.date.compareTo(a.date));
    for (final entity in sorted) {
      if (_normalize(entity.date).isBefore(normalized) && !entity.isEmpty) {
        return MealPlanDayEntity(
          date: normalized,
          meals: _cloneMeals(entity.meals),
          notes: entity.notes,
        );
      }
    }
    return MealPlanDayEntity(date: normalized);
  }

  MealPlanDayEntity? dayMatchingRecipes(Set<String> recipeUrls) {
    if (recipeUrls.isEmpty) {
      return null;
    }
    for (final entity in _box.values) {
      final assigned = <String>{};
      for (final list in entity.meals.values) {
        assigned.addAll(list);
      }
      if (assigned.containsAll(recipeUrls)) {
        return entity;
      }
    }
    return null;
  }

  Future<void> clear() => _box.clear();

  Future<void> deleteDay(DateTime date) async {
    final normalized = _normalize(date);
    await _box.delete(_keyForDate(normalized));
  }

  Future<void> _putOrDelete(MealPlanDayEntity entity) async {
    final key = _keyForDate(entity.date);
    if (entity.isEmpty) {
      await _box.delete(key);
    } else {
      await _box.put(key, entity);
    }
  }

  DateTime _normalize(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  String _keyForDate(DateTime date) => '${date.year}-${date.month}-${date.day}';

  List<Recipe> recipesForSlot(MealSlot slot, MealPlanDayEntity day) {
    final urls = day.meals[slot];
    if (urls == null || urls.isEmpty) {
      return const [];
    }
    final recipes = <Recipe>[];
    for (final url in urls) {
      final entity = RecipeStore.instance.entityFor(url);
      if (entity != null) {
        recipes.add(entity.toRecipe());
      }
    }
    return recipes;
  }

  Map<MealSlot, List<String>> _cloneMeals(Map<MealSlot, List<String>> source) {
    final copy = <MealSlot, List<String>>{};
    for (final entry in source.entries) {
      copy[entry.key] = List<String>.from(entry.value);
    }
    return copy;
  }
}
