/// Nutrition information for a recipe or meal
class NutritionInfo {
  NutritionInfo({
    this.calories,
    this.protein,
    this.carbohydrates,
    this.fat,
    this.fiber,
    this.sugar,
    this.sodium,
    this.servings,
  });

  /// Calories (kcal)
  final double? calories;

  /// Protein in grams
  final double? protein;

  /// Carbohydrates in grams
  final double? carbohydrates;

  /// Fat in grams
  final double? fat;

  /// Fiber in grams
  final double? fiber;

  /// Sugar in grams
  final double? sugar;

  /// Sodium in milligrams
  final double? sodium;

  /// Number of servings this nutrition info is for
  final int? servings;

  /// Get calories per serving
  double? get caloriesPerServing {
    if (calories == null || servings == null || servings == 0) {
      return null;
    }
    return calories! / servings!;
  }

  /// Get protein per serving in grams
  double? get proteinPerServing {
    if (protein == null || servings == null || servings == 0) {
      return null;
    }
    return protein! / servings!;
  }

  /// Get carbohydrates per serving in grams
  double? get carbohydratesPerServing {
    if (carbohydrates == null || servings == null || servings == 0) {
      return null;
    }
    return carbohydrates! / servings!;
  }

  /// Get fat per serving in grams
  double? get fatPerServing {
    if (fat == null || servings == null || servings == 0) {
      return null;
    }
    return fat! / servings!;
  }

  /// Scale nutrition info by a factor (e.g., for scaling recipes)
  NutritionInfo scale(double factor) {
    return NutritionInfo(
      calories: calories != null ? calories! * factor : null,
      protein: protein != null ? protein! * factor : null,
      carbohydrates: carbohydrates != null ? carbohydrates! * factor : null,
      fat: fat != null ? fat! * factor : null,
      fiber: fiber != null ? fiber! * factor : null,
      sugar: sugar != null ? sugar! * factor : null,
      sodium: sodium != null ? sodium! * factor : null,
      servings: servings,
    );
  }

  /// Combine multiple nutrition infos (for meal plans)
  static NutritionInfo combine(List<NutritionInfo> infos) {
    double? totalCalories;
    double? totalProtein;
    double? totalCarbohydrates;
    double? totalFat;
    double? totalFiber;
    double? totalSugar;
    double? totalSodium;

    for (final info in infos) {
      if (info.calories != null) {
        totalCalories = (totalCalories ?? 0) + info.calories!;
      }
      if (info.protein != null) {
        totalProtein = (totalProtein ?? 0) + info.protein!;
      }
      if (info.carbohydrates != null) {
        totalCarbohydrates = (totalCarbohydrates ?? 0) + info.carbohydrates!;
      }
      if (info.fat != null) {
        totalFat = (totalFat ?? 0) + info.fat!;
      }
      if (info.fiber != null) {
        totalFiber = (totalFiber ?? 0) + info.fiber!;
      }
      if (info.sugar != null) {
        totalSugar = (totalSugar ?? 0) + info.sugar!;
      }
      if (info.sodium != null) {
        totalSodium = (totalSodium ?? 0) + info.sodium!;
      }
    }

    return NutritionInfo(
      calories: totalCalories,
      protein: totalProtein,
      carbohydrates: totalCarbohydrates,
      fat: totalFat,
      fiber: totalFiber,
      sugar: totalSugar,
      sodium: totalSodium,
    );
  }

  /// Check if any nutrition data is available
  bool get hasData =>
      calories != null ||
      protein != null ||
      carbohydrates != null ||
      fat != null ||
      fiber != null ||
      sugar != null ||
      sodium != null;

  /// Check if all major nutrition data is available
  bool get hasCompleteData =>
      calories != null &&
      protein != null &&
      carbohydrates != null &&
      fat != null;
}

