import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../../../app/di.dart';
import '../../../../src/navigation/app_drawer.dart';
import '../../../../src/widgets/back_aware_app_bar.dart';
import '../../domain/models/recipe_model.dart';
import '../utils/recipe_navigation.dart';

/// Screen for filtering recipes by various criteria
/// 
/// Uses Riverpod for state management and the new RecipeController.
class FilterRecipesScreen extends ConsumerStatefulWidget {
  const FilterRecipesScreen({
    super.key,
    this.drawer,
  });

  static const routeName = '/filter';

  final Widget? drawer;

  @override
  ConsumerState<FilterRecipesScreen> createState() => _FilterRecipesScreenState();
}

class _FilterRecipesScreenState extends ConsumerState<FilterRecipesScreen> {
  final _searchController = TextEditingController();
  String? _selectedContinent;
  String? _selectedCountry;
  String? _selectedDiet;
  String? _selectedCourse;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(recipeControllerProvider.notifier);
    final state = ref.watch(recipeControllerProvider);
    final inset = responsivePageInsets(context);

    // Get available filter values from repository
    final repository = ref.watch(recipeRepositoryProvider);
    final availableContinents = repository.getAllContinents();
    final availableCountries = repository.getAllCountries();
    final availableDiets = repository.getAllDiets();
    final availableCourses = repository.getAllCourses();

    // Filter recipes using the use case
    final filteredRecipes = controller.filter(
      query: _searchController.text.trim(),
      continent: _selectedContinent,
      country: _selectedCountry,
      diet: _selectedDiet,
      course: _selectedCourse,
    );

    return Scaffold(
      appBar: const BackAwareAppBar(title: Text('Filter recipes')),
      drawer: widget.drawer ?? const AppDrawer(currentRoute: FilterRecipesScreen.routeName),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Search field
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                inset.left,
                inset.top,
                inset.right,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search by name or ingredient',
                    border: const OutlineInputBorder(),
                    suffixIcon: _searchController.text.isEmpty
                        ? const Icon(Icons.search)
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                              });
                            },
                          ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ),
            // Filter dropdowns
            if (state.isLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.error != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildError(context, state.error!),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  inset.left,
                  16,
                  inset.right,
                  0,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildFilterDropdown(
                        label: 'Continent',
                        value: _selectedContinent,
                        items: availableContinents,
                        onChanged: (value) => setState(() => _selectedContinent = value),
                      ),
                      const SizedBox(height: 12),
                      _buildFilterDropdown(
                        label: 'Country',
                        value: _selectedCountry,
                        items: availableCountries,
                        onChanged: (value) => setState(() => _selectedCountry = value),
                      ),
                      const SizedBox(height: 12),
                      _buildFilterDropdown(
                        label: 'Diet',
                        value: _selectedDiet,
                        items: availableDiets,
                        onChanged: (value) => setState(() => _selectedDiet = value),
                      ),
                      const SizedBox(height: 12),
                      _buildFilterDropdown(
                        label: 'Course',
                        value: _selectedCourse,
                        items: availableCourses,
                        onChanged: (value) => setState(() => _selectedCourse = value),
                      ),
                      if (_selectedContinent != null ||
                          _selectedCountry != null ||
                          _selectedDiet != null ||
                          _selectedCourse != null) ...[
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _selectedContinent = null;
                              _selectedCountry = null;
                              _selectedDiet = null;
                              _selectedCourse = null;
                            });
                          },
                          icon: const Icon(Icons.clear_all),
                          label: const Text('Clear all filters'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            // Filtered results
            if (state.isLoading)
              const SliverToBoxAdapter(child: SizedBox.shrink())
            else if (state.error != null)
              const SliverToBoxAdapter(child: SizedBox.shrink())
            else if (filteredRecipes.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: EdgeInsets.only(top: inset.bottom + 32),
                  child: const Center(
                    child: Text('No recipes match your filters yet.'),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  inset.left,
                  16,
                  inset.right,
                  inset.bottom,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final recipe = filteredRecipes[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _FilterResultTile(
                          recipe: recipe,
                          onTap: () => RecipeNavigation.pushRecipeDetails(context, recipe),
                        ),
                      );
                    },
                    childCount: filteredRecipes.length,
                  ),
                ),
              ),
          ],
        ),
      ),
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
          child: Text('All'),
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

  Widget _buildError(BuildContext context, String error) {
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
              'Error loading recipes',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
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
}

class _FilterResultTile extends StatelessWidget {
  const _FilterResultTile({
    required this.recipe,
    required this.onTap,
  });

  final RecipeModel recipe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ingredientsPreview = recipe.ingredients.isEmpty
        ? 'No ingredients listed'
        : recipe.ingredients.take(3).join(', ') +
            (recipe.ingredients.length > 3 ? ', ...' : '');

    return Card(
      child: ListTile(
        title: Text(recipe.title),
        subtitle: Text(
          ingredientsPreview,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: recipe.isFavorite
            ? Icon(Icons.star, color: Theme.of(context).colorScheme.primary)
            : null,
        onTap: onTap,
      ),
    );
  }
}

