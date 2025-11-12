import 'dart:convert';

import 'package:hive/hive.dart';

import 'package:core/core.dart';

class RecipeEntity extends HiveObject {
  RecipeEntity({
    required this.url,
    required this.title,
    required this.ingredients,
    required this.instructions,
    required this.cachedAt,
    required this.strategy,
    required this.categories,
    required this.searchableText,
    this.country,
    this.continent,
    this.diet,
    this.course,
    this.description,
    this.imageUrl,
    this.author,
    this.sourceUrl,
    this.yield,
    this.prepTimeSeconds,
    this.cookTimeSeconds,
    this.totalTimeSeconds,
    this.metadataJson,
    this.isFavorite = false,
  });

  final String url;
  final String title;
  final List<String> ingredients;
  final List<String> instructions;
  final DateTime cachedAt;
  final String strategy;
  final List<String> categories;
  final String searchableText;
  final String? country;
  final String? continent;
  final String? diet;
  final String? course;
  final String? description;
  final String? imageUrl;
  final String? author;
  final String? sourceUrl;
  final String? yield;
  final int? prepTimeSeconds;
  final int? cookTimeSeconds;
  final int? totalTimeSeconds;
  final String? metadataJson;
  final bool isFavorite;

  List<String> get normalizedCategories => effectiveCategories
      .map((category) => category.trim())
      .where((category) => category.isNotEmpty)
      .toList(growable: false);

  List<String> get effectiveCategories {
    // Only return manually set categories, no automatic extraction
    return categories;
  }

  String get _effectiveSearchableText => searchableText.isNotEmpty
      ? searchableText
      : _buildSearchableText(
          title: title,
          description: description,
          ingredients: ingredients,
          instructions: instructions,
          categories: effectiveCategories,
          notes: [
            strategy,
            author,
            yield,
            _metadataMap['keywords']?.toString(),
            country,
            continent,
            diet,
            course,
          ],
        );

  Map<String, Object?> get _metadataMap => metadataJson == null
      ? <String, Object?>{}
      : (jsonDecode(metadataJson!) as Map<String, dynamic>);

  bool matchesFilters({
    required String query,
    String? selectedContinent,
    String? selectedCountry,
    String? selectedDiet,
    String? selectedCourse,
  }) {
    final matchesQuery =
        query.isEmpty || _effectiveSearchableText.contains(query);
    
    if (!matchesQuery) return false;
    
    // If no filters are selected, show all recipes that match the query
    if (selectedContinent == null && 
        selectedCountry == null && 
        selectedDiet == null && 
        selectedCourse == null) {
      return true;
    }
    
    // Check each filter - all selected filters must match
    if (selectedContinent != null && continent != selectedContinent) {
      return false;
    }
    if (selectedCountry != null && country != selectedCountry) {
      return false;
    }
    if (selectedDiet != null && diet != selectedDiet) {
      return false;
    }
    if (selectedCourse != null && course != selectedCourse) {
      return false;
    }
    
    return true;
  }

