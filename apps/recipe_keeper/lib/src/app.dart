import 'dart:async';

import 'package:data/data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:meal_planner/meal_planner.dart';
import 'package:shared_ui/shared_ui.dart';
import 'package:core/core.dart';


import 'navigation/app_drawer.dart';
import 'screens/add_recipe_screen.dart';
import '../features/recipes/presentation/screens/add_recipe_screen.dart' as add_recipe;
import 'services/deep_link_service.dart';
import 'screens/domain_discovery_screen.dart';
import 'screens/visited_domains_screen.dart';
import 'screens/favorites_screen.dart';
import '../features/recipes/presentation/screens/favorites_screen.dart' as new_favorites;
import '../features/recipes/presentation/screens/recently_added_screen.dart' as new_recent;
import 'screens/inventory_recipe_suggestions_screen.dart';
import 'screens/filter_recipes_screen.dart';
import '../features/recipes/presentation/screens/filter_recipes_screen.dart' as new_filter;
import 'screens/home_screen.dart';
import 'screens/manual_recipe_screen.dart';
import '../features/recipes/presentation/screens/manual_recipe_screen.dart' as manual_recipe;
import 'screens/recently_added_screen.dart';
import 'screens/recipe_detail_screen.dart';
import 'screens/shopping_list_screen.dart';
import '../features/shopping_list/presentation/screens/shopping_list_screen.dart' as shopping_list;
import 'screens/stored_recipes_screen.dart';
import '../features/recipes/presentation/screens/stored_recipes_screen.dart' as new_arch;
import 'screens/inventory_screen.dart';
import 'screens/barcode_scan_screen.dart';
import 'screens/receipt_scan_screen.dart';
import 'screens/batch_cooking_screen.dart';
import '../features/recipes/presentation/screens/batch_cooking_screen.dart' as batch_cooking;
import 'screens/settings_screen.dart';
import '../features/meal_planning/presentation/screens/meal_plan_screen.dart' as meal_plan;
import '../features/inventory/presentation/screens/inventory_screen.dart' as inventory;

class RecipeParserApp extends StatefulWidget {
  const RecipeParserApp({super.key});

  static const _initialRoute = HomeScreen.routeName;

  @override
  State<RecipeParserApp> createState() => _RecipeParserAppState();
}

