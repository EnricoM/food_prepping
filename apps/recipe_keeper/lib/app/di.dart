import 'package:data/data.dart' hide RecipeRepository, ShoppingListRepository, MealPlanRepository, InventoryRepository;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/recipes/data/datasources/recipe_datasource.dart';
import '../features/recipes/data/repositories/recipe_repository_impl.dart';
import '../features/recipes/domain/repositories/recipe_repository.dart';
import '../features/recipes/presentation/controllers/recipe_controller.dart';
import '../features/shopping_list/data/datasources/shopping_list_datasource.dart';
import '../features/shopping_list/data/repositories/shopping_list_repository_impl.dart';
import '../features/shopping_list/domain/repositories/shopping_list_repository.dart' as shopping_list_domain;
import '../features/shopping_list/presentation/controllers/shopping_list_controller.dart';
import '../features/meal_planning/data/datasources/meal_plan_datasource.dart';
import '../features/meal_planning/data/repositories/meal_plan_repository_impl.dart';
import '../features/meal_planning/domain/repositories/meal_plan_repository.dart' as meal_plan_domain;
import '../features/meal_planning/presentation/controllers/meal_plan_controller.dart';
import '../features/inventory/data/datasources/inventory_datasource.dart';
import '../features/inventory/data/repositories/inventory_repository_impl.dart';
import '../features/inventory/domain/repositories/inventory_repository.dart' as inventory_domain;
import '../features/inventory/presentation/controllers/inventory_controller.dart';

/// Dependency injection setup
/// 
/// This file contains all Riverpod providers for dependency injection.
/// Providers are organized by feature/domain area.

// ============================================================================
// Recipes Feature Providers
// ============================================================================

/// Recipe data source provider
final recipeDataSourceProvider = Provider<RecipeDataSource>((ref) {
  return RecipeDataSource(RecipeStore.instance);
});

/// Recipe repository provider
final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  final dataSource = ref.watch(recipeDataSourceProvider);
  return RecipeRepositoryImpl(dataSource);
});

/// Recipe controller provider
final recipeControllerProvider =
    StateNotifierProvider<RecipeController, RecipeListState>((ref) {
  final repository = ref.watch(recipeRepositoryProvider);
  return RecipeController(repository);
});

// ============================================================================
// Shopping List Feature Providers
// ============================================================================

/// Shopping list data source provider
final shoppingListDataSourceProvider = Provider<ShoppingListDataSource>((ref) {
  return ShoppingListDataSource();
});

/// Shopping list repository provider
final shoppingListRepositoryProvider = Provider<shopping_list_domain.ShoppingListRepository>((ref) {
  final dataSource = ref.watch(shoppingListDataSourceProvider);
  return ShoppingListRepositoryImpl(dataSource);
});

/// Shopping list controller provider
final shoppingListControllerProvider =
    StateNotifierProvider<ShoppingListController, ShoppingListState>((ref) {
  final repository = ref.watch(shoppingListRepositoryProvider);
  return ShoppingListController(repository);
});

// ============================================================================
// Meal Planning Feature Providers
// ============================================================================

/// Meal plan data source provider
final mealPlanDataSourceProvider = Provider<MealPlanDataSource>((ref) {
  return MealPlanDataSource();
});

/// Meal plan repository provider
final mealPlanRepositoryProvider = Provider<meal_plan_domain.MealPlanRepository>((ref) {
  final dataSource = ref.watch(mealPlanDataSourceProvider);
  return MealPlanRepositoryImpl(dataSource);
});

/// Meal plan controller provider
final mealPlanControllerProvider =
    StateNotifierProvider<MealPlanController, MealPlanState>((ref) {
  final repository = ref.watch(mealPlanRepositoryProvider);
  return MealPlanController(repository);
});

// ============================================================================
// Inventory Feature Providers
// ============================================================================

/// Inventory data source provider
final inventoryDataSourceProvider = Provider<InventoryDataSource>((ref) {
  return InventoryDataSource();
});

/// Inventory repository provider
final inventoryRepositoryProvider = Provider<inventory_domain.InventoryRepository>((ref) {
  final dataSource = ref.watch(inventoryDataSourceProvider);
  return InventoryRepositoryImpl(dataSource);
});

/// Inventory controller provider
final inventoryControllerProvider =
    StateNotifierProvider<InventoryController, InventoryState>((ref) {
  final repository = ref.watch(inventoryRepositoryProvider);
  return InventoryController(repository);
});

