import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../i18n/strings.g.dart';
import '../navigation/app_drawer.dart';
import '../widgets/back_aware_app_bar.dart';

class FilterRecipesScreen extends StatefulWidget {
  const FilterRecipesScreen({
    super.key,
    this.drawer,
    required this.onRecipeTap,
  });

  static const routeName = '/filter';

  final Widget? drawer;
  final void Function(BuildContext context, RecipeEntity entity) onRecipeTap;

  @override
  State<FilterRecipesScreen> createState() => _FilterRecipesScreenState();
}

class _FilterRecipesScreenState extends State<FilterRecipesScreen> {
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
    final inset = responsivePageInsets(context);
    return Scaffold(
      appBar: BackAwareAppBar(title: Text(context.t.recipes.filter)),
      drawer: widget.drawer ?? const AppDrawer(currentRoute: FilterRecipesScreen.routeName),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
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
                    labelText: context.t.filters.searchPlaceholder,
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
            StreamBuilder<List<RecipeEntity>>(
              stream: AppRepositories.instance.recipes.watchAll(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
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
                              snapshot.error.toString(),
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
                    ),
                  );
                }
                
                if (!snapshot.hasData) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                
                final recipes = snapshot.data ?? const <RecipeEntity>[];
                
                // Extract unique values from recipes
                final availableContinents = recipes
                    .map((e) => e.continent)
                    .whereType<String>()
                    .toSet()
                    .toList()
                  ..sort();
                
                final availableCountries = recipes
                    .map((e) => e.country)
                    .whereType<String>()
                    .toSet()
                    .toList()
                  ..sort();
                
                final availableDiets = recipes
                    .map((e) => e.diet)
                    .whereType<String>()
                    .toSet()
                    .toList()
                  ..sort();
                
                final availableCourses = recipes
                    .map((e) => e.course)
                    .whereType<String>()
                    .toSet()
                    .toList()
                  ..sort();
                
                return SliverPadding(
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
                            label: Text(context.t.filters.clearAll),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
            StreamBuilder<List<RecipeEntity>>(
              stream: AppRepositories.instance.recipes.watchAll(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
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
                              snapshot.error.toString(),
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
                    ),
                  );
                }
                
                if (!snapshot.hasData) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                
                final query = _searchController.text.trim().toLowerCase();
                final items = (snapshot.data ?? const <RecipeEntity>[])
                    .where(
                      (entity) => entity.matchesFilters(
                        query: query,
                        selectedContinent: _selectedContinent,
                        selectedCountry: _selectedCountry,
                        selectedDiet: _selectedDiet,
                        selectedCourse: _selectedCourse,
                      ),
                    )
                    .toList()
                    ..sort(
                      (a, b) =>
                          a.title.toLowerCase().compareTo(b.title.toLowerCase()),
                    );
                if (items.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: EdgeInsets.only(top: inset.bottom + 32),
                      child: Center(
                        child: Text(context.t.filters.noMatch),
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    inset.left,
                    16,
                    inset.right,
                    inset.bottom,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final entity = items[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _FilterResultTile(
                            entity: entity,
                            onTap: () => widget.onRecipeTap(context, entity),
                          ),
                        );
                      },
                      childCount: items.length,
                    ),
                  ),
                );
              },
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
      // ignore: deprecated_member_use
      value: value,
      items: [
        DropdownMenuItem<String>(
          value: null,
          child: Text(context.t.filters.all),
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

class _FilterResultTile extends StatelessWidget {
  const _FilterResultTile({required this.entity, required this.onTap});

  final RecipeEntity entity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final recipe = entity.toRecipe();
    return Card(
      child: ListTile(
        title: Text(recipe.title),
        subtitle: Text(
          ingredientsPreview(recipe),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: entity.isFavorite
            ? Icon(Icons.star, color: Theme.of(context).colorScheme.primary)
            : null,
        onTap: onTap,
      ),
    );
  }
}
