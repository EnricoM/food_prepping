import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di.dart';
import '../../../../src/services/measurement_preferences.dart';
import '../../../../src/utils/countries.dart';
import '../../../../src/utils/ingredient_converter.dart';
import '../../../../src/widgets/ad_banner.dart';
import '../../../../src/widgets/back_aware_app_bar.dart';
import 'edit_recipe_screen.dart' as edit_recipe_screen;
import '../../../../src/screens/settings_screen.dart';
import '../../domain/models/recipe_model.dart';
import '../utils/recipe_navigation.dart';
import '../widgets/network_image_with_fallback.dart';

/// Arguments for RecipeDetailScreen
class RecipeDetailArgs {
  const RecipeDetailArgs({required this.recipe});

  final RecipeModel recipe;
}

/// Screen displaying recipe details with tabs
/// 
/// Uses Riverpod for state management and the new RecipeController.
class RecipeDetailScreen extends ConsumerWidget {
  const RecipeDetailScreen({super.key, required this.args});

  static const routeName = '/recipe-detail';

  final RecipeDetailArgs args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipeModel = args.recipe;
    final recipe = RecipeNavigation.toRecipe(recipeModel);
    final controller = ref.watch(recipeControllerProvider.notifier);
    final repository = ref.watch(recipeRepositoryProvider);

    // Get the full recipe model (with updated favorite status)
    final currentRecipe = repository.getById(recipeModel.id) ?? recipeModel;

    final tabs = const [
      Tab(icon: Icon(Icons.dashboard_outlined), text: 'Overview'),
      Tab(icon: Icon(Icons.list_alt_outlined), text: 'Ingredients'),
      Tab(icon: Icon(Icons.receipt_long_outlined), text: 'Preparation'),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: BackAwareAppBar(
          title: Text(recipeModel.title),
          actions: [
            IconButton(
              tooltip: 'Add ingredients to shopping list',
              icon: const Icon(Icons.shopping_cart_outlined),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                // TODO: When shopping list is migrated, use new architecture
                // For now, use old repository
                await AppRepositories.instance.shoppingList
                    .addIngredientsFromRecipe(recipe);
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Recipe ingredients added to shopping list.'),
                  ),
                );
              },
            ),
            IconButton(
              tooltip: 'Edit filters',
              icon: const Icon(Icons.filter_list),
              onPressed: () => _showFilterDialog(context, ref, currentRecipe),
            ),
            IconButton(
              tooltip: currentRecipe.isFavorite
                  ? 'Remove favourite'
                  : 'Add to favourites',
              icon: Icon(
                currentRecipe.isFavorite ? Icons.star : Icons.star_border,
                color: currentRecipe.isFavorite
                    ? Theme.of(context).colorScheme.onPrimary
                    : null,
              ),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final becomingFavorite = !currentRecipe.isFavorite;
                await controller.toggleFavorite(currentRecipe.id);
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      becomingFavorite
                          ? 'Added to favourites'
                          : 'Removed from favourites',
                    ),
                  ),
                );
              },
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditRecipe(context, recipe, currentRecipe);
                } else if (value == 'delete') {
                  _showDeleteConfirmation(context, ref, currentRecipe);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined),
                      SizedBox(width: 8),
                      Text('Edit recipe'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete recipe', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _OverviewTab(recipe: recipe, recipeModel: currentRecipe),
            _IngredientsTab(recipe: recipe, recipeModel: currentRecipe),
            _InstructionsTab(instructions: recipe.instructions, recipe: recipe),
          ],
        ),
        bottomNavigationBar: Material(
          elevation: 6,
          color: Theme.of(context).colorScheme.surface,
          child: SafeArea(
            top: false,
            child: TabBar(
              tabs: tabs,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor:
                  Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ),
      ),
    );
  }

  static void _showFilterDialog(
    BuildContext context,
    WidgetRef ref,
    RecipeModel recipeModel,
  ) {
    showDialog(
      context: context,
      builder: (context) => _FilterEditDialog(recipe: recipeModel, ref: ref),
    );
  }

  static void _showEditRecipe(
    BuildContext context,
    Recipe recipe,
    RecipeModel recipeModel,
  ) {
    // Use the new EditRecipeScreen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => edit_recipe_screen.EditRecipeScreen(recipe: recipeModel),
      ),
    );
  }

  static void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    RecipeModel recipeModel,
  ) {
    final controller = ref.read(recipeControllerProvider.notifier);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recipe'),
        content: Text(
          'Are you sure you want to delete "${recipeModel.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await controller.delete(recipeModel.id);
              if (context.mounted) {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to previous screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Recipe deleted')),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.recipe, required this.recipeModel});

  final Recipe recipe;
  final RecipeModel recipeModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty)
            NetworkImageWithFallback(
              imageUrl: recipe.imageUrl!,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
              borderRadius: BorderRadius.circular(20),
            ),
          const SizedBox(height: 16),
          Text(
            recipe.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (recipe.description != null && recipe.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(recipe.description!),
            ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              if (recipe.yield != null)
                _InfoChip(icon: Icons.restaurant, label: recipe.yield!),
              if (recipe.prepTime != null)
                _InfoChip(
                  icon: Icons.timer_outlined,
                  label: 'Prep ${recipe.prepTime!.inMinutes} min',
                ),
              if (recipe.cookTime != null)
                _InfoChip(
                  icon: Icons.local_fire_department_outlined,
                  label: 'Cook ${recipe.cookTime!.inMinutes} min',
                ),
              if (recipe.totalTime != null)
                _InfoChip(
                  icon: Icons.schedule,
                  label: 'Total ${recipe.totalTime!.inMinutes} min',
                ),
              if (recipeModel.country != null)
                _InfoChip(icon: Icons.public, label: recipeModel.country!),
              if (recipeModel.continent != null)
                _InfoChip(icon: Icons.map_outlined, label: recipeModel.continent!),
              if (recipeModel.diet != null)
                _InfoChip(icon: Icons.restaurant_menu, label: recipeModel.diet!),
              if (recipeModel.course != null)
                _InfoChip(icon: Icons.lunch_dining, label: recipeModel.course!),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              // TODO: When shopping list is migrated, use new architecture
              // For now, use old repository
              await AppRepositories.instance.shoppingList
                  .addIngredientsFromRecipe(recipe);
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Recipe ingredients added to shopping list.'),
                ),
              );
            },
            icon: const Icon(Icons.shopping_cart_outlined),
            label: const Text('Add ingredients to shopping list'),
          ),
          const SizedBox(height: 16),
          _NutritionCard(recipe: recipe, recipeModel: recipeModel),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Highlights', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Text(_ingredientsPreview(recipe)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _ingredientsPreview(Recipe recipe) {
    if (recipe.ingredients.isEmpty) return 'No ingredients listed';
    if (recipe.ingredients.length <= 3) {
      return recipe.ingredients.join(', ');
    }
    return '${recipe.ingredients.take(3).join(', ')}, +${recipe.ingredients.length - 3} more';
  }
}

