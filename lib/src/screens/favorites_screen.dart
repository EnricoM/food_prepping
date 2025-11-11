import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

import '../navigation/app_drawer.dart';
import 'widgets/recipe_tile.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({
    super.key,
    this.drawer,
    required this.onRecipeTap,
  });

  static const routeName = '/favorites';

  final Widget? drawer;
  final void Function(BuildContext context, RecipeEntity entity) onRecipeTap;

  @override
  Widget build(BuildContext context) {
    final inset = responsivePageInsets(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Favourite recipes')),
      drawer: drawer ?? const AppDrawer(currentRoute: routeName),
      body: SafeArea(
        child: Padding(
          padding: inset,
          child: StreamBuilder<List<RecipeEntity>>(
            stream: AppRepositories.instance.recipes.watchFavorites(),
            builder: (context, snapshot) {
              final favourites = List<RecipeEntity>.from(
                snapshot.data ?? const <RecipeEntity>[],
              )..sort(
                  (a, b) =>
                      a.title.toLowerCase().compareTo(b.title.toLowerCase()),
                );
              if (favourites.isEmpty) {
                return const Center(
                  child: Text('Mark recipes as favourites to see them here.'),
                );
              }
              return ListView.separated(
                itemCount: favourites.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final entity = favourites[index];
                  return RecipeListTile(
                    entity: entity,
                    onTap: () => onRecipeTap(context, entity),
                    onToggleFavorite: () => AppRepositories.instance.recipes
                        .toggleFavorite(entity.url),
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
