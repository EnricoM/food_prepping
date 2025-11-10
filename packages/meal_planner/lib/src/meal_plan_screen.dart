import 'dart:async';

import 'package:collection/collection.dart';
import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_ui/shared_ui.dart';
import 'package:table_calendar/table_calendar.dart';

class MealPlanScreen extends StatefulWidget {
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
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateUtils.dateOnly(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meal planner')),
      drawer: widget.drawer,
      body: SafeArea(
        child: ValueListenableBuilder<Box<MealPlanDayEntity>>(
          valueListenable: MealPlanStore.instance.listenable(),
          builder: (context, box, _) {
            final plansByDay = MealPlanStore.instance.asMap();
            final selectedPlan = MealPlanStore.instance.dayFor(_selectedDay);
            final allRecipes = RecipeStore.instance.allEntities()
              ..sort(
                (a, b) =>
                    a.title.toLowerCase().compareTo(b.title.toLowerCase()),
              );

            final selectedBySlot = <MealSlot, List<RecipeEntity>>{};
            for (final entry in selectedPlan.meals.entries) {
              final recipesForSlot = <RecipeEntity>[];
              for (final url in entry.value) {
                final entity = RecipeStore.instance.entityFor(url);
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
              allRecipes,
              selectedBySlot,
              sharedIngredients,
            );

            return Column(
              children: [
                Card(
                  margin: const EdgeInsets.all(16),
                  child: TableCalendar<MealPlanDayEntity>(
                    firstDay: DateTime.now().subtract(
                      const Duration(days: 365 * 2),
                    ),
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
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.2),
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
                    child: _MealDayEditor(
                      key: ValueKey(_selectedDay),
                      day: selectedPlan,
                      allRecipes: allRecipes,
                      selectedRecipes: selectedBySlot,
                      sharedIngredients: sharedIngredients,
                      suggestions: suggestions,
                      onRecipeSelected: widget.onRecipeSelected,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
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
    Map<MealSlot, List<RecipeEntity>> selected,
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
      'and',
      'with',
      'fresh',
      'ground',
      'large',
      'small',
      'medium',
      'tablespoon',
      'tablespoons',
      'teaspoon',
      'teaspoons',
      'cup',
      'cups',
      'ounce',
      'ounces',
      'clove',
      'cloves',
      'gram',
      'grams',
      'ml',
      'ltr',
      'liter',
      'litre',
      'pinch',
      'tsp',
      'tbsp',
      'package',
      'packages',
      'optional',
      'sliced',
      'chopped',
      'minced',
      'diced',
      'whole',
      'of',
      'the',
      'a',
      'an',
      'or',
    };

    final tokens = <String>{};
    for (final ingredient in recipe.ingredients) {
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

class _MealDayEditor extends StatefulWidget {
  const _MealDayEditor({
    super.key,
    required this.day,
    required this.allRecipes,
    required this.selectedRecipes,
    required this.sharedIngredients,
    required this.suggestions,
    required this.onRecipeSelected,
  });

  final MealPlanDayEntity day;
  final List<RecipeEntity> allRecipes;
  final Map<MealSlot, List<RecipeEntity>> selectedRecipes;
  final Map<String, int> sharedIngredients;
  final List<RecipeEntity> suggestions;
  final void Function(BuildContext context, RecipeEntity entity) onRecipeSelected;

  @override
  State<_MealDayEditor> createState() => _MealDayEditorState();
}

class _MealDayEditorState extends State<_MealDayEditor> {
  late final TextEditingController _notesController;
  Timer? _notesDebounce;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.day.notes ?? '');
  }

  @override
  void didUpdateWidget(covariant _MealDayEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.day.notes ?? '') != (widget.day.notes ?? '')) {
      _notesController.text = widget.day.notes ?? '';
    }
  }

  @override
  void dispose() {
    _notesDebounce?.cancel();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final slots = MealSlot.values;
    return ListView(
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              onPressed: _copyPreviousDay,
              icon: const Icon(Icons.history_toggle_off),
              label: const Text('Reuse previous plan'),
            ),
            OutlinedButton.icon(
              onPressed: widget.day.isEmpty
                  ? null
                  : () => MealPlanStore.instance.deleteDay(widget.day.date),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Clear day'),
            ),
            OutlinedButton.icon(
              onPressed: widget.selectedRecipes.isEmpty
                  ? null
                  : _addToShoppingList,
              icon: const Icon(Icons.shopping_cart_outlined),
              label: const Text('Add to shopping list'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        for (final slot in slots)
          Builder(
            builder: (context) {
              final selectedUrls = widget.day.recipesFor(slot);
              return _MealSlotCard(
                slot: slot,
                recipes: widget.allRecipes,
                selectedRecipes: widget.selectedRecipes[slot] ?? const [],
                selectedUrls: selectedUrls,
                onAddRecipe: (value) => _addMeal(slot, value),
                onRemoveRecipe: (value) => _removeMeal(slot, value),
                onClear: selectedUrls.isEmpty ? null : () => _clearSlot(slot),
                onRecipeTap: (recipe) => widget.onRecipeSelected(context, recipe),
              );
            },
          ),
        const SizedBox(height: 16),
        TextField(
          controller: _notesController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Prep notes',
            hintText: 'Portioning, reheating instructions, shopping reminders…',
            border: OutlineInputBorder(),
          ),
          onChanged: _handleNotesChanged,
        ),
        if (widget.sharedIngredients.isNotEmpty) ...[
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Shared ingredients today',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.sharedIngredients.entries
                        .map(
                          (entry) => Chip(
                            label: Text(
                              '${_capitalize(entry.key)} • ${entry.value} meals',
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
        if (widget.suggestions.isNotEmpty) ...[
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Suggested additions for efficient prep',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  ...widget.suggestions.map(
                    (recipe) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(recipe.title),
                      subtitle: Text(
                        _ingredientsPreview(recipe),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        tooltip: 'Assign to first free slot',
                        onPressed: () => _assignSuggestion(recipe),
                      ),
                      onTap: () => widget.onRecipeSelected(context, recipe),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _copyPreviousDay() async {
    final previous = MealPlanStore.instance.copyPreviousAvailable(
      widget.day.date,
    );
    if (previous.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No earlier meal plans to copy yet.')),
      );
      return;
    }
    await MealPlanStore.instance.setMeals(
      date: widget.day.date,
      meals: previous.meals,
    );
    await MealPlanStore.instance.setNotes(
      date: widget.day.date,
      notes: previous.notes,
    );
  }

  Future<void> _addMeal(MealSlot slot, String recipeUrl) async {
    await MealPlanStore.instance.addMeal(
      date: widget.day.date,
      slot: slot,
      recipeUrl: recipeUrl,
    );
  }

  Future<void> _removeMeal(MealSlot slot, String recipeUrl) async {
    await MealPlanStore.instance.removeMeal(
      date: widget.day.date,
      slot: slot,
      recipeUrl: recipeUrl,
    );
  }

  Future<void> _clearSlot(MealSlot slot) async {
    await MealPlanStore.instance.setMeal(
      date: widget.day.date,
      slot: slot,
      recipeUrl: null,
    );
  }

  Future<void> _addToShoppingList() async {
    final messenger = ScaffoldMessenger.of(context);
    final recipes = widget.selectedRecipes.values.expand((r) => r).toList();
    if (recipes.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Select recipes first.')),
      );
      return;
    }
    await ShoppingListStore.instance.addIngredientsFromEntities(recipes);
    messenger.showSnackBar(
      SnackBar(
        content: Text('Added ingredients from ${recipes.length} recipe(s).'),
      ),
    );
  }

  void _handleNotesChanged(String value) {
    _notesDebounce?.cancel();
    _notesDebounce = Timer(const Duration(milliseconds: 500), () {
      MealPlanStore.instance.setNotes(
        date: widget.day.date,
        notes: value.trim().isEmpty ? null : value.trim(),
      );
    });
  }

  Future<void> _assignSuggestion(RecipeEntity recipe) async {
    for (final slot in MealSlot.values) {
      final assignedUrls = widget.day.recipesFor(slot);
      if (!assignedUrls.contains(recipe.url)) {
        await _addMeal(slot, recipe.url);
        return;
      }
    }
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All meal slots already include this recipe.'),
      ),
    );
  }

  String _ingredientsPreview(RecipeEntity recipe, {int maxCount = 3}) {
    return _ingredientsPreviewText(recipe.toRecipe(), maxCount: maxCount);
  }
}

class _MealSlotCard extends StatefulWidget {
  const _MealSlotCard({
    required this.slot,
    required this.recipes,
    required this.selectedRecipes,
    required this.selectedUrls,
    required this.onAddRecipe,
    required this.onRemoveRecipe,
    this.onClear,
    required this.onRecipeTap,
  });

  final MealSlot slot;
  final List<RecipeEntity> recipes;
  final List<RecipeEntity> selectedRecipes;
  final List<String> selectedUrls;
  final ValueChanged<String> onAddRecipe;
  final ValueChanged<String> onRemoveRecipe;
  final VoidCallback? onClear;
  final ValueChanged<RecipeEntity> onRecipeTap;

  @override
  State<_MealSlotCard> createState() => _MealSlotCardState();
}

class _MealSlotCardState extends State<_MealSlotCard> {
  late final TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lowerQuery = _searchQuery.toLowerCase();

    bool matchesQuery(RecipeEntity recipe) {
      if (lowerQuery.isEmpty) {
        return true;
      }
      if (recipe.title.toLowerCase().contains(lowerQuery)) {
        return true;
      }
      if ((recipe.description ?? '').toLowerCase().contains(lowerQuery)) {
        return true;
      }
      if (recipe.ingredients
          .any((ingredient) => ingredient.toLowerCase().contains(lowerQuery))) {
        return true;
      }
      if (recipe.normalizedCategories
          .any((category) => category.toLowerCase().contains(lowerQuery))) {
        return true;
      }
      return false;
    }

    final filteredRecipes = widget.recipes.where(matchesQuery).toList();
    final favouriteRecipes = filteredRecipes
        .where((recipe) => recipe.isFavorite)
        .toList(growable: false);
    final otherRecipes = filteredRecipes
        .where((recipe) => !recipe.isFavorite)
        .toList(growable: false);

    final dropdownItems = <DropdownMenuItem<String>>[];

    void addHeader(String label) {
      dropdownItems.add(
        DropdownMenuItem<String>(
          value: '__${widget.slot.name}_header_$label',
          enabled: false,
          child: Text(
            label,
            style: theme.textTheme.labelSmall
                ?.copyWith(color: theme.colorScheme.primary),
          ),
        ),
      );
    }

    void addRecipes(List<RecipeEntity> recipes) {
      dropdownItems.addAll(
        recipes.map(
          (recipe) => DropdownMenuItem<String>(
            value: recipe.url,
            enabled: !widget.selectedUrls.contains(recipe.url),
            child: Text(recipe.title),
          ),
        ),
      );
    }

    if (favouriteRecipes.isNotEmpty) {
      addHeader('Favourites');
      addRecipes(favouriteRecipes);
    }
    if (otherRecipes.isNotEmpty) {
      addHeader(favouriteRecipes.isEmpty ? 'All recipes' : 'All recipes');
      addRecipes(otherRecipes);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_slotIcon(widget.slot), color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _slotLabel(widget.slot),
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: 'Clear all for this slot',
                  onPressed: widget.onClear,
                  icon: const Icon(Icons.clear_all),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search recipes',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value.trim()),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              key: ValueKey(
                '${widget.slot.name}-${widget.selectedUrls.length}',
              ),
              items: dropdownItems,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Add recipe to this slot',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                if (value == null || widget.selectedUrls.contains(value)) {
                  return;
                }
                widget.onAddRecipe(value);
              },
              menuMaxHeight: 320,
            ),
            if (widget.selectedRecipes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Column(
                children: widget.selectedRecipes
                    .map(
                      (recipe) => Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 0,
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.3),
                        child: ListTile(
                          title: Text(recipe.title),
                          subtitle: Text(
                            _ingredientsPreview(recipe),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            tooltip: 'Remove from slot',
                            onPressed: () => widget.onRemoveRecipe(recipe.url),
                          ),
                          onTap: () => widget.onRecipeTap(recipe),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ] else
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'No recipes assigned yet.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withValues(
                      alpha: 0.7,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _ingredientsPreview(RecipeEntity entity, {int maxCount = 3}) {
    return _ingredientsPreviewText(entity.toRecipe(), maxCount: maxCount);
  }
}

String _slotLabel(MealSlot slot) {
  switch (slot) {
    case MealSlot.breakfast:
      return 'Breakfast';
    case MealSlot.lunch:
      return 'Lunch';
    case MealSlot.dinner:
      return 'Dinner';
    case MealSlot.snack:
      return 'Snack';
  }
}

IconData _slotIcon(MealSlot slot) {
  switch (slot) {
    case MealSlot.breakfast:
      return Icons.free_breakfast_outlined;
    case MealSlot.lunch:
      return Icons.lunch_dining_outlined;
    case MealSlot.dinner:
      return Icons.dinner_dining;
    case MealSlot.snack:
      return Icons.fastfood_outlined;
  }
}

String _capitalize(String value) {
  if (value.isEmpty) return value;
  return value[0].toUpperCase() + value.substring(1);
}

String _ingredientsPreviewText(Recipe recipe, {int maxCount = 3}) {
  final ingredients = recipe.ingredients;
  if (ingredients.isEmpty) {
    return 'No ingredients listed';
  }
  final preview = ingredients.take(maxCount).toList(growable: false);
  final remaining = ingredients.length - preview.length;
  final suffix = remaining > 0 ? ' +$remaining more' : '';
  return preview.join(', ') + suffix;
}
