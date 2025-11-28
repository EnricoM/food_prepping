/// Domain model for a recipe
/// 
/// This is the core recipe model used throughout the recipes feature.
/// TODO: Add dart_mappable serialization once build_runner is configured
class RecipeModel {
  const RecipeModel({
    required this.id,
    required this.title,
    required this.ingredients,
    required this.instructions,
    this.description,
    this.imageUrl,
    this.author,
    this.sourceUrl,
    this.servings,
    this.prepTimeMinutes,
    this.cookTimeMinutes,
    this.totalTimeMinutes,
    this.continent,
    this.country,
    this.diet,
    this.course,
    this.isFavorite = false,
    this.cachedAt,
    this.strategy,
    this.categories = const [],
    this.metadata = const {},
  });

  final String id; // URL or unique identifier
  final String title;
  final List<String> ingredients;
  final List<String> instructions;
  final String? description;
  final String? imageUrl;
  final String? author;
  final String? sourceUrl;
    final String? servings;
  final int? prepTimeMinutes;
  final int? cookTimeMinutes;
  final int? totalTimeMinutes;
  final String? continent;
  final String? country;
  final String? diet;
  final String? course;
  final bool isFavorite;
  final DateTime? cachedAt;
  final String? strategy; // Parsing strategy used
  final List<String> categories;
  final Map<String, dynamic> metadata;

  RecipeModel copyWith({
    String? id,
    String? title,
    List<String>? ingredients,
    List<String>? instructions,
    String? description,
    String? imageUrl,
    String? author,
    String? sourceUrl,
    String? servings,
    int? prepTimeMinutes,
    int? cookTimeMinutes,
    int? totalTimeMinutes,
    String? continent,
    String? country,
    String? diet,
    String? course,
    bool? isFavorite,
    DateTime? cachedAt,
    String? strategy,
    List<String>? categories,
    Map<String, dynamic>? metadata,
  }) {
    return RecipeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      author: author ?? this.author,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      servings: servings ?? this.servings,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      cookTimeMinutes: cookTimeMinutes ?? this.cookTimeMinutes,
      totalTimeMinutes: totalTimeMinutes ?? this.totalTimeMinutes,
      continent: continent ?? this.continent,
      country: country ?? this.country,
      diet: diet ?? this.diet,
      course: course ?? this.course,
      isFavorite: isFavorite ?? this.isFavorite,
      cachedAt: cachedAt ?? this.cachedAt,
      strategy: strategy ?? this.strategy,
      categories: categories ?? this.categories,
      metadata: metadata ?? this.metadata,
    );
  }
}

