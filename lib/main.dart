import 'package:data/data.dart';
import 'package:flutter/material.dart';

import 'src/app.dart';
import 'package:flutter/foundation.dart';
import 'src/services/measurement_preferences.dart';
import 'src/services/subscription_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

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
  await MeasurementPreferences.instance.init();
  await SubscriptionService.instance.init();
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS)) {
    await MobileAds.instance.initialize();
  }
  runApp(const RecipeParserApp());
}
