/// App routing configuration
/// 
/// This file handles navigation setup for the app.
/// Currently using named routes, but can be migrated to go_router if needed.

class AppRouter {
  AppRouter._();

  /// Initial route for the app
  static const String initialRoute = '/home';

  /// Route names
  static const String home = '/home';
  static const String addRecipe = '/add';
  static const String manualRecipe = '/manual';
  static const String storedRecipes = '/stored';
  static const String filterRecipes = '/filter';
  static const String favorites = '/favorites';
  static const String recentlyAdded = '/recent';
  static const String domainDiscovery = '/discover';
  static const String visitedDomains = '/visited-domains';
  static const String batchCooking = '/batch-cooking';
  static const String inventory = '/inventory';
  static const String inventoryRecipes = '/inventory-recipes';
  static const String shoppingList = '/shopping-list';
  static const String mealPlan = '/meal-plan';
  static const String settings = '/settings';
  static const String recipeDetail = '/recipe-detail';
  static const String receiptScan = '/receipt-scan';
  static const String barcodeScan = '/barcode-scan';

  // TODO: Migrate to go_router or keep named routes based on preference
  // For now, routes are defined in app.dart
  // Future migration could use:
  // final routerProvider = Provider<GoRouter>((ref) {
  //   return GoRouter(
  //     initialLocation: initialRoute,
  //     routes: [...],
  //   );
  // });
}

