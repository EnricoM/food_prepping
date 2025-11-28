import 'dart:async';

import '../models/meal_plan_day_model.dart';
import '../models/meal_slot.dart';

/// Repository interface for meal plan data operations
///
/// This defines the contract for meal plan data access.
/// Implementations will be in the data layer.
abstract class MealPlanRepository {
  /// Stream of all meal plans by date
  Stream<Map<DateTime, MealPlanDayModel>> watchAll();

  /// Get meal plan for a specific date
  MealPlanDayModel dayFor(DateTime date);

  /// Set a meal for a specific date and slot
  Future<void> setMeal({
    required DateTime date,
    required MealSlot slot,
    String? recipeUrl,
  });

  /// Add a meal to a specific date and slot
  Future<void> addMeal({
    required DateTime date,
    required MealSlot slot,
    required String recipeUrl,
  });

  /// Remove a meal from a specific date and slot
  Future<void> removeMeal({
    required DateTime date,
    required MealSlot slot,
    required String recipeUrl,
  });

  /// Set all meals for a specific date
  Future<void> setMeals({
    required DateTime date,
    required Map<MealSlot, List<String>> meals,
  });

  /// Set notes for a specific date
  Future<void> setNotes({
    required DateTime date,
    String? notes,
  });

  /// Delete a day's meal plan
  Future<void> deleteDay(DateTime date);

  /// Clear all meal plans
  Future<void> clear();

  /// Copy meals from the most recent available day before the given date
  MealPlanDayModel copyPreviousAvailable(DateTime date);

  /// Find a day that matches all the given recipe URLs
  MealPlanDayModel? dayMatchingRecipes(Set<String> recipeUrls);

  /// Get all meal plans as a map
  Map<DateTime, MealPlanDayModel> asMap();
}

