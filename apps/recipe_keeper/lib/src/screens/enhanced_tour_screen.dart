import 'dart:async';
import 'package:flutter/material.dart';
import 'package:meal_planner/meal_planner.dart';

import '../../i18n/strings.g.dart';
import '../services/tour_service.dart';
import '../services/tour_progress.dart';
import '../navigation/app_drawer.dart';
import '../widgets/back_aware_app_bar.dart';
import 'add_recipe_screen.dart';
import 'stored_recipes_screen.dart';
import 'shopping_list_screen.dart';
import 'tour_completion_screen.dart';

class EnhancedTourScreen extends StatefulWidget {
  const EnhancedTourScreen({super.key, this.autoStart = false, this.resumeFromStep});

  static const routeName = '/tour-enhanced';

  final bool autoStart;
  final Map<String, int>? resumeFromStep; // {'scenario': 1, 'step': 2}

  @override
  State<EnhancedTourScreen> createState() => _EnhancedTourScreenState();
}

class _EnhancedTourScreenState extends State<EnhancedTourScreen> {
  int? _currentScenario;
  int? _currentStep;
  Timer? _autoAdvanceTimer;
  final List<GlobalKey> _showcaseKeys = [];

  @override
  void initState() {
    super.initState();
    _initializeShowcaseKeys();
    if (widget.autoStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startTour();
      });
    }
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    super.dispose();
  }

  void _initializeShowcaseKeys() {
    // Create keys for all showcase highlights
    for (int i = 0; i < 20; i++) {
      _showcaseKeys.add(GlobalKey());
    }
  }

  void _startTour() {
    if (widget.resumeFromStep != null) {
      _currentScenario = widget.resumeFromStep!['scenario'];
      _currentStep = widget.resumeFromStep!['step'];
    } else if (TourService.instance.canResume()) {
      _currentScenario = TourService.instance.getResumeScenario();
      _currentStep = TourService.instance.getResumeStep();
    }
    
    if (_currentScenario == null) {
      _currentScenario = 1;
      _currentStep = 0;
    }
    
    _showStep(_currentScenario!, _currentStep ?? 0);
  }

  void _showStep(int scenario, int step) {
    _currentScenario = scenario;
    _currentStep = step;
    TourProgress.instance.updateProgress(scenario, step);

    switch (scenario) {
      case 1:
        _showScenario1Step(step);
        break;
      case 2:
        _showScenario2Step(step);
        break;
      case 3:
        _showScenario3Step(step);
        break;
    }
  }


  void _previousStep() {
    if (_currentScenario == null || _currentStep == null) return;
    
    if (_currentStep! > 0) {
      _showStep(_currentScenario!, _currentStep! - 1);
    } else if (_currentScenario! > 1) {
      final prevScenarioSteps = TourProgress.instance.getScenarioTotalSteps(_currentScenario! - 1);
      _showStep(_currentScenario! - 1, prevScenarioSteps - 1);
    }
  }

  void _skipScenario() {
    if (_currentScenario == null) return;
    
    if (_currentScenario! < 3) {
      _showStep(_currentScenario! + 1, 0);
    } else {
      _completeTour();
    }
  }

  void _completeTour() {
    TourService.instance.markTourCompleted();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const TourCompletionScreen(),
      ),
    );
  }

  // Scenario 1 Steps
  void _showScenario1Step(int step) {
    switch (step) {
      case 0:
        _showStepDialog(
          scenario: 1,
          step: 0,
          title: 'Scenario 1: Adding Recipes to Your Collection',
          stepTitle: 'Step 1: Enter Recipe URL',
          icon: Icons.link,
          instructions: const [
            'Find a recipe URL from any cooking website',
            'Copy the URL from your browser',
            'Tap the "Recipe URL" text field at the top',
            'Paste the URL (or use the paste button)',
          ],
          tip: 'Tip: You can also manually type the URL if needed',
          onNext: () async {
            Navigator.of(context).pop();
            // Wait for dialog to fully dismiss before navigating
            await Future.delayed(const Duration(milliseconds: 300));
            if (mounted) {
              _navigateToScenario1();
            }
          },
        );
        break;
      case 1:
        _showStepDialog(
          scenario: 1,
          step: 1,
          title: 'Scenario 1: Adding Recipes',
          stepTitle: 'Step 2: Parse the Recipe',
          icon: Icons.auto_awesome,
          instructions: const [
            'After pasting the URL, find the green "Parse recipe" button',
            'Tap the "Parse recipe" button (play arrow icon)',
            'Wait while the app extracts recipe details',
          ],
          tip: 'The app automatically extracts: title, ingredients, instructions, cooking time, and more!',
          onNext: () {
            Navigator.of(context).pop();
            // Stay on current screen, just show next instruction
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted && _currentScenario == 1) {
                _showStep(1, 2); // Show step 3
              }
            });
          },
        );
        break;
      case 2:
        _showStepDialog(
          scenario: 1,
          step: 2,
          title: 'Scenario 1: Adding Recipes',
          stepTitle: 'Step 3: Review the Parsed Recipe',
          icon: Icons.visibility,
          instructions: const [
            'After parsing, you\'ll see a preview card',
            'Review the recipe title, image, and ingredients',
            'Tap "View details" to see the full recipe before saving',
          ],
          tip: 'Always review the parsed recipe to ensure accuracy',
          onNext: () {
            Navigator.of(context).pop();
            // Stay on current screen, just show next instruction
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted && _currentScenario == 1) {
                _showStep(1, 3); // Show step 4
              }
            });
          },
        );
        break;
      case 3:
        _showStepDialog(
          scenario: 1,
          step: 3,
          title: 'Scenario 1: Adding Recipes',
          stepTitle: 'Step 4: Save to Your Library',
          icon: Icons.save,
          instructions: const [
            'Tap the "Save to library" button',
            'The recipe is now saved and accessible',
            'You can also create manual recipes from the menu',
          ],
          tip: 'Great! You\'ve successfully added a recipe. Let\'s move to meal planning!',
          onNext: () {
            Navigator.of(context).pop();
            _showStep(2, 0);
          },
          isLast: true,
        );
        break;
    }
  }

  Future<void> _navigateToScenario1() async {
    // Navigate to AddRecipeScreen and wait for user to return
    await Navigator.of(context).pushNamed(AddRecipeScreen.routeName);
    
    // When user returns from AddRecipeScreen, automatically show next step
    // This ensures the tour continues seamlessly
    if (mounted && _currentScenario == 1) {
      // Small delay to ensure screen is fully rendered after returning
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted && _currentScenario == 1) {
        // Automatically advance to step 1 (which shows step 2 dialog)
        _showStep(1, 1);
      }
    }
  }

  // Scenario 2 Steps
  void _showScenario2Step(int step) {
    switch (step) {
      case 0:
        _showStepDialog(
          scenario: 2,
          step: 0,
          title: 'Scenario 2: Meal Prepping for Tomorrow',
          stepTitle: 'Step 1: Open Meal Planner',
          icon: Icons.calendar_today,
          instructions: const [
            'Open the menu drawer (hamburger icon)',
            'Tap on "Meal planner" under "Meal Planning"',
            'You\'ll see a calendar view',
          ],
          tip: 'The calendar helps you plan meals for different days',
          onNext: () {
            Navigator.of(context).pop();
            _navigateToScenario2();
          },
        );
        break;
      case 1:
        _showStepDialog(
          scenario: 2,
          step: 1,
          title: 'Scenario 2: Meal Prepping',
          stepTitle: 'Step 2: Select Tomorrow\'s Date',
          icon: Icons.event,
          instructions: const [
            'Tap on tomorrow\'s date in the calendar',
            'The selected date will be highlighted',
            'You\'ll see meal slots: Breakfast, Lunch, Dinner, Snacks',
          ],
          tip: 'You can plan different recipes for each meal of the day',
          onNext: () {
            Navigator.of(context).pop();
          },
        );
        break;
      case 2:
        _showStepDialog(
          scenario: 2,
          step: 2,
          title: 'Scenario 2: Meal Prepping',
          stepTitle: 'Step 3: Add Recipes to Meal Slots',
          icon: Icons.restaurant,
          instructions: const [
            'Scroll down to see recipe suggestions',
            'Tap on a recipe card to add it to a meal slot',
            'Select which meal (Breakfast, Lunch, Dinner, or Snack)',
            'Repeat for other meals you want to plan',
          ],
          tip: 'The app suggests recipes based on shared ingredients to reduce waste!',
          onNext: () {
            Navigator.of(context).pop();
          },
        );
        break;
      case 3:
        _showStepDialog(
          scenario: 2,
          step: 3,
          title: 'Scenario 2: Meal Prepping',
          stepTitle: 'Step 4: Create Shopping List',
          icon: Icons.shopping_cart,
          instructions: const [
            'After adding recipes, find "Add to shopping list" button',
            'Tap it - this adds all ingredients from planned meals',
            'The app automatically combines duplicate ingredients',
          ],
          tip: 'Your shopping list is now ready! Let\'s check it out.',
          onNext: () {
            Navigator.of(context).pop();
            _navigateToShoppingList();
          },
        );
        break;
      case 4:
        _showStepDialog(
          scenario: 2,
          step: 4,
          title: 'Scenario 2: Meal Prepping',
          stepTitle: 'Step 5: Check Off Items While Shopping',
          icon: Icons.checklist,
          instructions: const [
            'Tap the checkbox next to each item as you shop',
            'Checked items move to the bottom of the list',
            'You can swipe left on any item to remove it',
          ],
          tip: 'The list is organized by category to make shopping easier',
          onNext: () {
            Navigator.of(context).pop();
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted && _currentScenario == 2) {
                _showStep(2, 5); // Show step 6
              }
            });
          },
        );
        break;
      case 5:
        _showStepDialog(
          scenario: 2,
          step: 5,
          title: 'Scenario 2: Meal Prepping',
          stepTitle: 'Step 6: Add Purchased Items to Inventory',
          icon: Icons.inventory_2,
          instructions: const [
            'After checking off an item, a dialog will appear',
            'Tap "Add to inventory & remove" to track what you have',
            'Enter the quantity and unit (optional)',
            'The item is now in your inventory',
          ],
          tip: 'Your inventory helps the app suggest recipes based on what you already have!',
          onNext: () {
            Navigator.of(context).pop();
            _showStep(3, 0);
          },
          isLast: true,
        );
        break;
    }
  }

  void _navigateToScenario2() {
    Navigator.of(context).pushNamed(MealPlanScreen.routeName).then((_) {
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted && _currentScenario == 2) {
            _showStep(2, 1); // Show step 2
          }
        });
      }
    });
  }

  void _navigateToShoppingList() {
    Navigator.of(context).pushNamed(ShoppingListScreen.routeName).then((_) {
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted && _currentScenario == 2) {
            _showStep(2, 4); // Show step 5 (shopping list step)
          }
        });
      }
    });
  }

  // Scenario 3 Steps
  void _showScenario3Step(int step) {
    switch (step) {
      case 0:
        _showStepDialog(
          scenario: 3,
          step: 0,
          title: 'Scenario 3: Preparing a Recipe',
          stepTitle: 'Step 1: Select a Recipe',
          icon: Icons.menu_book,
          instructions: const [
            'From "Stored recipes", tap on any recipe card',
            'This opens the detailed recipe view',
            'You\'ll see tabs for Overview, Ingredients, and Preparation',
          ],
          tip: 'The recipe detail screen is your cooking companion!',
          onNext: () {
            Navigator.of(context).pop();
            _navigateToScenario3();
          },
        );
        break;
      case 1:
        _showStepDialog(
          scenario: 3,
          step: 1,
          title: 'Scenario 3: Preparing a Recipe',
          stepTitle: 'Step 2: Review Ingredients',
          icon: Icons.list_alt,
          instructions: const [
            'Tap on the "Ingredients" tab at the top',
            'You\'ll see a complete list with quantities',
            'Check off ingredients as you gather them',
            'Use the shopping cart icon to add missing ingredients',
          ],
          tip: 'The ingredients list helps you prepare everything before cooking',
          onNext: () {
            Navigator.of(context).pop();
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted && _currentScenario == 3) {
                _showStep(3, 2); // Show step 3
              }
            });
          },
        );
        break;
      case 2:
        _showStepDialog(
          scenario: 3,
          step: 2,
          title: 'Scenario 3: Preparing a Recipe',
          stepTitle: 'Step 3: Follow Preparation Steps',
          icon: Icons.receipt_long,
          instructions: const [
            'Tap on the "Preparation" tab',
            'You\'ll see step-by-step cooking instructions',
            'Check off each step as you complete it',
            'The recipe shows cooking time and servings in Overview',
          ],
          tip: 'Following steps in order ensures the best cooking results!',
          onNext: () {
            Navigator.of(context).pop();
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted && _currentScenario == 3) {
                _showStep(3, 3); // Show step 4
              }
            });
          },
        );
        break;
      case 3:
        _showStepDialog(
          scenario: 3,
          step: 3,
          title: 'Scenario 3: Preparing a Recipe',
          stepTitle: 'Step 4: Favorite Your Best Recipes',
          icon: Icons.star,
          instructions: const [
            'Tap the star icon in the app bar to favorite a recipe',
            'Favorited recipes appear in "Favourites" section',
            'They also get priority in meal planning suggestions',
          ],
          tip: 'Favorites make it easy to find your go-to recipes quickly!',
          onNext: () {
            Navigator.of(context).pop();
            _completeTour();
          },
          isLast: true,
        );
        break;
    }
  }

  void _navigateToScenario3() {
    Navigator.of(context).pushNamed(StoredRecipesScreen.routeName).then((_) {
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted && _currentScenario == 3) {
            _showStep(3, 1); // Show step 2
          }
        });
      }
    });
  }

  void _showStepDialog({
    required int scenario,
    required int step,
    required String title,
    required String stepTitle,
    required IconData icon,
    required List<String> instructions,
    String? tip,
    required VoidCallback onNext,
    bool isLast = false,
  }) {
    final progress = TourProgress.instance;
    final totalSteps = progress.getScenarioTotalSteps(scenario);
    final quickTips = progress.quickTipsMode;
    
    // Auto-advance setup
    if (progress.autoAdvance && !isLast) {
      _autoAdvanceTimer?.cancel();
      _autoAdvanceTimer = Timer(const Duration(seconds: 5), () {
        if (mounted) {
          Navigator.of(context).pop();
          onNext();
        }
      });
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _EnhancedTourStepDialog(
        title: title,
        stepNumber: step + 1,
        totalSteps: totalSteps,
        stepTitle: stepTitle,
        icon: icon,
        instructions: instructions,
        tip: tip,
        quickTipsMode: quickTips,
        canGoBack: step > 0 || scenario > 1,
        canSkipScenario: !isLast,
        onNext: () {
          _autoAdvanceTimer?.cancel();
          Navigator.of(context).pop();
          onNext();
        },
        onBack: () {
          _autoAdvanceTimer?.cancel();
          Navigator.of(context).pop();
          _previousStep();
        },
        onSkip: () {
          _autoAdvanceTimer?.cancel();
          Navigator.of(context).pop();
          _skipScenario();
        },
        isLast: isLast,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progress = TourProgress.instance;

    return Scaffold(
      appBar: BackAwareAppBar(title: Text(context.t.tour.title)),
      drawer: const AppDrawer(currentRoute: EnhancedTourScreen.routeName),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary.withValues(alpha: 0.1),
                      colorScheme.primary.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.explore,
                      size: 64,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Welcome to Recipe Keeper!',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Take an interactive tour to learn the main features',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Tour Options
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tour Options',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        title: const Text('Auto-advance mode'),
                        subtitle: const Text('Automatically move to next step after 5 seconds'),
                        value: progress.autoAdvance,
                        onChanged: (value) {
                          TourProgress.instance.setAutoAdvance(value);
                          setState(() {});
                        },
                      ),
                      SwitchListTile(
                        title: Text(context.t.tour.quickTipsMode),
                        subtitle: Text(context.t.tour.quickTipsDescription),
                        value: progress.quickTipsMode,
                        onChanged: (value) {
                          TourProgress.instance.setQuickTipsMode(value);
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Progress Indicators
              if (TourService.instance.canResume()) ...[
                Card(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.history, color: colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Resume Tour',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You have an incomplete tour. Tap "Start Complete Tour" to resume.',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Text(
                'Tour Scenarios',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _ScenarioCard(
                icon: Icons.restaurant_menu,
                title: 'Scenario 1: Filling the app with recipes',
                description: 'Learn step-by-step how to add recipes from websites',
                progress: progress.scenario1Progress,
                totalSteps: 4,
                onTap: () => _showStep(1, 0),
              ),
              const SizedBox(height: 16),
              _ScenarioCard(
                icon: Icons.calendar_today,
                title: 'Scenario 2: Meal prepping for next day',
                description: 'Plan meals, create shopping lists, and manage inventory',
                progress: progress.scenario2Progress,
                totalSteps: 6,
                onTap: () => _showStep(2, 0),
              ),
              const SizedBox(height: 16),
              _ScenarioCard(
                icon: Icons.restaurant_menu,
                title: 'Scenario 3: Preparing a recipe',
                description: 'Use your saved recipes to cook with step-by-step guidance',
                progress: progress.scenario3Progress,
                totalSteps: 4,
                onTap: () => _showStep(3, 0),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _startTour,
                icon: const Icon(Icons.play_arrow),
                label: Text(context.t.tour.startCompleteTour),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScenarioCard extends StatelessWidget {
  const _ScenarioCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.progress,
    required this.totalSteps,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final int progress;
  final int totalSteps;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isComplete = progress >= totalSteps;

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isComplete
                          ? colorScheme.primaryContainer
                          : colorScheme.primaryContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isComplete ? Icons.check_circle : icon,
                      color: isComplete ? colorScheme.primary : colorScheme.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isComplete)
                    Icon(
                      Icons.check_circle,
                      color: colorScheme.primary,
                    )
                  else
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                ],
              ),
              if (progress > 0 && !isComplete) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: progress / totalSteps,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$progress/$totalSteps',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EnhancedTourStepDialog extends StatelessWidget {
  const _EnhancedTourStepDialog({
    required this.title,
    required this.stepNumber,
    required this.totalSteps,
    required this.stepTitle,
    required this.icon,
    required this.instructions,
    this.tip,
    required this.quickTipsMode,
    required this.canGoBack,
    required this.canSkipScenario,
    required this.onNext,
    required this.onBack,
    required this.onSkip,
    this.isLast = false,
  });

  final String title;
  final int stepNumber;
  final int totalSteps;
  final String stepTitle;
  final IconData icon;
  final List<String> instructions;
  final String? tip;
  final bool quickTipsMode;
  final bool canGoBack;
  final bool canSkipScenario;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: colorScheme.primary, size: 24),
              const SizedBox(width: 8),
              Expanded(child: Text(title)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: stepNumber / totalSteps,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$stepNumber/$totalSteps',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stepTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (quickTipsMode)
              ...instructions.map((instruction) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.arrow_right, size: 16, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            instruction,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ))
            else
              ...instructions.asMap().entries.map((entry) => _InstructionStep(
                    number: '${entry.key + 1}',
                    text: entry.value,
                  )),
            if (tip != null) ...[
              const SizedBox(height: 12),
              _HighlightBox(icon: Icons.lightbulb_outline, text: tip!),
            ],
          ],
        ),
      ),
      actions: [
        if (canGoBack)
          TextButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
            label: Text(context.t.tour.back),
          ),
        if (canSkipScenario)
          TextButton(
            onPressed: onSkip,
            child: Text(context.t.tour.skipScenario),
          ),
        TextButton(
          onPressed: onSkip,
          child: Text(context.t.tour.skip),
        ),
        FilledButton(
          onPressed: onNext,
          child: Text(isLast ? 'Complete' : 'Next'),
        ),
      ],
    );
  }
}

class _InstructionStep extends StatelessWidget {
  const _InstructionStep({
    required this.number,
    required this.text,
  });

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightBox extends StatelessWidget {
  const _HighlightBox({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

