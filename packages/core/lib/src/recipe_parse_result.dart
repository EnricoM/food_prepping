import 'recipe.dart';

class RecipeParseResult {
  RecipeParseResult({
    required this.recipe,
    required this.strategy,
    List<String> notes = const [],
  }) : notes = List.unmodifiable(notes);

  final Recipe recipe;
  final String strategy;
  final List<String> notes;

  RecipeParseResult copyWith({
    Recipe? recipe,
    String? strategy,
    List<String>? notes,
  }) {
    return RecipeParseResult(
      recipe: recipe ?? this.recipe,
      strategy: strategy ?? this.strategy,
      notes: notes ?? this.notes,
    );
  }
}
