import 'package:core/core.dart';

String ingredientsPreview(Recipe recipe, {int maxCount = 3}) {
  final ingredients = recipe.ingredients;
  if (ingredients.isEmpty) {
    return 'No ingredients listed';
  }
  final preview = ingredients.take(maxCount).toList(growable: false);
  final remaining = ingredients.length - preview.length;
  final suffix = remaining > 0 ? ' +$remaining more' : '';
  return preview.join(', ') + suffix;
}
