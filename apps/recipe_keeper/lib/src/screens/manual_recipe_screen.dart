import 'dart:async';

import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../i18n/strings.g.dart';
import '../navigation/app_drawer.dart';
import '../widgets/back_aware_app_bar.dart';
import 'recipe_detail_screen.dart';

class ManualRecipeScreen extends StatefulWidget {
  const ManualRecipeScreen({super.key, this.drawer});

  static const routeName = '/manual';

  final Widget? drawer;

  @override
  State<ManualRecipeScreen> createState() => _ManualRecipeScreenState();
}

class _ManualRecipeScreenState extends State<ManualRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _servingsController = TextEditingController();
  final _prepMinutesController = TextEditingController();
  final _cookMinutesController = TextEditingController();
  final _ingredientController = TextEditingController();
  final _categoryController = TextEditingController();

  final List<TextEditingController> _instructionControllers = [];
  final List<String> _ingredients = [];
  final List<String> _categories = [];

  bool _isFavorite = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _addInstructionField();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _servingsController.dispose();
    _prepMinutesController.dispose();
    _cookMinutesController.dispose();
    _ingredientController.dispose();
    _categoryController.dispose();
    for (final controller in _instructionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inset = responsivePageInsets(context);
    return Scaffold(
      appBar: BackAwareAppBar(title: Text(context.t.manualRecipe.title)),
      drawer: widget.drawer ??
          const AppDrawer(currentRoute: ManualRecipeScreen.routeName),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: inset,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Recipe title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter a recipe title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _servingsController,
                        decoration: const InputDecoration(
                          labelText: 'Servings',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _prepMinutesController,
                        decoration: const InputDecoration(
                          labelText: 'Prep (min)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _cookMinutesController,
                        decoration: const InputDecoration(
                          labelText: 'Cook (min)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(context.t.manualRecipe.ingredients, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _ingredientController,
                        decoration: const InputDecoration(
                          labelText: 'Add ingredient',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _addIngredient(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: _addIngredient,
                      icon: const Icon(Icons.add),
                      label: Text(context.t.manualRecipe.add),
                    ),
                  ],
                ),
                if (_ingredients.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _ingredients
                        .asMap()
                        .entries
                        .map(
                          (entry) => InputChip(
                            label: Text(entry.value),
                            onDeleted: () => setState(() {
                              _ingredients.removeAt(entry.key);
                            }),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Preview: ${_ingredientsPreview()}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 24),
                Text(context.t.manualRecipe.instructions,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                ..._instructionControllers.asMap().entries.map(
                  (entry) {
                    final index = entry.key;
                    final controller = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: 28, child: Text('${index + 1}.')),
                          Expanded(
                            child: TextField(
                              controller: controller,
                              decoration: const InputDecoration(
                                labelText: 'Instruction step',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            tooltip: 'Remove step',
                            onPressed: _instructionControllers.length <= 1
                                ? null
                                : () => _removeInstructionField(index),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _addInstructionField,
                    icon: const Icon(Icons.add_circle_outline),
                    label: Text(context.t.manualRecipe.addStep),
                  ),
                ),
                const SizedBox(height: 24),
                Text(context.t.manualRecipe.categories,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _categoryController,
                        decoration: const InputDecoration(
                          labelText: 'Add category',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _addCategory(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: _addCategory,
                      icon: const Icon(Icons.add),
                      label: Text(context.t.manualRecipe.add),
                    ),
                  ],
                ),
                if (_categories.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories
                        .asMap()
                        .entries
                        .map(
                          (entry) => InputChip(
                            label: Text(entry.value),
                            onDeleted: () => setState(() {
                              _categories.removeAt(entry.key);
                            }),
                          ),
                        )
                        .toList(),
                  ),
                ],
                const SizedBox(height: 24),
                SwitchListTile.adaptive(
                  value: _isFavorite,
                  onChanged: (value) => setState(() => _isFavorite = value),
                  title: Text(context.t.manualRecipe.markAsFavourite),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _isSaving ? null : _saveRecipe,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(_isSaving ? 'Saving…' : 'Save recipe'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addInstructionField() {
    setState(() {
      _instructionControllers.add(TextEditingController());
    });
  }

  void _removeInstructionField(int index) {
    setState(() {
      final controller = _instructionControllers.removeAt(index);
      controller.dispose();
    });
  }

  void _addIngredient() {
    final text = _ingredientController.text.trim();
    if (text.isEmpty) {
      return;
    }
    setState(() {
      _ingredients.add(text);
    });
    _ingredientController.clear();
  }

  void _addCategory() {
    final text = _categoryController.text.trim();
    if (text.isEmpty) {
      return;
    }
    setState(() {
      _categories.add(text);
    });
    _categoryController.clear();
  }

  String _ingredientsPreview({int maxCount = 3}) {
    if (_ingredients.isEmpty) {
      return 'No ingredients yet';
    }
    final preview = _ingredients.take(maxCount).toList();
    final remaining = _ingredients.length - preview.length;
    final suffix = remaining > 0 ? ' +$remaining more' : '';
    return preview.join(', ') + suffix;
  }

  Duration? _durationFromMinutes(String value) {
    if (value.isEmpty) return null;
    final minutes = int.tryParse(value);
    if (minutes == null || minutes <= 0) return null;
    return Duration(minutes: minutes);
  }

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.t.manualRecipe.addIngredientRequired)),
      );
      return;
    }
    final instructions = _instructionControllers
        .map((controller) => controller.text.trim())
        .where((step) => step.isNotEmpty)
        .toList();
    if (instructions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.t.manualRecipe.addIngredientRequired)),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final metadata = <String, Object?>{
        if (_servingsController.text.trim().isNotEmpty)
          'servings': _servingsController.text.trim(),
        if (_categories.isNotEmpty) 'tags': _categories,
        'source': 'manual',
      };
      final recipe = Recipe(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        ingredientStrings: _ingredients,
        instructions: instructions,
        prepTime: _durationFromMinutes(_prepMinutesController.text.trim()),
        cookTime: _durationFromMinutes(_cookMinutesController.text.trim()),
        totalTime: _computeTotalTime(),
        metadata: metadata,
      );
      final savedUrl = await AppRepositories.instance.recipes.saveManualRecipe(
        recipe: recipe,
        categories: _categories,
        isFavorite: _isFavorite,
      );
      if (!mounted) return;
      final entity = AppRepositories.instance.recipes.entityFor(savedUrl);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Manual recipe saved.')),
      );
      Navigator.of(context).pushNamed(
        RecipeDetailScreen.routeName,
        arguments: RecipeDetailArgs(
          recipe: entity?.toRecipe() ?? recipe,
          entity: entity,
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.t.recipes.failedToSave.replaceAll('{error}', error.toString()))),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Duration? _computeTotalTime() {
    final prep = _durationFromMinutes(_prepMinutesController.text.trim());
    final cook = _durationFromMinutes(_cookMinutesController.text.trim());
    if (prep == null && cook == null) return null;
    return Duration(minutes: (prep?.inMinutes ?? 0) + (cook?.inMinutes ?? 0));
  }
}