class _RecipeParserAppState extends State<RecipeParserApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  StreamSubscription<Uri>? _deepLinkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    await DeepLinkService.instance.init();
    _deepLinkSubscription = DeepLinkService.instance.linkStream.listen(
      (uri) {
        _handleDeepLink(uri);
      },
    );
  }

  void _handleDeepLink(Uri uri) {
    final navigator = _navigatorKey.currentState;
    if (navigator == null) return;

    // Extract URL from deep link
    // The URL could be:
    // - The full URI itself (if shared directly as http/https)
    // - A query parameter like ?url=https://...
    // - The path/query if it's a custom scheme with URL in it
    String? url;
    
    if (uri.scheme == 'http' || uri.scheme == 'https') {
      // Direct URL share - use the full URI
      url = uri.toString();
    } else if (uri.queryParameters.containsKey('url')) {
      // URL in query parameter
      url = uri.queryParameters['url'];
    } else if (uri.path.isNotEmpty && (uri.path.startsWith('http://') || uri.path.startsWith('https://'))) {
      // URL might be in the path (some share implementations do this)
      url = uri.path;
    } else if (uri.hasQuery && uri.query.isNotEmpty) {
      // Try to find URL in query string
      final query = uri.query;
      // Look for http:// or https:// in the query
      final urlMatch = RegExp(r'https?://[^\s]+').firstMatch(query);
      if (urlMatch != null) {
        url = urlMatch.group(0);
      }
    } else {
      // Try to use the full URI as URL (for custom schemes that might contain URLs)
      final uriString = uri.toString();
      // Check if the URI string contains a URL
      final urlMatch = RegExp(r'https?://[^\s]+').firstMatch(uriString);
      if (urlMatch != null) {
        url = urlMatch.group(0);
      } else {
        url = uriString;
      }
    }

    // Validate that we have a valid URL
    if (url != null && url.isNotEmpty) {
      // Clean up the URL (remove trailing whitespace, fragments that might break parsing)
      url = url.trim();
      
      // Validate it's actually a URL
      final parsedUrl = Uri.tryParse(url);
      if (parsedUrl != null && (parsedUrl.scheme == 'http' || parsedUrl.scheme == 'https')) {
        // Navigate to add recipe screen with the URL
        // The screen will auto-parse the URL
        navigator.pushNamed(
          AddRecipeScreen.routeName,
          arguments: url,
        );
      }
    }
  }

  @override
  void dispose() {
    _deepLinkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF43A047),
      brightness: Brightness.light,
    );

    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Recipe Keeper',
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6FFF8),
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          centerTitle: true,
          shadowColor: Colors.black.withValues(alpha: 0.1),
        ),
        cardTheme: CardThemeData(
          color: colorScheme.surface,
          margin: EdgeInsets.zero,
          elevation: 2,
          shadowColor: Colors.black.withValues(alpha: 0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          surfaceTintColor: Colors.transparent,
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
            elevation: 2,
            shadowColor: Colors.black.withValues(alpha: 0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            side: BorderSide(color: colorScheme.primary, width: 1.5),
            foregroundColor: colorScheme.primary,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        drawerTheme: DrawerThemeData(
          backgroundColor: const Color(0xFFE9F7EE),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
      // Localization configuration  
      locale: const Locale('en'),
      supportedLocales: const [Locale('en')],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        // Try to find a matching locale
        for (var locale in supportedLocales) {
          if (locale.languageCode == deviceLocale?.languageCode) {
            return locale;
          }
        }
        // Default to English if device locale is not supported
        return const Locale('en');
      },
      initialRoute: RecipeParserApp._initialRoute,
      routes: {
        HomeScreen.routeName: (context) => _HomeScreenWrapper(
          openAddRecipe: () => _pushRoute(context, AddRecipeScreen.routeName),
          openManualRecipe: () =>
              _pushRoute(context, ManualRecipeScreen.routeName),
          openStoredRecipes: () =>
              _pushRoute(context, StoredRecipesScreen.routeName),
          openShoppingList: () =>
              _pushRoute(context, ShoppingListScreen.routeName),
          openInventory: () => _pushRoute(context, InventoryScreen.routeName),
        ),
        AddRecipeScreen.routeName: (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final url = args is String ? args : null;
          return add_recipe.AddRecipeScreen(
            drawer: const AppDrawer(currentRoute: AddRecipeScreen.routeName),
            initialUrl: url,
          );
        },
        ManualRecipeScreen.routeName: (context) => const manual_recipe.ManualRecipeScreen(
          drawer: AppDrawer(currentRoute: ManualRecipeScreen.routeName),
        ),
        StoredRecipesScreen.routeName: (context) => new_arch.StoredRecipesScreen(
          drawer: const AppDrawer(currentRoute: StoredRecipesScreen.routeName),
          onRecipeTap: (ctx, recipe) {
            // Navigation is handled internally by the new screen
            // This callback is for compatibility/extension
          },
        ),
        InventoryScreen.routeName: (context) => inventory.InventoryScreen(),
        ShoppingListScreen.routeName: (context) => const shopping_list.ShoppingListScreen(),
        FilterRecipesScreen.routeName: (context) => const new_filter.FilterRecipesScreen(
          drawer: AppDrawer(currentRoute: FilterRecipesScreen.routeName),
        ),
        BatchCookingScreen.routeName: (context) => const batch_cooking.BatchCookingScreen(
          drawer: AppDrawer(currentRoute: BatchCookingScreen.routeName),
        ),
        FavoritesScreen.routeName: (context) => const new_favorites.FavoritesScreen(
          drawer: AppDrawer(currentRoute: FavoritesScreen.routeName),
        ),
        RecentlyAddedScreen.routeName: (context) => const new_recent.RecentlyAddedScreen(
          drawer: AppDrawer(currentRoute: RecentlyAddedScreen.routeName),
        ),
        DomainDiscoveryScreen.routeName: (context) => DomainDiscoveryScreen(
          drawer: const AppDrawer(
            currentRoute: DomainDiscoveryScreen.routeName,
          ),
          onRecipeDiscovered: (ctx, url) {
            Navigator.of(ctx).push(
              MaterialPageRoute<void>(
                builder: (innerContext) => add_recipe.AddRecipeScreen(
                  initialUrl: url,
                ),
              ),
            );
          },
        ),
        VisitedDomainsScreen.routeName: (context) => const VisitedDomainsScreen(
          drawer: AppDrawer(currentRoute: VisitedDomainsScreen.routeName),
        ),
        SettingsScreen.routeName: (context) => const SettingsScreen(),
        InventoryRecipeSuggestionsScreen.routeName: (context) => const InventoryRecipeSuggestionsScreen(
          drawer: AppDrawer(currentRoute: InventoryRecipeSuggestionsScreen.routeName),
        ),
        MealPlanScreen.routeName: (context) => meal_plan.MealPlanScreen(
          drawer: const AppDrawer(currentRoute: MealPlanScreen.routeName),
          onRecipeSelected: (ctx, entity) =>
              pushRecipeDetails(ctx, entity.toRecipe(), entity: entity),
          pageInsetsBuilder: responsivePageInsets,
        ),
      },
      onGenerateRoute: (settings) {
        // Handle old RecipeDetailScreen for backward compatibility
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

class _HomeScreenWrapper extends StatelessWidget {
  const _HomeScreenWrapper({
    required this.openAddRecipe,
    required this.openManualRecipe,
    required this.openStoredRecipes,
    required this.openShoppingList,
    required this.openInventory,
  });

  final VoidCallback openAddRecipe;
  final VoidCallback openManualRecipe;
  final VoidCallback openStoredRecipes;
  final VoidCallback openShoppingList;
  final VoidCallback openInventory;

  @override
  Widget build(BuildContext context) {
    // Tour disabled - removed auto-launch to avoid bad first impression
    return HomeScreen(
      openAddRecipe: openAddRecipe,
      openManualRecipe: openManualRecipe,
      openStoredRecipes: openStoredRecipes,
      openShoppingList: openShoppingList,
      openInventory: openInventory,
    );
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