  RecipeEntity copyWith({
    bool? isFavorite,
    String? continent,
    String? country,
    String? diet,
    String? course,
  }) {
    return RecipeEntity(
      url: url,
      title: title,
      ingredients: ingredients,
      instructions: instructions,
      cachedAt: cachedAt,
      strategy: strategy,
      categories: categories,
      searchableText: searchableText,
      country: country ?? this.country,
      continent: continent ?? this.continent,
      diet: diet ?? this.diet,
      course: course ?? this.course,
      description: description,
      imageUrl: imageUrl,
      author: author,
      sourceUrl: sourceUrl,
      yield: yield,
      prepTimeSeconds: prepTimeSeconds,
      cookTimeSeconds: cookTimeSeconds,
      totalTimeSeconds: totalTimeSeconds,
      metadataJson: metadataJson,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  factory RecipeEntity.fromRecipe(
    Recipe recipe, {
    required String url,
    required String strategy,
  }) {
    final metadata = recipe.metadata;
    final metadataCategories = _extractCategories(metadata);
    final location = _inferLocation(
      url: url,
      metadata: metadata,
      categories: metadataCategories,
      title: recipe.title,
      description: recipe.description,
    );

    final categoriesSet = <String>{...metadataCategories};
    if (location.country != null) {
      categoriesSet.add(location.country!);
    }
    if (location.continent != null) {
      categoriesSet.add(location.continent!);
    }
    final resolvedCategories = categoriesSet.toList(growable: false);

    final searchableText = _buildSearchableText(
      title: recipe.title,
      description: recipe.description,
      ingredients: recipe.ingredients,
      instructions: recipe.instructions,
      categories: resolvedCategories,
      notes: [
        strategy,
        recipe.author,
        recipe.yield,
        metadata['keywords']?.toString(),
        location.country,
        location.continent,
      ],
    );

    return RecipeEntity(
      url: url,
      title: recipe.title,
      description: recipe.description,
      imageUrl: recipe.imageUrl,
      author: recipe.author,
      sourceUrl: recipe.sourceUrl ?? url,
      yield: recipe.yield,
      prepTimeSeconds: recipe.prepTime?.inSeconds,
      cookTimeSeconds: recipe.cookTime?.inSeconds,
      totalTimeSeconds: recipe.totalTime?.inSeconds,
      metadataJson: metadata.isEmpty ? null : jsonEncode(metadata),
      ingredients: List<String>.from(recipe.ingredients),
      instructions: List<String>.from(recipe.instructions),
      cachedAt: DateTime.now(),
      strategy: strategy,
      categories: resolvedCategories,
      searchableText: searchableText,
      country: location.country,
      continent: location.continent,
    );
  }

  Recipe toRecipe() {
    final metadata = Map<String, Object?>.from(_metadataMap);
    metadata['categories'] ??= effectiveCategories;
    if (country != null) {
      metadata['country'] ??= country;
    }
    if (continent != null) {
      metadata['continent'] ??= continent;
    }

    return Recipe(
      title: title,
      description: description,
      imageUrl: imageUrl,
      author: author,
      sourceUrl: sourceUrl,
      yield: yield,
      prepTime: _durationFromSeconds(prepTimeSeconds),
      cookTime: _durationFromSeconds(cookTimeSeconds),
      totalTime: _durationFromSeconds(totalTimeSeconds),
      ingredients: ingredients,
      instructions: instructions,
      metadata: metadata,
    );
  }

  static List<String> _extractCategories(Map<String, Object?> metadata) {
    final categories = <String>{};

    void addValue(Object? value) {
      if (value == null) {
        return;
      }
      if (value is String) {
        final parts = value.split(RegExp(r'[;,]'));
        for (final part in parts) {
          final trimmed = part.trim();
          if (trimmed.isNotEmpty) {
            categories.add(trimmed);
          }
        }
      } else if (value is Iterable) {
        for (final item in value) {
          addValue(item);
        }
      } else {
        categories.add(value.toString());
      }
    }

    addValue(metadata['recipeCategory']);
    addValue(metadata['category']);
    addValue(metadata['cuisine']);
    addValue(metadata['recipeCuisine']);
    addValue(metadata['keywords']);
    addValue(metadata['tags']);

    return categories.toList(growable: false);
  }

  static String _buildSearchableText({
    required String title,
    required String? description,
    required List<String> ingredients,
    required List<String> instructions,
    required List<String> categories,
    required List<String?> notes,
  }) {
    final buffer = StringBuffer();
    void addText(String? text) {
      if (text == null) {
        return;
      }
      final trimmed = text.trim();
      if (trimmed.isEmpty) {
        return;
      }
      buffer.writeln(trimmed.toLowerCase());
    }

    addText(title);
    addText(description);
    for (final ingredient in ingredients) {
      addText(ingredient);
    }
    for (final instruction in instructions) {
      addText(instruction);
    }
    for (final category in categories) {
      addText(category);
    }
    for (final note in notes) {
      addText(note);
    }
    return buffer.toString();
  }

  Duration? _durationFromSeconds(int? seconds) {
    if (seconds == null) {
      return null;
    }
    return Duration(seconds: seconds);
  }
}

class RecipeEntityAdapter extends TypeAdapter<RecipeEntity> {
  @override
  final int typeId = 1;

  @override
  RecipeEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      fields[key] = reader.read();
    }

    return RecipeEntity(
      url: fields[0] as String,
      title: fields[1] as String,
      ingredients: (fields[2] as List?)?.cast<String>() ?? const [],
      instructions: (fields[3] as List?)?.cast<String>() ?? const [],
      cachedAt: fields[4] is int
          ? DateTime.fromMillisecondsSinceEpoch(fields[4] as int)
          : (fields[4] as DateTime?) ?? DateTime.fromMillisecondsSinceEpoch(0),
      strategy: fields[5] as String? ?? 'Unknown',
      description: fields[6] as String?,
      imageUrl: fields[7] as String?,
      author: fields[8] as String?,
      sourceUrl: fields[9] as String?,
      yield: fields[10] as String?,
      prepTimeSeconds: fields[11] as int?,
      cookTimeSeconds: fields[12] as int?,
      totalTimeSeconds: fields[13] as int?,
      metadataJson: fields[14] as String?,
      categories: (fields[15] as List?)?.cast<String>() ?? const [],
      searchableText: fields[16] as String? ?? '',
      country: fields[17] as String?,
      continent: fields[18] as String?,
      diet: fields[20] as String?,
      course: fields[21] as String?,
      isFavorite: fields[19] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, RecipeEntity obj) {
    writer
      ..writeByte(22)
      ..writeByte(0)
      ..write(obj.url)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.ingredients)
      ..writeByte(3)
      ..write(obj.instructions)
      ..writeByte(4)
      ..write(obj.cachedAt)
      ..writeByte(5)
      ..write(obj.strategy)
      ..writeByte(6)
      ..write(obj.description)
      ..writeByte(7)
      ..write(obj.imageUrl)
      ..writeByte(8)
      ..write(obj.author)
      ..writeByte(9)
      ..write(obj.sourceUrl)
      ..writeByte(10)
      ..write(obj.yield)
      ..writeByte(11)
      ..write(obj.prepTimeSeconds)
      ..writeByte(12)
      ..write(obj.cookTimeSeconds)
      ..writeByte(13)
      ..write(obj.totalTimeSeconds)
      ..writeByte(14)
      ..write(obj.metadataJson)
      ..writeByte(15)
      ..write(obj.categories)
      ..writeByte(16)
      ..write(obj.searchableText)
      ..writeByte(17)
      ..write(obj.country)
      ..writeByte(18)
      ..write(obj.continent)
      ..writeByte(19)
      ..write(obj.isFavorite)
      ..writeByte(20)
      ..write(obj.diet)
      ..writeByte(21)
      ..write(obj.course);
  }
}

