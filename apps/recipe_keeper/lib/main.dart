import 'dart:io';

import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'src/app.dart';
import 'src/screens/initialization_error_screen.dart';
import 'package:flutter/foundation.dart';
import 'src/services/measurement_preferences.dart';
import 'src/services/subscription_service.dart';
import 'src/services/tour_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize data stores with error handling
  // If initialization fails (e.g., corrupted data), show error screen
  Object? initError;
  try {
    await RecipeStore.init();
    await MealPlanStore.init();
    await ShoppingListStore.init();
    await InventoryStore.init();
    await ImportedUrlStore.init();
    
    // Install repositories after stores are initialized
    AppRepositories.install(
      AppRepositories(
        recipes: HiveRecipeRepository(),
        mealPlans: HiveMealPlanRepository(),
        shoppingList: HiveShoppingListRepository(),
        inventory: HiveInventoryRepository(),
      ),
    );
  } catch (e) {
    debugPrint('Error initializing data stores: $e');
    initError = e;
  }
  
  // If initialization failed, show error screen
  if (initError != null) {
    runApp(InitializationErrorApp(error: initError));
    return;
  }
  
  // Initialize services with error handling
  try {
    await MeasurementPreferences.instance.init();
  } catch (e) {
    debugPrint('Error initializing measurement preferences: $e');
  }
  
  try {
    await SubscriptionService.instance.init();
  } catch (e) {
    debugPrint('Error initializing subscription service: $e');
  }
  
  // TourService.init() already calls TourProgress.instance.init(), so we don't need to call it again
  try {
    await TourService.instance.init();
  } catch (e) {
    debugPrint('Error initializing tour service: $e');
  }
  
  // Initialize AdMob with error handling
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS)) {
    try {
      await MobileAds.instance.initialize();
    } catch (e) {
      debugPrint('Error initializing AdMob: $e');
      // Continue anyway - ads just won't work
    }
  }
  
  runApp(
    const ProviderScope(
      child: RecipeParserApp(),
    ),
  );
}

class InitializationErrorApp extends StatelessWidget {
  const InitializationErrorApp({super.key, required this.error});

  final Object error;

  Future<void> _clearAllData() async {
    try {
      // Close all boxes
      await Hive.close();
      
      // Delete all box files
      final boxNames = ['recipes', 'mealPlans', 'shoppingList', 'inventory', 'importedUrls'];
      for (final boxName in boxNames) {
        try {
          await Hive.deleteBoxFromDisk(boxName);
        } catch (e) {
          debugPrint('Error deleting box $boxName: $e');
        }
      }
      
      // Restart the app
      exit(0);
    } catch (e) {
      debugPrint('Error clearing data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Recipe Keeper',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF43A047),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        home: InitializationErrorScreen(
          error: error,
          onRetry: () {
            // Restart the app
            exit(0);
          },
          onClearData: _clearAllData,
        ),
      ),
    );
  }
}
