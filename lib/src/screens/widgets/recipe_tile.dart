import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

class RecipeListTile extends StatelessWidget {
  const RecipeListTile({
    super.key,
    required this.entity,
    required this.onTap,
    required this.onToggleFavorite,
  });

  final RecipeEntity entity;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final recipe = entity.toRecipe();
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RecipeThumbnail(imageUrl: recipe.imageUrl),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (recipe.description != null &&
                        recipe.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          recipe.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      ingredientsPreview(recipe),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.black54),
                    ),
                    if (entity.normalizedCategories.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: entity.normalizedCategories
                              .take(3)
                              .map((category) => Chip(label: Text(category)))
                              .toList(),
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                tooltip:
                    entity.isFavorite ? 'Remove favourite' : 'Add to favourites',
                icon: Icon(
                  entity.isFavorite ? Icons.star : Icons.star_border,
                  color: entity.isFavorite
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                onPressed: onToggleFavorite,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecipeThumbnail extends StatelessWidget {
  const _RecipeThumbnail({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _placeholder();
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl!,
        width: 96,
        height: 96,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return const SizedBox(
      width: 96,
      height: 96,
      child: DecoratedBox(
        decoration: BoxDecoration(color: Colors.black12),
        child: Icon(Icons.image_not_supported),
      ),
    );
  }
}
