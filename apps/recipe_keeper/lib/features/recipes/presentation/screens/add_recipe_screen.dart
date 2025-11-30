import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:parsing/parsing.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../../../app/di.dart';
import '../../../../src/navigation/app_drawer.dart';
import '../../../../src/widgets/back_aware_app_bar.dart';
import '../../domain/models/recipe_model.dart';
import '../utils/recipe_navigation.dart';
import '../widgets/network_image_with_fallback.dart';

/// Screen for adding a recipe by parsing from a URL
/// 
/// Uses Riverpod for state management and the new RecipeController.
class AddRecipeScreen extends ConsumerStatefulWidget {
  const AddRecipeScreen({
    super.key,
    this.drawer,
    this.initialUrl,
  });

  static const routeName = '/add';

  final Widget? drawer;
  final String? initialUrl;

  @override
  ConsumerState<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends ConsumerState<AddRecipeScreen> {
  final _urlController = TextEditingController();
  final _parser = RecipeParser();
  RecipeParseResult? _result;
  bool _isLoading = false;
  String? _error;
  bool _didAutoParse = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialUrl;
    if (initial != null && initial.isNotEmpty) {
      _urlController.text = initial;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_didAutoParse) {
          _didAutoParse = true;
          _parseUrl();
        }
      });
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _parser.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inset = responsivePageInsets(context);
    return Scaffold(
      appBar: BackAwareAppBar(
        title: const Text('Add recipe from URL'),
      ),
      drawer:
          widget.drawer ?? const AppDrawer(currentRoute: AddRecipeScreen.routeName),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: inset,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: 'Recipe URL',
                  border: const OutlineInputBorder(),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.paste),
                        tooltip: 'Paste URL',
                        onPressed: _pasteUrlFromClipboard,
                      ),
                      if (_urlController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          tooltip: 'Clear URL',
                          onPressed: () {
                            _urlController.clear();
                            setState(() {
                              _result = null;
                              _error = null;
                            });
                          },
                        ),
                    ],
                  ),
                ),
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.go,
                onSubmitted: (_) => _parseUrl(),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _isLoading ? null : _parseUrl,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.play_arrow),
                label: Text(_isLoading ? 'Parsing…' : 'Parse recipe'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              if (_result != null) ...[
                const SizedBox(height: 24),
                _RecipePreviewCard(
                  result: _result!,
                  onSave: _saveRecipe,
                  onView: () {
                    // Convert to RecipeModel and navigate
                    final recipeModel = _recipeToModel(_result!.recipe, _urlController.text.trim());
                    RecipeNavigation.pushRecipeDetails(context, recipeModel);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _parseUrl() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() => _error = 'Please enter a recipe URL.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _result = null;
      _didAutoParse = true;
    });

    try {
      final result = await _parser.parseUrl(url);
      if (!mounted) return;
      setState(() => _result = result);
    } on RecipeParseException catch (error) {
      setState(() => _error = error.message);
    } catch (error) {
      setState(() => _error = 'Failed to parse recipe: $error');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveRecipe() async {
    final result = _result;
    if (result == null) {
      setState(() => _error = 'Parse a recipe before saving.');
      return;
    }
    
    final scaffold = ScaffoldMessenger.of(context);
    final url = _urlController.text.trim();
    
    try {
      final repository = ref.read(recipeRepositoryProvider);
      
      // Convert Recipe to RecipeModel
      final recipeModel = _recipeToModel(result.recipe, url);
      
      // Save the recipe
      await repository.save(recipeModel);
      
      if (!mounted) return;
      
      scaffold.showSnackBar(
        const SnackBar(content: Text('Recipe saved to your library.')),
      );
      
      // Navigate to detail screen
      final saved = repository.getById(recipeModel.id);
      if (saved != null && mounted) {
        RecipeNavigation.pushRecipeDetails(context, saved);
      }
    } catch (error) {
      if (!mounted) return;
      scaffold.showSnackBar(
        SnackBar(content: Text('Failed to save recipe: $error')),
      );
    }
  }

  /// Convert Recipe (from parsing) to RecipeModel
  RecipeModel _recipeToModel(Recipe recipe, String url) {
    // Use sourceUrl if available, otherwise use the provided URL
    final recipeId = recipe.sourceUrl?.isNotEmpty == true
        ? recipe.sourceUrl!
        : url;
    
    return RecipeModel(
      id: recipeId,
      title: recipe.title,
      description: recipe.description,
      ingredients: recipe.ingredients,
      instructions: recipe.instructions,
      imageUrl: recipe.imageUrl,
      author: recipe.author,
      sourceUrl: recipe.sourceUrl ?? url,
      servings: recipe.yield,
      prepTimeMinutes: recipe.prepTime?.inMinutes,
      cookTimeMinutes: recipe.cookTime?.inMinutes,
      totalTimeMinutes: recipe.totalTime?.inMinutes,
      strategy: 'parsed', // Will be updated by repository if needed
      cachedAt: DateTime.now(),
      metadata: recipe.metadata,
    );
  }

  Future<void> _pasteUrlFromClipboard() async {
    setState(() {
      _urlController.clear();
      _result = null;
      _error = null;
    });
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted) return;
    final text = data?.text?.trim();
    if (text == null || text.isEmpty) {
      return;
    }
    setState(() {
      _urlController.text = text;
      _urlController.selection =
          TextSelection.collapsed(offset: _urlController.text.length);
    });
  }
}

class _RecipePreviewCard extends StatelessWidget {
  const _RecipePreviewCard({
    required this.result,
    required this.onSave,
    required this.onView,
  });

  final RecipeParseResult result;
  final VoidCallback onSave;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    final recipe = result.recipe;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty)
                  NetworkImageWithFallback(
                    imageUrl: recipe.imageUrl!,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(12),
                    fallback: const SizedBox(
                      width: 120,
                      height: 120,
                      child: DecoratedBox(
                        decoration: BoxDecoration(color: Colors.black12),
                        child: Icon(Icons.image_not_supported),
                      ),
                    ),
                  )
                else
                  const SizedBox(
                    width: 120,
                    height: 120,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: Colors.black12),
                      child: Icon(Icons.restaurant_menu),
                    ),
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _ingredientsPreview(recipe),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Strategy: ${result.strategy}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (recipe.description != null && recipe.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(recipe.description!),
              ),
            const SizedBox(height: 20),
            Row(
              children: [
                FilledButton.icon(
                  onPressed: onSave,
                  icon: const Icon(Icons.save_alt),
                  label: const Text('Save to library'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: onView,
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('View details'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _ingredientsPreview(Recipe recipe) {
    if (recipe.ingredients.isEmpty) return 'No ingredients listed';
    if (recipe.ingredients.length <= 3) {
      return recipe.ingredients.join(', ');
    }
    return '${recipe.ingredients.take(3).join(', ')}, +${recipe.ingredients.length - 3} more';
  }
}

