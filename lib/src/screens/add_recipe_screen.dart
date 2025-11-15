import 'dart:async';

import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parsing/parsing.dart';
import 'package:shared_ui/shared_ui.dart';

import '../navigation/app_drawer.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({
    super.key,
    this.drawer,
    required this.onRecipeSaved,
    this.initialUrl,
  });

  static const routeName = '/add';

  final Widget? drawer;
  final void Function(BuildContext context, Recipe recipe) onRecipeSaved;
  final String? initialUrl;

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
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
      appBar: AppBar(title: const Text('Add recipe from URL')),
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
                  onView: () => widget.onRecipeSaved(context, _result!.recipe),
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
      final repositories = AppRepositories.instance;
      await repositories.recipes
          .saveParsedRecipe(result: result, url: url);
      if (!mounted) return;
      final key = result.recipe.sourceUrl?.isNotEmpty == true
          ? result.recipe.sourceUrl!
          : url;
      final entity = repositories.recipes.entityFor(key);
      scaffold.showSnackBar(
        const SnackBar(content: Text('Recipe saved to your library.')),
      );
      widget.onRecipeSaved(
        context,
        entity?.toRecipe() ?? result.recipe,
      );
    } catch (error) {
      scaffold.showSnackBar(
        SnackBar(content: Text('Failed to save recipe: $error')),
      );
    }
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      recipe.imageUrl!,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox(
                        width: 120,
                        height: 120,
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: Colors.black12),
                          child: Icon(Icons.image_not_supported),
                        ),
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
                        ingredientsPreview(recipe),
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
}
