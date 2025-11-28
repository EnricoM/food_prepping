import 'dart:async';

import '../../domain/models/meal_plan_day_model.dart';
import '../../domain/models/meal_slot.dart' as domain;
import '../../domain/repositories/meal_plan_repository.dart' as domain_repo;
import '../datasources/meal_plan_datasource.dart';

/// Implementation of [domain_repo.MealPlanRepository] using [MealPlanDataSource]
class MealPlanRepositoryImpl implements domain_repo.MealPlanRepository {
  MealPlanRepositoryImpl(this._dataSource);

  final MealPlanDataSource _dataSource;

  @override
  Stream<Map<DateTime, MealPlanDayModel>> watchAll() {
    final listenable = _dataSource.listenable;
    return Stream<Map<DateTime, MealPlanDayModel>>.multi((controller) {
      void emit() {
        final box = listenable.value;
        final map = <DateTime, MealPlanDayModel>{};
        for (final entity in box.values) {
          final normalized = DateTime(
            entity.date.year,
            entity.date.month,
            entity.date.day,
          );
          map[normalized] = _dataSource.toModel(entity);
        }
        controller.add(map);
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
  MealPlanDayModel dayFor(DateTime date) {
    return _dataSource.dayFor(date);
  }

  @override
  Future<void> setMeal({
    required DateTime date,
    required domain.MealSlot slot,
    String? recipeUrl,
  }) async {
    await _dataSource.setMeal(date: date, slot: slot, recipeUrl: recipeUrl);
  }

  @override
  Future<void> addMeal({
    required DateTime date,
    required domain.MealSlot slot,
    required String recipeUrl,
  }) async {
    await _dataSource.addMeal(date: date, slot: slot, recipeUrl: recipeUrl);
  }

  @override
  Future<void> removeMeal({
    required DateTime date,
    required domain.MealSlot slot,
    required String recipeUrl,
  }) async {
    await _dataSource.removeMeal(date: date, slot: slot, recipeUrl: recipeUrl);
  }

  @override
  Future<void> setMeals({
    required DateTime date,
    required Map<domain.MealSlot, List<String>> meals,
  }) async {
    await _dataSource.setMeals(date: date, meals: meals);
  }

  @override
  Future<void> setNotes({
    required DateTime date,
    String? notes,
  }) async {
    await _dataSource.setNotes(date: date, notes: notes);
  }

  @override
  Future<void> deleteDay(DateTime date) async {
    await _dataSource.deleteDay(date);
  }

  @override
  Future<void> clear() async {
    await _dataSource.clear();
  }

  @override
  MealPlanDayModel copyPreviousAvailable(DateTime date) {
    return _dataSource.copyPreviousAvailable(date);
  }

  @override
  MealPlanDayModel? dayMatchingRecipes(Set<String> recipeUrls) {
    return _dataSource.dayMatchingRecipes(recipeUrls);
  }

  @override
  Map<DateTime, MealPlanDayModel> asMap() {
    return _dataSource.getAll();
  }
}

