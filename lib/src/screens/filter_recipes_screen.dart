import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_ui/shared_ui.dart';

import '../navigation/app_drawer.dart';

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
  final _selectedCategories = <String>{};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inset = responsivePageInsets(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Filter recipes')),
      drawer: widget.drawer ?? const AppDrawer(currentRoute: FilterRecipesScreen.routeName),
      body: SafeArea(
        child: Padding(
          padding: inset,
          child: Column(
            children: [
              TextField(
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
              const SizedBox(height: 16),
              ValueListenableBuilder<Box<RecipeEntity>>(
                valueListenable: RecipeStore.instance.listenable(),
                builder: (context, box, _) {
                  final categories = RecipeStore.instance
                      .allCategories()
                      .map((e) => e.toLowerCase())
                      .toSet();
                  final sortedCategories = categories.toList()..sort();
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: sortedCategories
                        .map(
                          (category) => FilterChip(
                            label: Text(category),
                            selected: _selectedCategories.contains(category),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedCategories.add(category);
                                } else {
                                  _selectedCategories.remove(category);
                                }
                              });
                            },
                          ),
                        )
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ValueListenableBuilder<Box<RecipeEntity>>(
                  valueListenable: RecipeStore.instance.listenable(),
                  builder: (context, box, _) {
                    final query = _searchController.text.trim().toLowerCase();
                    final categories = _selectedCategories;
                    final items = box.values
                        .where(
                          (entity) => entity.matchesFilters(
                            query: query,
                            selectedCategories: categories,
                          ),
                        )
                        .toList()
                      ..sort(
                        (a, b) =>
                            a.title.toLowerCase().compareTo(b.title.toLowerCase()),
                      );
                    if (items.isEmpty) {
                      return const Center(
                        child: Text('No recipes match your filters yet.'),
                      );
                    }
                    return ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final entity = items[index];
                        return _FilterResultTile(
                          entity: entity,
                          onTap: () => widget.onRecipeTap(context, entity),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
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
