import 'package:collection/collection.dart';
import 'package:data/data.dart' hide MealSlot;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_ui/shared_ui.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../app/di.dart';
import '../../../../src/navigation/app_drawer.dart';
import '../../../../src/widgets/back_aware_app_bar.dart';
import '../../../recipes/domain/models/recipe_model.dart';
import '../../domain/models/meal_plan_day_model.dart';
import '../../domain/models/meal_slot.dart' as domain;
import '../controllers/meal_plan_controller.dart';
import 'widgets/meal_plan_widgets.dart' as widgets;

/// Screen for managing meal plans
/// 
/// Uses Riverpod for state management and the new MealPlanController.
class MealPlanScreen extends ConsumerStatefulWidget {
  const MealPlanScreen({
    super.key,
    this.drawer,
    required this.onRecipeSelected,
    this.pageInsetsBuilder = responsivePageInsets,
  });

  static const routeName = '/meal-plan';

  final Widget? drawer;
  final void Function(BuildContext context, RecipeEntity entity) onRecipeSelected;
  final EdgeInsets Function(BuildContext context) pageInsetsBuilder;

  @override
  ConsumerState<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends ConsumerState<MealPlanScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateUtils.dateOnly(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final mealPlanState = ref.watch(mealPlanControllerProvider);
    final mealPlanController = ref.watch(mealPlanControllerProvider.notifier);
    final recipeListState = ref.watch(recipeControllerProvider);

    return Scaffold(
      appBar: const BackAwareAppBar(title: Text('Meal planner')),
      drawer: widget.drawer ?? const AppDrawer(currentRoute: MealPlanScreen.routeName),
      body: SafeArea(
        child: _buildContent(
          mealPlanState,
          mealPlanController,
          recipeListState.recipes,
        ),
      ),
    );
  }

  Widget _buildContent(
    MealPlanState mealPlanState,
    MealPlanController mealPlanController,
    List<RecipeModel> allRecipes,
  ) {
    if (mealPlanState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (mealPlanState.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                'Error loading meal plans',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                mealPlanState.error!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final plansByDay = mealPlanState.plansByDay;
    final selectedPlan = mealPlanController.dayFor(_selectedDay);

    // Convert RecipeModel to RecipeEntity for compatibility with existing widgets
    // TODO: Update widgets to use RecipeModel directly when fully migrated
    final allRecipeEntities = <RecipeEntity>[];
    for (final recipe in allRecipes) {
      final entity = AppRepositories.instance.recipes.entityFor(recipe.id);
      if (entity != null) {
        allRecipeEntities.add(entity);
      }
    }
    allRecipeEntities.sort(
      (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
    );

    final selectedBySlot = <domain.MealSlot, List<RecipeEntity>>{};
    for (final entry in selectedPlan.meals.entries) {
      final recipesForSlot = <RecipeEntity>[];
      for (final url in entry.value) {
        final entity = AppRepositories.instance.recipes.entityFor(url);
        if (entity != null) {
          recipesForSlot.add(entity);
        }
      }
      if (recipesForSlot.isNotEmpty) {
        selectedBySlot[entry.key] = recipesForSlot;
      }
    }

    final sharedIngredients = _sharedIngredientCounts(
      selectedBySlot.values.expand((recipes) => recipes),
    );
    final suggestions = _recommendedRecipes(
      allRecipeEntities,
      selectedBySlot,
      sharedIngredients,
    );

    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(16),
          child: TableCalendar<MealPlanDayModel>(
            firstDay: DateTime.now().subtract(const Duration(days: 365 * 2)),
            lastDay: DateTime.now().add(const Duration(days: 365 * 5)),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = DateUtils.dateOnly(selectedDay);
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() => _calendarFormat = format);
            },
            eventLoader: (day) {
              final normalized = DateUtils.dateOnly(day);
              final entity = plansByDay[normalized];
              if (entity == null || entity.isEmpty) return const [];
              return [entity];
            },
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                shape: BoxShape.circle,
              ),
              markersAlignment: Alignment.bottomRight,
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: widget.pageInsetsBuilder(context).copyWith(top: 0),
            child: widgets.MealDayEditor(
              key: ValueKey(_selectedDay),
              day: selectedPlan,
              allRecipes: allRecipeEntities,
              selectedRecipes: selectedBySlot,
              sharedIngredients: sharedIngredients,
              suggestions: suggestions,
              onRecipeSelected: widget.onRecipeSelected,
              mealPlanController: mealPlanController,
            ),
          ),
        ),
      ],
    );
  }

  Map<String, int> _sharedIngredientCounts(Iterable<RecipeEntity> recipes) {
    final counts = <String, int>{};
    for (final recipe in recipes) {
      final tokens = _ingredientTokens(recipe);
      for (final token in tokens) {
        counts[token] = (counts[token] ?? 0) + 1;
      }
    }
    final filtered = counts.entries.where((entry) => entry.value > 1).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(filtered);
  }

  List<RecipeEntity> _recommendedRecipes(
    List<RecipeEntity> allRecipes,
    Map<domain.MealSlot, List<RecipeEntity>> selected,
    Map<String, int> sharedIngredients,
  ) {
    final used = <String>{};
    for (final list in selected.values) {
      used.addAll(list.map((recipe) => recipe.url));
    }
    final priorityTokens = sharedIngredients.entries.map((e) => e.key).toList();
    if (priorityTokens.isEmpty && selected.isNotEmpty) {
      final firstList = selected.values.first;
      if (firstList.isNotEmpty) {
        priorityTokens.addAll(_ingredientTokens(firstList.first));
      }
    }
    if (priorityTokens.isEmpty) {
      final aggregate = <String, int>{};
      for (final recipe in allRecipes.take(10)) {
        for (final token in _ingredientTokens(recipe)) {
          aggregate[token] = (aggregate[token] ?? 0) + 1;
        }
      }
      priorityTokens.addAll(
        aggregate.entries
            .sorted((a, b) => b.value.compareTo(a.value))
            .map((e) => e.key)
            .take(3),
      );
    }

    final suggestions = <RecipeEntity>[];
    for (final recipe in allRecipes) {
      if (used.contains(recipe.url)) continue;
      final tokens = _ingredientTokens(recipe);
      if (priorityTokens.any(tokens.contains)) {
        suggestions.add(recipe);
      }
      if (suggestions.length >= 6) break;
    }
    return suggestions;
  }

  Set<String> _ingredientTokens(RecipeEntity recipe) {
    const stopWords = {
      'and', 'with', 'fresh', 'ground', 'large', 'small', 'medium',
      'tablespoon', 'tablespoons', 'teaspoon', 'teaspoons', 'cup', 'cups',
      'ounce', 'ounces', 'clove', 'cloves', 'gram', 'grams', 'ml', 'ltr',
      'liter', 'litre', 'pinch', 'tsp', 'tbsp', 'package', 'packages',
      'optional', 'sliced', 'chopped', 'minced', 'diced', 'whole', 'of',
      'the', 'a', 'an', 'or',
    };

    final tokens = <String>{};
    for (final ingredient in recipe.ingredientStrings) {
      final words = ingredient
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z\s]'), ' ')
          .split(RegExp(r'\s+'))
          .where((word) => word.isNotEmpty && !stopWords.contains(word))
          .toList();
      if (words.isEmpty) continue;
      tokens.add(words.first);
      if (words.length > 1) {
        tokens.add(words[1]);
      }
    }
    return tokens;
  }
}

