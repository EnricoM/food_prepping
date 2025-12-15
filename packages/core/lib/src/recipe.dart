import 'dart:collection';

import 'ingredient.dart';
import 'ingredient_parser.dart';

class Recipe {
  Recipe({
    required this.title,
    List<Ingredient>? ingredients,
    List<String>? ingredientStrings,
    required List<String> instructions,
    this.description,
    this.imageUrl,
    this.author,
    this.sourceUrl,
    this.yield,
    this.prepTime,
    this.cookTime,
    this.totalTime,
    Map<String, Object?> metadata = const {},
  })  : ingredients = List.unmodifiable(
          ingredients ??
              (ingredientStrings != null
                  ? IngredientParser.parseList(
                      ingredientStrings
                          .where((item) => item.trim().isNotEmpty)
                          .map((item) => item.trim())
                          .toList(),
                    )
                  : []),
        ),
        instructions = List.unmodifiable(
          instructions
              .where((item) => item.trim().isNotEmpty)
              .map((item) => item.trim()),
        ),
        metadata = UnmodifiableMapView(metadata);

  final String title;
  final List<Ingredient> ingredients;
  final List<String> instructions;

  /// Get ingredients as strings (for backward compatibility)
  List<String> get ingredientStrings =>
      ingredients.map((ing) => ing.displayString).toList(growable: false);
  final String? description;
  final String? imageUrl;
  final String? author;
  final String? sourceUrl;
  final String? yield;
  final Duration? prepTime;
  final Duration? cookTime;
  final Duration? totalTime;
  final Map<String, Object?> metadata;

  String? get servings {
    return metadata['servings'] as String? ?? _extractServingsFromYield();
  }

  String? _extractServingsFromYield() {
    if (yield == null) {
      return null;
    }
    final normalized = yield!.toLowerCase();
    if (normalized.contains('serv')) {
      return yield;
    }
    final match = RegExp(
      r'\b\d+\s*(?:servings?|people|persons?)\b',
      caseSensitive: false,
    ).firstMatch(yield!);
    return match?.group(0);
  }

  Recipe copyWith({
    String? title,
    List<Ingredient>? ingredients,
    List<String>? instructions,
    String? description,
    String? imageUrl,
    String? author,
    String? sourceUrl,
    String? yield,
    Duration? prepTime,
    Duration? cookTime,
    Duration? totalTime,
    Map<String, Object?>? metadata,
  }) {
    return Recipe(
      title: title ?? this.title,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      author: author ?? this.author,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      yield: yield ?? this.yield,
      prepTime: prepTime ?? this.prepTime,
      cookTime: cookTime ?? this.cookTime,
      totalTime: totalTime ?? this.totalTime,
      metadata: metadata ?? this.metadata,
    );
  }
}
