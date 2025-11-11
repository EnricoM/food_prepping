import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

import '../navigation/app_drawer.dart';
import 'widgets/recipe_tile.dart';

class RecentlyAddedScreen extends StatelessWidget {
  const RecentlyAddedScreen({
    super.key,
    this.drawer,
    required this.onRecipeTap,
  });

  static const routeName = '/recent';

  final Widget? drawer;
  final void Function(BuildContext context, RecipeEntity entity) onRecipeTap;

  @override
  Widget build(BuildContext context) {
    final inset = responsivePageInsets(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Recently added')),
      drawer: drawer ?? const AppDrawer(currentRoute: routeName),
      body: SafeArea(
        child: Padding(
          padding: inset,
          child: StreamBuilder<List<RecipeEntity>>(
            stream: AppRepositories.instance.recipes.watchAll(),
            builder: (context, snapshot) {
              final recent = List<RecipeEntity>.from(
                snapshot.data ?? const <RecipeEntity>[],
              )..sort((a, b) => b.cachedAt.compareTo(a.cachedAt));
              final topTen = recent.take(10).toList();
              if (topTen.isEmpty) {
                return const Center(
                  child: Text('Parse or create recipes to build your history.'),
                );
              }
              return ListView.separated(
                itemCount: topTen.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final entity = topTen[index];
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
