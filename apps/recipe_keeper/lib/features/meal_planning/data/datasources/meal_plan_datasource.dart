import 'dart:async';

import 'package:data/data.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/models/meal_plan_day_model.dart';
import '../../domain/models/meal_slot.dart' as domain;

/// Data source for meal plans
///
/// This adapts the existing MealPlanStore to work with the new MealPlanDayModel.
class MealPlanDataSource {
  MealPlanDataSource({MealPlanStore? store})
      : _store = store ?? MealPlanStore.instance;

  final MealPlanStore _store;

  ValueListenable<Box<MealPlanDayEntity>> get listenable => _store.listenable();

  /// Convert MealPlanDayEntity to MealPlanDayModel
  MealPlanDayModel toModel(MealPlanDayEntity entity) {
    final meals = <domain.MealSlot, List<String>>{};
    for (final entry in entity.meals.entries) {
      meals[_convertSlot(entry.key)] = List<String>.from(entry.value);
    }
    return MealPlanDayModel(
      date: entity.date,
      meals: meals,
      notes: entity.notes,
    );
  }

  /// Convert MealPlanDayModel to MealPlanDayEntity
  MealPlanDayEntity toEntity(MealPlanDayModel model) {
    final meals = <MealSlot, List<String>>{};
    for (final entry in model.meals.entries) {
      meals[_convertSlotToData(entry.key)] = List<String>.from(entry.value);
    }
    return MealPlanDayEntity(
      date: model.date,
      meals: meals,
      notes: model.notes,
    );
  }

  /// Convert data package MealSlot to domain MealSlot
  domain.MealSlot _convertSlot(MealSlot slot) {
    // Both enums have the same values, so we can use index mapping
    return domain.MealSlot.values[slot.index];
  }

  /// Convert domain MealSlot to data package MealSlot
  MealSlot _convertSlotToData(domain.MealSlot slot) {
    // Both enums have the same values, so we can use index mapping
    return MealSlot.values[slot.index];
  }

  Map<DateTime, MealPlanDayModel> getAll() {
    final map = <DateTime, MealPlanDayModel>{};
    for (final entry in _store.asMap().entries) {
      map[entry.key] = toModel(entry.value);
    }
    return map;
  }

  MealPlanDayModel dayFor(DateTime date) {
    return toModel(_store.dayFor(date));
  }

  Future<void> setMeal({
    required DateTime date,
    required domain.MealSlot slot,
    String? recipeUrl,
  }) async {
    await _store.setMeal(
      date: date,
      slot: _convertSlotToData(slot),
      recipeUrl: recipeUrl,
    );
  }

  Future<void> addMeal({
    required DateTime date,
    required domain.MealSlot slot,
    required String recipeUrl,
  }) async {
    await _store.addMeal(
      date: date,
      slot: _convertSlotToData(slot),
      recipeUrl: recipeUrl,
    );
  }

  Future<void> removeMeal({
    required DateTime date,
    required domain.MealSlot slot,
    required String recipeUrl,
  }) async {
    await _store.removeMeal(
      date: date,
      slot: _convertSlotToData(slot),
      recipeUrl: recipeUrl,
    );
  }

  Future<void> setMeals({
    required DateTime date,
    required Map<domain.MealSlot, List<String>> meals,
  }) async {
    final dataMeals = <MealSlot, List<String>>{};
    for (final entry in meals.entries) {
      dataMeals[_convertSlotToData(entry.key)] = List<String>.from(entry.value);
    }
    await _store.setMeals(date: date, meals: dataMeals);
  }

  Future<void> setNotes({
    required DateTime date,
    String? notes,
  }) async {
    await _store.setNotes(date: date, notes: notes);
  }

  Future<void> deleteDay(DateTime date) async {
    await _store.deleteDay(date);
  }

  Future<void> clear() async {
    await _store.clear();
  }

  MealPlanDayModel copyPreviousAvailable(DateTime date) {
    return toModel(_store.copyPreviousAvailable(date));
  }

  MealPlanDayModel? dayMatchingRecipes(Set<String> recipeUrls) {
    final entity = _store.dayMatchingRecipes(recipeUrls);
    return entity != null ? toModel(entity) : null;
  }
}