class _Location {
  const _Location({this.country, this.continent});

  final String? country;
  final String? continent;
}

_Location _inferLocation({
  required String url,
  required Map<String, Object?> metadata,
  required List<String> categories,
  required String title,
  String? description,
}) {
  String? country;

  final candidates = <String>[];

  void addCandidate(Object? value) {
    if (value == null) {
      return;
    }
    if (value is String) {
      candidates.add(value);
    } else if (value is Iterable) {
      for (final item in value) {
        addCandidate(item);
      }
    } else {
      candidates.add(value.toString());
    }
  }

  addCandidate(metadata['recipeCuisine']);
  addCandidate(metadata['cuisine']);
  addCandidate(metadata['recipeCategory']);
  addCandidate(metadata['category']);
  addCandidate(metadata['keywords']);
  addCandidate(categories);
  addCandidate(title);
  addCandidate(description);

  final joined = candidates.join(' ').toLowerCase();
  for (final entry in _keywordToCountry.entries) {
    if (joined.contains(entry.key)) {
      country = entry.value;
      break;
    }
  }

  if (country == null) {
    final host = Uri.tryParse(url)?.host ?? '';
    final parts = host.split('.');
    if (parts.isNotEmpty) {
      final tld = parts.last.toLowerCase();
      country = _tldToCountry[tld];
    }
  }

  final continent = country != null ? _countryToContinent[country] : null;

  return _Location(country: country, continent: continent);
}

