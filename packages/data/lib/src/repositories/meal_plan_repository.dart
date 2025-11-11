import 'dart:async';

import '../meal_plan_entity.dart';
import '../meal_plan_store.dart';

abstract class MealPlanRepository {
  Stream<Map<DateTime, MealPlanDayEntity>> watchAll();
  MealPlanDayEntity dayFor(DateTime date);
  Future<void> setMeal({
    required DateTime date,
    required MealSlot slot,
    String? recipeUrl,
  });
  Future<void> addMeal({
    required DateTime date,
    required MealSlot slot,
    required String recipeUrl,
  });
  Future<void> removeMeal({
    required DateTime date,
    required MealSlot slot,
    required String recipeUrl,
  });
  Future<void> setMeals({
    required DateTime date,
    required Map<MealSlot, List<String>> meals,
  });
  Future<void> setNotes({required DateTime date, String? notes});
  Future<void> deleteDay(DateTime date);
  Future<void> clear();
  MealPlanDayEntity copyPreviousAvailable(DateTime date);
  MealPlanDayEntity? dayMatchingRecipes(Set<String> recipeUrls);
  Map<DateTime, MealPlanDayEntity> asMap();
}

class HiveMealPlanRepository implements MealPlanRepository {
  HiveMealPlanRepository({MealPlanStore? store})
      : _store = store ?? MealPlanStore.instance;

  final MealPlanStore _store;

  @override
  Stream<Map<DateTime, MealPlanDayEntity>> watchAll() {
    final listenable = _store.listenable();
    return Stream<Map<DateTime, MealPlanDayEntity>>.multi((controller) {
      void emit() => controller.add(_store.asMap());
      emit();
      void listener() => emit();
      listenable.addListener(listener);
      controller.onCancel = () {
        listenable.removeListener(listener);
      };
    });
  }

  @override
  MealPlanDayEntity dayFor(DateTime date) => _store.dayFor(date);

  @override
  Future<void> setMeal({
    required DateTime date,
    required MealSlot slot,
    String? recipeUrl,
  }) =>
      _store.setMeal(date: date, slot: slot, recipeUrl: recipeUrl);

  @override
  Future<void> addMeal({
    required DateTime date,
    required MealSlot slot,
    required String recipeUrl,
  }) =>
      _store.addMeal(date: date, slot: slot, recipeUrl: recipeUrl);

  @override
  Future<void> removeMeal({
    required DateTime date,
    required MealSlot slot,
    required String recipeUrl,
  }) =>
      _store.removeMeal(date: date, slot: slot, recipeUrl: recipeUrl);

  @override
  Future<void> setMeals({
    required DateTime date,
    required Map<MealSlot, List<String>> meals,
  }) =>
      _store.setMeals(date: date, meals: meals);

  @override
  Future<void> setNotes({required DateTime date, String? notes}) =>
      _store.setNotes(date: date, notes: notes);

  @override
  Future<void> deleteDay(DateTime date) => _store.deleteDay(date);

  @override
  Future<void> clear() => _store.clear();

  @override
  MealPlanDayEntity copyPreviousAvailable(DateTime date) =>
      _store.copyPreviousAvailable(date);

  @override
  MealPlanDayEntity? dayMatchingRecipes(Set<String> recipeUrls) =>
      _store.dayMatchingRecipes(recipeUrls);

  @override
  Map<DateTime, MealPlanDayEntity> asMap() => _store.asMap();
}

