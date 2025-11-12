import 'package:data/data.dart';
import 'package:flutter/material.dart';

import 'src/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RecipeStore.init();
  await MealPlanStore.init();
  await ShoppingListStore.init();
  await InventoryStore.init();
  await ImportedUrlStore.init();
  AppRepositories.install(
    AppRepositories(
      recipes: HiveRecipeRepository(),
      mealPlans: HiveMealPlanRepository(),
      shoppingList: HiveShoppingListRepository(),
      inventory: HiveInventoryRepository(),
    ),
  );
  runApp(const RecipeParserApp());
}
