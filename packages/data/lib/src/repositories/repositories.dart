import 'inventory_repository.dart';
import 'meal_plan_repository.dart';
import 'recipe_repository.dart';
import 'shopping_list_repository.dart';

class AppRepositories {
  AppRepositories({
    required this.recipes,
    required this.mealPlans,
    required this.shoppingList,
    required this.inventory,
  });

  final RecipeRepository recipes;
  final MealPlanRepository mealPlans;
  final ShoppingListRepository shoppingList;
  final InventoryRepository inventory;

  static late AppRepositories instance;

  static void install(AppRepositories repositories) {
    instance = repositories;
  }
}

