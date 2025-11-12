import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:core/core.dart';
import 'imported_url_store.dart';
import 'recipe_entity.dart';

class RecipeStore {
  RecipeStore._();

  static const _boxName = 'recipes';
  static RecipeStore? _instance;

  static RecipeStore get instance {
    final instance = _instance;
    if (instance == null) {
      throw StateError('RecipeStore has not been initialized.');
    }
    return instance;
  }

  Box<RecipeEntity> get _box => Hive.box<RecipeEntity>(_boxName);

  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(RecipeEntityAdapter().typeId)) {
      Hive.registerAdapter(RecipeEntityAdapter());
    }
    await Hive.openBox<RecipeEntity>(_boxName);
    _instance = RecipeStore._();
  }

  ValueListenable<Box<RecipeEntity>> listenable() => _box.listenable();

  Future<void> saveRecipe({
    required RecipeParseResult result,
    required String url,
  }) async {
    final recipe = result.recipe;
    final key = recipe.sourceUrl?.isNotEmpty == true ? recipe.sourceUrl! : url;
    final existing = _box.get(key);
    final entity = RecipeEntity.fromRecipe(
      recipe,
      url: key,
      strategy: result.strategy,
    ).copyWith(isFavorite: existing?.isFavorite);
    await _box.put(key, entity);
    
    // Mark URL as imported
    await ImportedUrlStore.instance.markAsImported(key);
  }

  Future<String> saveManualRecipe({
    required Recipe recipe,
    List<String> categories = const [],
    bool isFavorite = false,
  }) async {
    final metadata = {
      ...recipe.metadata,
      if (categories.isNotEmpty) 'tags': categories,
      'source': 'manual',
    };
    final manualRecipe = recipe.copyWith(
      sourceUrl: recipe.sourceUrl?.isNotEmpty == true
          ? recipe.sourceUrl
          : 'manual://${DateTime.now().millisecondsSinceEpoch}',
      metadata: metadata,
    );
    final entity = RecipeEntity.fromRecipe(
      manualRecipe,
      url: manualRecipe.sourceUrl!,
      strategy: 'Manual entry',
    ).copyWith(isFavorite: isFavorite);
    await _box.put(manualRecipe.sourceUrl!, entity);
    return manualRecipe.sourceUrl!;
  }

  RecipeParseResult? getRecipe(String url) {
    final entity = _box.get(url);
    if (entity == null) {
      return null;
    }
    final recipe = entity.toRecipe();
    return RecipeParseResult(
      recipe: recipe,
      strategy: entity.strategy,
      notes: const ['Loaded from cache'],
    );
  }

  RecipeEntity? entityFor(String url) => _box.get(url);

  List<RecipeEntity> allEntities() => _box.values.toList(growable: false);

  List<RecipeEntity> favoriteEntities() =>
      _box.values.where((entity) => entity.isFavorite).toList(growable: false);

  List<RecipeEntity> entitiesForUrls(Iterable<String> urls) {
    final unique = urls.toSet();
    return unique
        .map((url) => _box.get(url))
        .whereType<RecipeEntity>()
        .toList(growable: false);
  }

  Set<String> allCategories() {
    final categories = <String>{};
    for (final entity in _box.values) {
      categories.addAll(
        entity.normalizedCategories.map((e) => e.toLowerCase()),
      );
    }
    return categories;
  }

  Future<void> toggleFavorite(String url) async {
    final entity = _box.get(url);
    if (entity == null) {
      return;
    }
    await _box.put(url, entity.copyWith(isFavorite: !entity.isFavorite));
  }

  Future<void> updateFilters({
    required String url,
    String? continent,
    String? country,
    String? diet,
    String? course,
  }) async {
    final entity = _box.get(url);
    if (entity == null) {
      return;
    }
    await _box.put(
      url,
      entity.copyWith(
        continent: continent,
        country: country,
        diet: diet,
        course: course,
      ),
    );
  }

  Future<void> delete(String url) => _box.delete(url);

  Future<void> clear() => _box.clear();
}
