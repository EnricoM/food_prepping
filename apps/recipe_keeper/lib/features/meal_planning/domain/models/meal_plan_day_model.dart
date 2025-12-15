import 'meal_slot.dart';

/// Domain model for a meal plan day
///
/// Represents the meals planned for a specific date.
class MealPlanDayModel {
  const MealPlanDayModel({
    required this.date,
    this.meals = const {},
    this.notes,
  });

  final DateTime date;
  final Map<MealSlot, List<String>> meals; // Map of meal slot to recipe URLs
  final String? notes;

  MealPlanDayModel copyWith({
    DateTime? date,
    Map<MealSlot, List<String>>? meals,
    String? notes,
  }) {
    return MealPlanDayModel(
      date: date ?? this.date,
      meals: meals ?? this.meals,
      notes: notes ?? this.notes,
    );
  }

  List<String> recipesFor(MealSlot slot) {
    return List.unmodifiable(meals[slot] ?? const []);
  }

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
}