const Map<String, String> _keywordToCountry = {
  'italian': 'Italy',
  'italiaans': 'Italy',
  'frans': 'France',
  'french': 'France',
  'spanish': 'Spain',
  'spaans': 'Spain',
  'mexican': 'Mexico',
  'mexicaans': 'Mexico',
  'thai': 'Thailand',
  'thais': 'Thailand',
  'indian': 'India',
  'indiaas': 'India',
  'chinese': 'China',
  'chinees': 'China',
  'japanese': 'Japan',
  'japans': 'Japan',
  'greek': 'Greece',
  'grieks': 'Greece',
  'turkish': 'Turkey',
  'turks': 'Turkey',
  'moroccan': 'Morocco',
  'marokkaans': 'Morocco',
  'vietnamese': 'Vietnam',
  'vietnamees': 'Vietnam',
  'korean': 'South Korea',
  'koreaans': 'South Korea',
  'jewish': 'Israel',
  'israeli': 'Israel',
  'dutch': 'Netherlands',
  'nederlands': 'Netherlands',
  'belgian': 'Belgium',
  'belgisch': 'Belgium',
  'german': 'Germany',
  'duits': 'Germany',
  'portuguese': 'Portugal',
  'portugees': 'Portugal',
  'brazilian': 'Brazil',
  'brasiliaans': 'Brazil',
  'argentinian': 'Argentina',
  'argentinaans': 'Argentina',
  'american': 'United States',
  'amerikaans': 'United States',
  'british': 'United Kingdom',
  'engels': 'United Kingdom',
  'swedish': 'Sweden',
  'zweeds': 'Sweden',
  'norwegian': 'Norway',
  'noors': 'Norway',
  'danish': 'Denmark',
  'deens': 'Denmark',
  'african': 'South Africa',
  'south african': 'South Africa',
  'ethiopian': 'Ethiopia',
  'ethiopisch': 'Ethiopia',
  'indonesian': 'Indonesia',
  'indonesisch': 'Indonesia',
  'javanese': 'Indonesia',
};

const Map<String, String> _tldToCountry = {
  'nl': 'Netherlands',
  'be': 'Belgium',
  'fr': 'France',
  'de': 'Germany',
  'it': 'Italy',
  'es': 'Spain',
  'pt': 'Portugal',
  'uk': 'United Kingdom',
  'co.uk': 'United Kingdom',
  'ie': 'Ireland',
  'us': 'United States',
  'ca': 'Canada',
  'mx': 'Mexico',
  'br': 'Brazil',
  'ar': 'Argentina',
  'za': 'South Africa',
  'dz': 'Algeria',
  'ma': 'Morocco',
  'in': 'India',
  'cn': 'China',
  'jp': 'Japan',
  'kr': 'South Korea',
  'th': 'Thailand',
  'vn': 'Vietnam',
  'id': 'Indonesia',
  'au': 'Australia',
  'nz': 'New Zealand',
  'ru': 'Russia',
  'se': 'Sweden',
  'no': 'Norway',
  'dk': 'Denmark',
  'fi': 'Finland',
  'pl': 'Poland',
  'gr': 'Greece',
  'tr': 'Turkey',
  'il': 'Israel',
  'sa': 'Saudi Arabia',
  'ae': 'United Arab Emirates',
  'sg': 'Singapore',
};

const Map<String, String> _countryToContinent = {
  'Netherlands': 'Europe',
  'Belgium': 'Europe',
  'France': 'Europe',
  'Germany': 'Europe',
  'Italy': 'Europe',
  'Spain': 'Europe',
  'Portugal': 'Europe',
  'United Kingdom': 'Europe',
  'Ireland': 'Europe',
  'Poland': 'Europe',
  'Greece': 'Europe',
  'Turkey': 'Europe',
  'Sweden': 'Europe',
  'Norway': 'Europe',
  'Denmark': 'Europe',
  'Finland': 'Europe',
  'Russia': 'Europe',
  'United States': 'North America',
  'Canada': 'North America',
  'Mexico': 'North America',
  'Brazil': 'South America',
  'Argentina': 'South America',
  'Colombia': 'South America',
  'Chile': 'South America',
  'South Africa': 'Africa',
  'Algeria': 'Africa',
  'Morocco': 'Africa',
  'Ethiopia': 'Africa',
  'Egypt': 'Africa',
  'India': 'Asia',
  'China': 'Asia',
  'Japan': 'Asia',
  'South Korea': 'Asia',
  'Thailand': 'Asia',
  'Vietnam': 'Asia',
  'Indonesia': 'Asia',
  'Israel': 'Asia',
  'Saudi Arabia': 'Asia',
  'United Arab Emirates': 'Asia',
  'Australia': 'Oceania',
  'New Zealand': 'Oceania',
};
