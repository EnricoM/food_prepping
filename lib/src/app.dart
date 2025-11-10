import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/meal_planner.dart';
import 'package:shared_ui/shared_ui.dart';
import 'package:core/core.dart';

import 'navigation/app_drawer.dart';
import 'screens/add_recipe_screen.dart';
import 'screens/domain_discovery_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/filter_recipes_screen.dart';
import 'screens/home_screen.dart';
import 'screens/manual_recipe_screen.dart';
import 'screens/recently_added_screen.dart';
import 'screens/recipe_detail_screen.dart';
import 'screens/shopping_list_screen.dart';
import 'screens/stored_recipes_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/barcode_scan_screen.dart';
import 'screens/receipt_scan_screen.dart';

class RecipeParserApp extends StatelessWidget {
  const RecipeParserApp({super.key});

  static const _initialRoute = HomeScreen.routeName;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF43A047),
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'Recipe Parser',
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6FFF8),
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          color: colorScheme.surface,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        chipTheme:
            ChipThemeData.fromDefaults(
              secondaryColor: colorScheme.primary,
              brightness: Brightness.light,
              labelStyle: const TextStyle(fontWeight: FontWeight.w500),
            ).copyWith(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            side: BorderSide(color: colorScheme.primary),
            foregroundColor: colorScheme.primary,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        drawerTheme: DrawerThemeData(
          backgroundColor: const Color(0xFFE9F7EE),
          surfaceTintColor: Colors.transparent,
        ),
        navigationDrawerTheme: NavigationDrawerThemeData(
          indicatorColor: colorScheme.secondaryContainer,
        ),
        textTheme: Theme.of(context).textTheme.apply(
          fontFamily: 'Roboto',
          bodyColor: const Color(0xFF1B4332),
          displayColor: const Color(0xFF1B4332),
        ),
      ),
      initialRoute: _initialRoute,
      routes: {
        HomeScreen.routeName: (context) => HomeScreen(
          openAddRecipe: () =>
              _pushRoute(context, AddRecipeScreen.routeName),
          openManualRecipe: () =>
              _pushRoute(context, ManualRecipeScreen.routeName),
          openStoredRecipes: () =>
              _pushRoute(context, StoredRecipesScreen.routeName),
          openShoppingList: () =>
              _pushRoute(context, ShoppingListScreen.routeName),
          openInventory: () =>
              _pushRoute(context, InventoryScreen.routeName),
        ),
        AddRecipeScreen.routeName: (context) => AddRecipeScreen(
          drawer: const AppDrawer(currentRoute: AddRecipeScreen.routeName),
          onRecipeSaved: (ctx, recipe) => pushRecipeDetails(ctx, recipe),
        ),
        ManualRecipeScreen.routeName: (context) => ManualRecipeScreen(
          drawer: const AppDrawer(currentRoute: ManualRecipeScreen.routeName),
        ),
        StoredRecipesScreen.routeName: (context) => StoredRecipesScreen(
          drawer: const AppDrawer(currentRoute: StoredRecipesScreen.routeName),
          onRecipeTap: (ctx, entity) =>
              pushRecipeDetails(ctx, entity.toRecipe(), entity: entity),
        ),
        InventoryScreen.routeName: (context) => const InventoryScreen(),
        ShoppingListScreen.routeName: (context) => const ShoppingListScreen(),
        FilterRecipesScreen.routeName: (context) => FilterRecipesScreen(
          drawer: const AppDrawer(currentRoute: FilterRecipesScreen.routeName),
          onRecipeTap: (ctx, entity) =>
              pushRecipeDetails(ctx, entity.toRecipe(), entity: entity),
        ),
        FavoritesScreen.routeName: (context) => FavoritesScreen(
          drawer: const AppDrawer(currentRoute: FavoritesScreen.routeName),
          onRecipeTap: (ctx, entity) =>
              pushRecipeDetails(ctx, entity.toRecipe(), entity: entity),
        ),
        RecentlyAddedScreen.routeName: (context) => RecentlyAddedScreen(
          drawer: const AppDrawer(currentRoute: RecentlyAddedScreen.routeName),
          onRecipeTap: (ctx, entity) =>
              pushRecipeDetails(ctx, entity.toRecipe(), entity: entity),
        ),
        DomainDiscoveryScreen.routeName: (context) => DomainDiscoveryScreen(
          drawer: const AppDrawer(
            currentRoute: DomainDiscoveryScreen.routeName,
          ),
          onRecipeDiscovered: (ctx, url) {
            Navigator.of(ctx).push(
              MaterialPageRoute<void>(
                builder: (innerContext) => AddRecipeScreen(
                  onRecipeSaved: (detailCtx, recipe) =>
                      pushRecipeDetails(detailCtx, recipe),
                  initialUrl: url,
                ),
              ),
            );
          },
        ),
        MealPlanScreen.routeName: (context) => MealPlanScreen(
          drawer: const AppDrawer(currentRoute: MealPlanScreen.routeName),
          onRecipeSelected: (ctx, entity) =>
              pushRecipeDetails(ctx, entity.toRecipe(), entity: entity),
          pageInsetsBuilder: responsivePageInsets,
        ),
      },
      onGenerateRoute: (settings) {
        if (settings.name == RecipeDetailScreen.routeName) {
          final args = settings.arguments;
          if (args is RecipeDetailArgs) {
            return MaterialPageRoute<void>(
              builder: (_) => RecipeDetailScreen(args: args),
              settings: settings,
            );
          }
        }
        if (settings.name == ReceiptScanScreen.routeName) {
          final target =
              settings.arguments as ReceiptScanTarget? ??
              ReceiptScanTarget.inventory;
          return MaterialPageRoute<void>(
            builder: (_) => ReceiptScanScreen(target: target),
            settings: settings,
          );
        }
        if (settings.name == BarcodeScanScreen.routeName) {
          final target =
              settings.arguments as BarcodeScanTarget? ??
              BarcodeScanTarget.inventory;
          return MaterialPageRoute<void>(
            builder: (_) => BarcodeScanScreen(target: target),
            settings: settings,
          );
        }
        return null;
      },
    );
  }

  static void _pushRoute(BuildContext context, String route) {
    final current = ModalRoute.of(context)?.settings.name;
    if (current == route) {
      return;
    }
    Navigator.of(context).pushNamed(route);
  }
}

void pushRecipeDetails(
  BuildContext context,
  Recipe recipe, {
  RecipeEntity? entity,
}) {
  Navigator.of(context).pushNamed(
    RecipeDetailScreen.routeName,
    arguments: RecipeDetailArgs(recipe: recipe, entity: entity),
  );
}