class _IngredientsTab extends StatefulWidget {
  const _IngredientsTab({required this.recipe, required this.recipeModel});

  final Recipe recipe;
  final RecipeModel recipeModel;

  @override
  State<_IngredientsTab> createState() => _IngredientsTabState();
}

class _IngredientsTabState extends State<_IngredientsTab> {
  int? _targetServings;
  ScaledRecipe? _scaledRecipe;
  late final TextEditingController _servingsController;

  @override
  void initState() {
    super.initState();
    final originalServings = _extractServings(widget.recipe);
    _targetServings = originalServings;
    _servingsController = TextEditingController(
      text: originalServings.toString(),
    );
  }

  @override
  void dispose() {
    _servingsController.dispose();
    super.dispose();
  }

  int? _extractServings(Recipe recipe) {
    if (recipe.servings != null) {
      final match = RegExp(r'(\d+)').firstMatch(recipe.servings!);
      if (match != null) {
        return int.tryParse(match.group(1) ?? '');
      }
    }
    if (recipe.yield != null) {
      final match = RegExp(r'(\d+)').firstMatch(recipe.yield!);
      if (match != null) {
        return int.tryParse(match.group(1) ?? '');
      }
    }
    return 4; // Default
  }

  void _updateScaling(int? servings) {
    setState(() {
      _targetServings = servings;
      if (servings != null && servings > 0) {
        final originalServings = _extractServings(widget.recipe);
        _scaledRecipe = RecipeScaler.scaleRecipe(
          recipe: widget.recipe,
          targetServings: servings,
          originalServings: originalServings,
        );
        if (_servingsController.text != servings.toString()) {
          _servingsController.text = servings.toString();
        }
      } else {
        _scaledRecipe = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final originalServings = _extractServings(widget.recipe);
    final displayIngredients = _scaledRecipe?.scaledIngredients ?? widget.recipe.ingredients;

    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.scale_outlined, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Text(
                      'Scale Recipe',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        originalServings != null
                            ? 'Original: $originalServings servings'
                            : 'Servings: ${originalServings ?? 4}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 100,
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Servings',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        keyboardType: TextInputType.number,
                        controller: _servingsController,
                        onChanged: (value) {
                          final servings = int.tryParse(value);
                          if (servings != null) {
                            _updateScaling(servings);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                if (_scaledRecipe != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Scaled ${_scaledRecipe!.scaleFactorLabel} (${_scaledRecipe!.targetServings} servings)',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [2, 4, 6, 8, 12].map((servings) {
                    return ChoiceChip(
                      label: Text('${servings}x'),
                      selected: _targetServings == servings,
                      onSelected: (selected) {
                        if (selected) {
                          _updateScaling(servings);
                        } else {
                          _updateScaling(originalServings);
                        }
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        AnimatedBuilder(
          animation: MeasurementPreferences.instance,
          builder: (context, _) {
            final measurementSystem = MeasurementPreferences.instance.system;
            final converter = IngredientConverter(measurementSystem);
            final convertedIngredients = displayIngredients
                .map(converter.convert)
                .toList(growable: false);
            final isScaled = _scaledRecipe != null;
            return Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Icon(
                          Icons.straighten_outlined,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Showing ${measurementSystem.displayName}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context)
                              .pushNamed(SettingsScreen.routeName),
                          child: const Text('Change'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: convertedIngredients.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final ingredient = convertedIngredients[index];
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '• ',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isScaled
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                ingredient,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: isScaled
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurface,
                                  fontWeight: isScaled
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        const AdBanner(),
      ],
    );
  }
}

class _InstructionsTab extends StatelessWidget {
  const _InstructionsTab({required this.instructions, required this.recipe});

  final List<String> instructions;
  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final prepAheadSteps = _getPrepAheadSteps();

    if (instructions.isEmpty) {
      return const Center(
        child: Text('Preparation steps were not provided for this recipe.'),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        if (prepAheadSteps.isNotEmpty) ...[
          Card(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_outlined,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Prep Ahead',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'These steps can be done ahead of time to save you time on cooking day:',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  ...prepAheadSteps.map((step) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              step,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
        ...instructions.asMap().entries.map((entry) {
          final index = entry.key;
          final instruction = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(instruction),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  List<String> _getPrepAheadSteps() {
    final prepKeywords = [
      'chop',
      'dice',
      'slice',
      'mince',
      'grate',
      'peel',
      'marinate',
      'soak',
      'mix',
      'combine',
      'whisk',
      'prepare',
      'cut',
      'trim',
      'clean',
      'wash',
      'dry',
    ];

    final prepAhead = <String>[];
    for (final instruction in instructions) {
      final lower = instruction.toLowerCase();
      if (prepKeywords.any((keyword) => lower.contains(keyword)) &&
          !lower.contains('cook') &&
          !lower.contains('bake') &&
          !lower.contains('fry') &&
          !lower.contains('boil') &&
          !lower.contains('simmer') &&
          !lower.contains('heat') &&
          !lower.contains('warm')) {
        prepAhead.add(instruction);
      }
    }

    return prepAhead;
  }
}

class _NutritionCard extends StatelessWidget {
  const _NutritionCard({required this.recipe, required this.recipeModel});

  final Recipe recipe;
  final RecipeModel recipeModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // TODO: When NutritionService is migrated, use RecipeModel directly
    // For now, convert to RecipeEntity for compatibility
    // Use old repository to get entity
    final oldRepository = AppRepositories.instance.recipes;
    final entity = oldRepository.entityFor(recipeModel.id);
    final nutrition = entity != null
        ? NutritionService.getNutritionInfoForEntity(entity)
        : NutritionService.getNutritionInfo(recipe);

    if (nutrition == null || !nutrition.hasData) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Nutrition',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (nutrition.calories != null) ...[
              _NutritionRow(
                label: 'Calories',
                value: '${nutrition.calories!.toStringAsFixed(0)} kcal',
                perServing: nutrition.caloriesPerServing != null
                    ? '${nutrition.caloriesPerServing!.toStringAsFixed(0)} kcal/serving'
                    : null,
                color: Colors.orange,
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                if (nutrition.protein != null)
                  Expanded(
                    child: _NutritionMacro(
                      label: 'Protein',
                      value: '${nutrition.protein!.toStringAsFixed(1)}g',
                      perServing: nutrition.proteinPerServing != null
                          ? '${nutrition.proteinPerServing!.toStringAsFixed(1)}g'
                          : null,
                      color: Colors.blue,
                    ),
                  ),
                if (nutrition.carbohydrates != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _NutritionMacro(
                      label: 'Carbs',
                      value: '${nutrition.carbohydrates!.toStringAsFixed(1)}g',
                      perServing: nutrition.carbohydratesPerServing != null
                          ? '${nutrition.carbohydratesPerServing!.toStringAsFixed(1)}g'
                          : null,
                      color: Colors.green,
                    ),
                  ),
                ],
                if (nutrition.fat != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _NutritionMacro(
                      label: 'Fat',
                      value: '${nutrition.fat!.toStringAsFixed(1)}g',
                      perServing: nutrition.fatPerServing != null
                          ? '${nutrition.fatPerServing!.toStringAsFixed(1)}g'
                          : null,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ],
            ),
            if (nutrition.fiber != null ||
                nutrition.sugar != null ||
                nutrition.sodium != null) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  if (nutrition.fiber != null)
                    _NutritionDetail(
                      label: 'Fiber',
                      value: '${nutrition.fiber!.toStringAsFixed(1)}g',
                    ),
                  if (nutrition.sugar != null)
                    _NutritionDetail(
                      label: 'Sugar',
                      value: '${nutrition.sugar!.toStringAsFixed(1)}g',
                    ),
                  if (nutrition.sodium != null)
                    _NutritionDetail(
                      label: 'Sodium',
                      value: '${(nutrition.sodium! / 1000).toStringAsFixed(1)}g',
                    ),
                ],
              ),
            ],
            if (!nutrition.hasCompleteData) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Estimated nutrition values',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NutritionRow extends StatelessWidget {
  const _NutritionRow({
    required this.label,
    required this.value,
    this.perServing,
    required this.color,
  });

  final String label;
  final String value;
  final String? perServing;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            if (perServing != null)
              Text(
                perServing!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _NutritionMacro extends StatelessWidget {
  const _NutritionMacro({
    required this.label,
    required this.value,
    this.perServing,
    required this.color,
  });

  final String label;
  final String value;
  final String? perServing;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          if (perServing != null) ...[
            const SizedBox(height: 2),
            Text(
              perServing!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: color.withValues(alpha: 0.7),
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NutritionDetail extends StatelessWidget {
  const _NutritionDetail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: theme.textTheme.bodySmall,
        ),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

class _FilterEditDialog extends ConsumerStatefulWidget {
  const _FilterEditDialog({required this.recipe, required this.ref});

  final RecipeModel recipe;
  final WidgetRef ref;

  @override
  ConsumerState<_FilterEditDialog> createState() => _FilterEditDialogState();
}

class _FilterEditDialogState extends ConsumerState<_FilterEditDialog> {
  late String? _selectedContinent;
  late String? _selectedCountry;
  late String? _selectedDiet;
  late String? _selectedCourse;

  static const List<String> _continents = [
    'Africa',
    'Asia',
    'Europe',
    'North America',
    'Oceania',
    'South America',
  ];

  // Use comprehensive list of all countries for editing filters
  List<String> get _countries => List<String>.from(allCountries)..sort();

  static const List<String> _diets = [
    'Vegetarian',
    'Vegan',
    'Pescatarian',
    'Gluten-Free',
    'Dairy-Free',
    'Keto',
    'Paleo',
    'Low-Carb',
    'Halal',
    'Kosher',
  ];

  static const List<String> _courses = [
    'Appetizer',
    'Main Course',
    'Dessert',
    'Side Dish',
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snack',
    'Beverage',
    'Soup',
    'Salad',
  ];

  @override
  void initState() {
    super.initState();
    _selectedContinent = widget.recipe.continent;
    _selectedCountry = widget.recipe.country;
    _selectedDiet = widget.recipe.diet;
    _selectedCourse = widget.recipe.course;
  }

  @override
  Widget build(BuildContext context) {
    final repository = ref.watch(recipeRepositoryProvider);
    return AlertDialog(
      title: const Text('Edit Filters'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFilterDropdown(
              label: 'Continent',
              value: _selectedContinent,
              items: _continents,
              onChanged: (value) => setState(() => _selectedContinent = value),
            ),
            const SizedBox(height: 16),
            _buildFilterDropdown(
              label: 'Country',
              value: _selectedCountry,
              items: _countries,
              onChanged: (value) => setState(() => _selectedCountry = value),
            ),
            const SizedBox(height: 16),
            _buildFilterDropdown(
              label: 'Diet',
              value: _selectedDiet,
              items: _diets,
              onChanged: (value) => setState(() => _selectedDiet = value),
            ),
            const SizedBox(height: 16),
            _buildFilterDropdown(
              label: 'Course',
              value: _selectedCourse,
              items: _courses,
              onChanged: (value) => setState(() => _selectedCourse = value),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            // Update the recipe model with new filters
            final updatedRecipe = widget.recipe.copyWith(
              continent: _selectedContinent,
              country: _selectedCountry,
              diet: _selectedDiet,
              course: _selectedCourse,
            );
            await repository.update(updatedRecipe);
            if (context.mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Filters updated')),
              );
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      value: value,
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('None'),
        ),
        ...items.map(
          (item) => DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }
}

