import '../models/meal_plan_day_model.dart';
import '../models/meal_slot.dart';

/// Use cases for meal plan operations
///
/// These define the business logic for meal plan operations.

/// Get meal plans between two dates
class GetMealPlansBetweenUseCase {
  const GetMealPlansBetweenUseCase();

  List<MealPlanDayModel> call({
    required Map<DateTime, MealPlanDayModel> allPlans,
    required DateTime start,
    required DateTime end,
  }) {
    final normalizedStart = DateTime(start.year, start.month, start.day);
    final normalizedEnd = DateTime(end.year, end.month, end.day);
    
    final days = <MealPlanDayModel>[];
    for (final entry in allPlans.entries) {
      final date = DateTime(
        entry.key.year,
        entry.key.month,
        entry.key.day,
      );
      if (!date.isBefore(normalizedStart) && !date.isAfter(normalizedEnd)) {
        days.add(entry.value);
      }
    }
    days.sort((a, b) => a.date.compareTo(b.date));
    return days;
  }
}

/// Get recipes for a specific slot on a given day
class GetRecipesForSlotUseCase {
  const GetRecipesForSlotUseCase();

  List<String> call({
    required MealPlanDayModel day,
    required MealSlot slot,
  }) {
    return day.recipesFor(slot);
  }
}

