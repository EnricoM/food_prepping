import 'dart:convert';
import 'dart:io';

import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackupService {
  BackupService._();
  static final BackupService instance = BackupService._();

  static const String _keyLastBackup = 'last_backup_timestamp';
  static const String _keyAutoBackupEnabled = 'auto_backup_enabled';
  static const String _keyBackupIntervalDays = 'backup_interval_days';

  bool _autoBackupEnabled = false;
  int _backupIntervalDays = 7;
  DateTime? _lastBackup;

  bool get autoBackupEnabled => _autoBackupEnabled;
  int get backupIntervalDays => _backupIntervalDays;
  DateTime? get lastBackup => _lastBackup;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _autoBackupEnabled = prefs.getBool(_keyAutoBackupEnabled) ?? false;
    _backupIntervalDays = prefs.getInt(_keyBackupIntervalDays) ?? 7;
    final lastBackupTimestamp = prefs.getInt(_keyLastBackup);
    if (lastBackupTimestamp != null) {
      _lastBackup = DateTime.fromMillisecondsSinceEpoch(lastBackupTimestamp);
    }
  }

  Future<void> setAutoBackupEnabled(bool enabled) async {
    _autoBackupEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoBackupEnabled, enabled);
  }

  Future<void> setBackupIntervalDays(int days) async {
    _backupIntervalDays = days;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyBackupIntervalDays, days);
  }

  /// Export all app data to a JSON file
  Future<File> exportToFile() async {
    final recipes = AppRepositories.instance.recipes.getAll();
    final mealPlansMap = AppRepositories.instance.mealPlans.asMap();
    final mealPlans = mealPlansMap.values.toList();
    // Get shopping list from stream
    final shoppingList = await AppRepositories.instance.shoppingList.watchAll().first;
    final inventory = AppRepositories.instance.inventory.getAll();

    final backupData = {
      'version': '1.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'recipes': recipes.map((e) => _recipeEntityToJson(e)).toList(),
      'mealPlans': mealPlans.map((e) => _mealPlanToJson(e)).toList(),
      'shoppingList': shoppingList.map((e) => _shoppingListItemToJson(e)).toList(),
      'inventory': inventory.map((e) => _inventoryItemToJson(e)).toList(),
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
    final fileName = 'recipe_keeper_backup_$timestamp.json';

    // Save to Downloads folder on Android, Documents on iOS
    Directory? directory;
    if (Platform.isAndroid) {
      directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        // Fallback to app documents directory
        directory = await getApplicationDocumentsDirectory();
      }
    } else if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    final file = File('${directory.path}/$fileName');
    await file.writeAsString(jsonString);

    // Update last backup timestamp
    final prefs = await SharedPreferences.getInstance();
    _lastBackup = DateTime.now();
    await prefs.setInt(_keyLastBackup, _lastBackup!.millisecondsSinceEpoch);

    return file;
  }

  /// Import data from a JSON file
  Future<void> importFromFile(File file) async {
    final jsonString = await file.readAsString();
    final backupData = jsonDecode(jsonString) as Map<String, dynamic>;

    // Import recipes
    if (backupData['recipes'] != null) {
      final recipes = (backupData['recipes'] as List)
          .map((e) => _recipeEntityFromJson(e as Map<String, dynamic>))
          .toList();
      
      for (final entity in recipes) {
        try {
          final recipe = entity.toRecipe();
          final parseResult = RecipeParseResult(
            recipe: recipe,
            strategy: entity.strategy,
          );
          await AppRepositories.instance.recipes.saveParsedRecipe(
            result: parseResult,
            url: entity.url,
          );
          // Restore favorite status if it was a favorite
          final currentEntity = AppRepositories.instance.recipes.entityFor(entity.url);
          if (entity.isFavorite && (currentEntity?.isFavorite != true)) {
            await AppRepositories.instance.recipes.toggleFavorite(entity.url);
          }
        } catch (e) {
          debugPrint('Error importing recipe ${entity.url}: $e');
        }
      }
    }

    // Import meal plans
    if (backupData['mealPlans'] != null) {
      final mealPlans = (backupData['mealPlans'] as List)
          .map((e) => _mealPlanFromJson(e as Map<String, dynamic>))
          .toList();
      
      for (final dayEntity in mealPlans) {
        try {
          // Import meals for each day
          for (final slot in MealSlot.values) {
            final recipeUrls = dayEntity.meals[slot];
            if (recipeUrls != null && recipeUrls.isNotEmpty) {
              for (final url in recipeUrls) {
                await AppRepositories.instance.mealPlans.addMeal(
                  date: dayEntity.date,
                  slot: slot,
                  recipeUrl: url,
                );
              }
            }
          }
          // Import notes
          final notes = dayEntity.notes;
          if (notes != null && notes.isNotEmpty) {
            await AppRepositories.instance.mealPlans.setNotes(
              date: dayEntity.date,
              notes: notes,
            );
          }
        } catch (e) {
          debugPrint('Error importing meal plan for ${dayEntity.date}: $e');
        }
      }
    }

    // Import shopping list
    if (backupData['shoppingList'] != null) {
      final items = (backupData['shoppingList'] as List)
          .map((e) => _shoppingListItemFromJson(e as Map<String, dynamic>))
          .toList();
      
      if (items.isNotEmpty) {
        // Clear existing shopping list first
        await AppRepositories.instance.shoppingList.clearAll();
        await AppRepositories.instance.shoppingList.addItems(items);
      }
    }

    // Import inventory
    if (backupData['inventory'] != null) {
      final items = (backupData['inventory'] as List)
          .map((e) => _inventoryItemFromJson(e as Map<String, dynamic>))
          .toList();
      
      for (final item in items) {
        try {
          await AppRepositories.instance.inventory.addItem(item);
        } catch (e) {
          debugPrint('Error importing inventory item ${item.name}: $e');
        }
      }
    }
  }

  /// Check if automatic backup is needed and perform it
  Future<bool> checkAndPerformAutoBackup() async {
    if (!_autoBackupEnabled) {
      return false;
    }

    if (_lastBackup == null) {
      // First backup
      try {
        await exportToFile();
        return true;
      } catch (e) {
        debugPrint('Error performing automatic backup: $e');
        return false;
      }
    }

    final daysSinceLastBackup = DateTime.now().difference(_lastBackup!).inDays;
    if (daysSinceLastBackup >= _backupIntervalDays) {
      try {
        await exportToFile();
        return true;
      } catch (e) {
        debugPrint('Error performing automatic backup: $e');
        return false;
      }
    }

    return false;
  }

  // JSON serialization helpers
  Map<String, dynamic> _recipeEntityToJson(RecipeEntity entity) {
    return {
      'url': entity.url,
      'title': entity.title,
      'sourceUrl': entity.sourceUrl,
      'strategy': entity.strategy,
      'isFavorite': entity.isFavorite,
      'cachedAt': entity.cachedAt.toIso8601String(),
      'continent': entity.continent,
      'country': entity.country,
      'diet': entity.diet,
      'course': entity.course,
      'recipe': _recipeToJson(entity.toRecipe()),
    };
  }

  RecipeEntity _recipeEntityFromJson(Map<String, dynamic> json) {
    final recipe = _recipeFromJson(json['recipe'] as Map<String, dynamic>);
    final entity = RecipeEntity.fromRecipe(
      recipe,
      url: json['url'] as String,
      strategy: json['strategy'] as String? ?? 'unknown',
    );
    // Note: We can't set cachedAt directly, but we can restore other properties
    return entity.copyWith(
      isFavorite: json['isFavorite'] as bool? ?? false,
      continent: json['continent'] as String?,
      country: json['country'] as String?,
      diet: json['diet'] as String?,
      course: json['course'] as String?,
    );
  }

  Map<String, dynamic> _recipeToJson(Recipe recipe) {
    return {
      'title': recipe.title,
      'description': recipe.description,
      'sourceUrl': recipe.sourceUrl,
      'imageUrl': recipe.imageUrl,
      'author': recipe.author,
      'prepTime': recipe.prepTime?.inSeconds,
      'cookTime': recipe.cookTime?.inSeconds,
      'totalTime': recipe.totalTime?.inSeconds,
      'yield': recipe.yield,
      'ingredients': recipe.ingredientStrings,
      'instructions': recipe.instructions,
      'metadata': recipe.metadata,
    };
  }

  Recipe _recipeFromJson(Map<String, dynamic> json) {
    return Recipe(
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      sourceUrl: json['sourceUrl'] as String?,
      imageUrl: json['imageUrl'] as String?,
      author: json['author'] as String?,
      prepTime: json['prepTime'] != null
          ? Duration(seconds: json['prepTime'] as int)
          : null,
      cookTime: json['cookTime'] != null
          ? Duration(seconds: json['cookTime'] as int)
          : null,
      totalTime: json['totalTime'] != null
          ? Duration(seconds: json['totalTime'] as int)
          : null,
      yield: json['yield'] as String?,
      ingredientStrings: (json['ingredients'] as List?)
              ?.map((i) => i as String)
              .toList() ??
          [],
      instructions: (json['instructions'] as List?)
              ?.map((i) => i as String)
              .toList() ??
          [],
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? {},
    );
  }

  Map<String, dynamic> _mealPlanToJson(MealPlanDayEntity entity) {
    return {
      'date': entity.date.toIso8601String(),
      'meals': {
        for (final slot in MealSlot.values)
          slot.toString(): entity.meals[slot] ?? [],
      },
      'notes': entity.notes,
    };
  }

  MealPlanDayEntity _mealPlanFromJson(Map<String, dynamic> json) {
    final date = DateTime.parse(json['date'] as String);
    final meals = <MealSlot, List<String>>{};
    final mealsMap = json['meals'] as Map<String, dynamic>;
    for (final slot in MealSlot.values) {
      final urls = (mealsMap[slot.toString()] as List?)
              ?.map((u) => u as String)
              .toList() ??
          [];
      if (urls.isNotEmpty) {
        meals[slot] = urls;
      }
    }
    return MealPlanDayEntity(
      date: date,
      meals: meals,
      notes: json['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> _shoppingListItemToJson(ShoppingListItem item) {
    return {
      'ingredient': item.ingredient,
      'note': item.note,
      'recipeTitle': item.recipeTitle,
      'recipeUrl': item.recipeUrl,
      'isChecked': item.isChecked,
      'addedAt': item.addedAt.toIso8601String(),
    };
  }

  ShoppingListItem _shoppingListItemFromJson(Map<String, dynamic> json) {
    return ShoppingListItem(
      ingredient: json['ingredient'] as String? ?? '',
      note: json['note'] as String?,
      recipeTitle: json['recipeTitle'] as String?,
      recipeUrl: json['recipeUrl'] as String?,
      isChecked: json['isChecked'] as bool? ?? false,
      addedAt: json['addedAt'] != null
          ? DateTime.parse(json['addedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> _inventoryItemToJson(InventoryItem item) {
    return {
      'name': item.name,
      'quantity': item.quantity,
      'unit': item.unit,
      'category': item.category,
      'location': item.location,
      'note': item.note,
      'expiry': item.expiry?.toIso8601String(),
      'costPerUnit': item.costPerUnit,
      'isLowStock': item.isLowStock,
      'addedAt': item.addedAt.toIso8601String(),
      'updatedAt': item.updatedAt.toIso8601String(),
    };
  }

  InventoryItem _inventoryItemFromJson(Map<String, dynamic> json) {
    return InventoryItem(
      name: json['name'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String?,
      category: json['category'] as String?,
      location: json['location'] as String?,
      note: json['note'] as String?,
      expiry: json['expiry'] != null
          ? DateTime.parse(json['expiry'] as String)
          : null,
      costPerUnit: (json['costPerUnit'] as num?)?.toDouble(),
      isLowStock: json['isLowStock'] as bool? ?? false,
      addedAt: json['addedAt'] != null
          ? DateTime.parse(json['addedAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }
}

