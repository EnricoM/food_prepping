import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_ui/shared_ui.dart';

import '../navigation/app_drawer.dart';
import 'widgets/recipe_tile.dart';

class StoredRecipesScreen extends StatelessWidget {
  const StoredRecipesScreen({
    super.key,
    this.drawer,
    required this.onRecipeTap,
  });

  static const routeName = '/stored';

  final Widget? drawer;
  final void Function(BuildContext context, RecipeEntity entity) onRecipeTap;

  @override
  Widget build(BuildContext context) {
    final inset = responsivePageInsets(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Stored recipes')),
      drawer: drawer ?? const AppDrawer(currentRoute: routeName),
      body: SafeArea(
        child: Padding(
          padding: inset,
          child: ValueListenableBuilder<Box<RecipeEntity>>(
            valueListenable: RecipeStore.instance.listenable(),
            builder: (context, box, _) {
              final recipes = box.values.toList(growable: false)
                ..sort(
                  (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
                );
              if (recipes.isEmpty) {
                return const Center(
                  child: Text('No recipes yet. Parse a recipe to see it here.'),
                );
              }
              return ListView.separated(
                itemCount: recipes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final entity = recipes[index];
                  return RecipeListTile(
                    entity: entity,
                    onTap: () => onRecipeTap(context, entity),
                    onToggleFavorite: () =>
                        RecipeStore.instance.toggleFavorite(entity.url),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
