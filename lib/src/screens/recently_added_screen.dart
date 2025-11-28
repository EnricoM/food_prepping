import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

import '../navigation/app_drawer.dart';
import '../widgets/back_aware_app_bar.dart';
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
      appBar: const BackAwareAppBar(title: Text('Recently added')),
      drawer: drawer ?? const AppDrawer(currentRoute: routeName),
      body: SafeArea(
        child: Padding(
          padding: inset,
          child: StreamBuilder<List<RecipeEntity>>(
            stream: AppRepositories.instance.recipes.watchAll(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
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
                );
              }
              
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              
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
