import 'dart:async';

import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

import '../widgets/back_aware_app_bar.dart';
import 'recipe_detail_screen.dart';

class EditRecipeScreen extends StatefulWidget {
  const EditRecipeScreen({
    super.key,
    required this.recipe,
    required this.entity,
  });

  final Recipe recipe;
  final RecipeEntity entity;

  @override
  State<EditRecipeScreen> createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _servingsController;
  late final TextEditingController _prepMinutesController;
  late final TextEditingController _cookMinutesController;
  late final TextEditingController _ingredientController;
  late final TextEditingController _categoryController;

  late final List<TextEditingController> _instructionControllers;
  late final List<String> _ingredients;
  late final List<String> _categories;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final recipe = widget.recipe;
    _titleController = TextEditingController(text: recipe.title);
    _descriptionController = TextEditingController(text: recipe.description ?? '');
    _servingsController = TextEditingController(
      text: recipe.servings ?? recipe.yield ?? '',
    );
    _prepMinutesController = TextEditingController(
      text: recipe.prepTime?.inMinutes.toString() ?? '',
    );
    _cookMinutesController = TextEditingController(
      text: recipe.cookTime?.inMinutes.toString() ?? '',
    );
    _ingredientController = TextEditingController();
    _categoryController = TextEditingController();
    
    _ingredients = List<String>.from(recipe.ingredients);
    _categories = List<String>.from(widget.entity.normalizedCategories);
    _instructionControllers = recipe.instructions
        .map((instruction) => TextEditingController(text: instruction))
        .toList();
    
    if (_instructionControllers.isEmpty) {
      _addInstructionField();
    }
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
      appBar: BackAwareAppBar(title: const Text('Edit recipe')),
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
                const Text('Ingredients', style: TextStyle()),
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
                      label: const Text('Add'),
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
                ],
                const SizedBox(height: 24),
                Text('Instructions',
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
                    label: const Text('Add step'),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Categories',
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
                      label: const Text('Add'),
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
                FilledButton.icon(
                  onPressed: _isSaving ? null : _saveRecipe,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(_isSaving ? 'Saving…' : 'Save changes'),
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
        const SnackBar(content: Text('Add at least one ingredient.')),
      );
      return;
    }
    final instructions = _instructionControllers
        .map((controller) => controller.text.trim())
        .where((step) => step.isNotEmpty)
        .toList();
    if (instructions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one instruction step.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final metadata = <String, Object?>{
        ...widget.recipe.metadata,
        if (_servingsController.text.trim().isNotEmpty)
          'servings': _servingsController.text.trim(),
        if (_categories.isNotEmpty) 'tags': _categories,
      };
      final updatedRecipe = _buildUpdatedRecipe(metadata, instructions);
      await AppRepositories.instance.recipes.updateRecipe(
        url: widget.entity.url,
        recipe: updatedRecipe,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Success')),
      );
      Navigator.of(context).pop();
      // Refresh the detail screen by popping and pushing again
      final updatedEntity = AppRepositories.instance.recipes.entityFor(widget.entity.url);
      if (updatedEntity != null && mounted) {
        Navigator.of(context).pushReplacementNamed(
          RecipeDetailScreen.routeName,
          arguments: RecipeDetailArgs(
            recipe: updatedEntity.toRecipe(),
            entity: updatedEntity,
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save recipe: $error')),
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

  Recipe _buildUpdatedRecipe(Map<String, Object?> metadata, List<String> instructions) {
    final servingsText = _servingsController.text.trim();
    final recipeYield = servingsText.isEmpty ? null : servingsText;
    return widget.recipe.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      ingredients: IngredientParser.parseList(_ingredients),
      instructions: instructions,
      prepTime: _durationFromMinutes(_prepMinutesController.text.trim()),
      cookTime: _durationFromMinutes(_cookMinutesController.text.trim()),
      totalTime: _computeTotalTime(),
      metadata: metadata,
      yield: recipeYield,
    );
  }
}

