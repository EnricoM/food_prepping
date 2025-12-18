import 'package:flutter/material.dart';
import 'package:meal_planner/meal_planner.dart';

import '../../i18n/strings.g.dart';
import '../services/tour_service.dart';
import '../navigation/app_drawer.dart';
import '../widgets/back_aware_app_bar.dart';
import 'add_recipe_screen.dart';
import 'stored_recipes_screen.dart';
import 'home_screen.dart';
import 'shopping_list_screen.dart';

class TourScreen extends StatefulWidget {
  const TourScreen({super.key, this.autoStart = false});

  static const routeName = '/tour';

  final bool autoStart;

  @override
  State<TourScreen> createState() => _TourScreenState();
}

class _TourScreenState extends State<TourScreen> {

  @override
  void initState() {
    super.initState();
    if (widget.autoStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startTour();
      });
    }
  }

  void _startTour() {
    _showScenario1Step1();
  }

  // Scenario 1: Adding Recipes
  void _showScenario1Step1() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _TourStepDialog(
        title: 'Scenario 1: Adding Recipes to Your Collection',
        stepNumber: 1,
        totalSteps: 4,
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Step 1: Enter Recipe URL',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _InstructionStep(
              number: '1',
              text: 'Find a recipe URL from any cooking website (e.g., AllRecipes, Food Network, BBC Good Food)',
            ),
            _InstructionStep(
              number: '2',
              text: 'Copy the URL from your browser',
            ),
            _InstructionStep(
              number: '3',
              text: 'Tap the "Recipe URL" text field at the top of the screen',
            ),
            _InstructionStep(
              number: '4',
              text: 'Paste the URL into the field (or use the paste button on the right)',
            ),
            SizedBox(height: 12),
            _HighlightBox(
              icon: Icons.info_outline,
              text: 'Tip: You can also manually type the URL if needed',
            ),
          ],
        ),
        onNext: () {
          Navigator.of(context).pop();
          _navigateToScenario1();
        },
        onSkip: () {
          Navigator.of(context).pop();
          _navigateToScenario1();
        },
        onComplete: () {
          Navigator.of(context).pop();
          _navigateToScenario1();
        },
      ),
    );
  }

  void _navigateToScenario1() {
    Navigator.of(context).pushNamed(AddRecipeScreen.routeName).then((_) {
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            _showScenario1Step2();
          }
        });
      }
    });
  }

  void _continueScenario1() {
    // After step 2, show step 3
    _showScenario1Step3();
  }

  void _showScenario1Step2() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _TourStepDialog(
        title: 'Scenario 1: Adding Recipes',
        stepNumber: 2,
        totalSteps: 4,
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Step 2: Parse the Recipe',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _InstructionStep(
              number: '1',
              text: 'After pasting the URL, look for the green "Parse recipe" button below the text field',
            ),
            _InstructionStep(
              number: '2',
              text: 'Tap the "Parse recipe" button (it has a play arrow icon)',
            ),
            _InstructionStep(
              number: '3',
              text: 'Wait a few seconds while the app extracts the recipe details',
            ),
            SizedBox(height: 12),
            _HighlightBox(
              icon: Icons.auto_awesome,
              text: 'The app automatically extracts: title, ingredients, instructions, cooking time, and more!',
            ),
          ],
        ),
        onNext: () {
          Navigator.of(context).pop();
          _continueScenario1();
        },
        onSkip: () {
          Navigator.of(context).pop();
          _continueScenario1();
        },
      ),
    );
  }

  void _showScenario1Step3() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _TourStepDialog(
        title: 'Scenario 1: Adding Recipes',
        stepNumber: 3,
        totalSteps: 4,
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Step 3: Review the Parsed Recipe',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _InstructionStep(
              number: '1',
              text: 'After parsing, you\'ll see a preview card showing the recipe details',
            ),
            _InstructionStep(
              number: '2',
              text: 'Review the recipe title, image, and ingredients preview',
            ),
            _InstructionStep(
              number: '3',
              text: 'You can tap "View details" to see the full recipe before saving',
            ),
            SizedBox(height: 12),
            _HighlightBox(
              icon: Icons.visibility,
              text: 'Always review the parsed recipe to ensure accuracy',
            ),
          ],
        ),
        onNext: () {
          Navigator.of(context).pop();
          _showScenario1Step4();
        },
        onSkip: () {
          Navigator.of(context).pop();
          _showScenario1Step4();
        },
      ),
    );
  }

  void _showScenario1Step4() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _TourStepDialog(
        title: 'Scenario 1: Adding Recipes',
        stepNumber: 4,
        totalSteps: 4,
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Step 4: Save to Your Library',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _InstructionStep(
              number: '1',
              text: 'Once you\'re happy with the parsed recipe, tap the "Save to library" button',
            ),
            _InstructionStep(
              number: '2',
              text: 'The recipe is now saved and accessible from "Stored recipes" in the menu',
            ),
            _InstructionStep(
              number: '3',
              text: 'You can also create manual recipes by going to Menu → "Create manual recipe"',
            ),
            SizedBox(height: 12),
            _HighlightBox(
              icon: Icons.check_circle,
              text: 'Great! You\'ve successfully added a recipe. Let\'s move to meal planning!',
            ),
          ],
        ),
        onNext: () {
          Navigator.of(context).pop();
          _showScenario2Step1();
        },
        onSkip: () {
          Navigator.of(context).pop();
          _showScenario2Step1();
        },
        isLast: true,
        onComplete: () {
          Navigator.of(context).pop();
          _showScenario2Step1();
        },
      ),
    );
  }

  // Scenario 2: Meal Planning
  void _showScenario2Step1() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _TourStepDialog(
        title: 'Scenario 2: Meal Prepping for Tomorrow',
        stepNumber: 1,
        totalSteps: 6,
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Step 1: Open Meal Planner',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _InstructionStep(
              number: '1',
              text: 'Open the menu drawer (hamburger icon in the top left)',
            ),
            _InstructionStep(
              number: '2',
              text: 'Tap on "Meal planner" under the "Meal Planning" section',
            ),
            _InstructionStep(
              number: '3',
              text: 'You\'ll see a calendar view showing your meal plan',
            ),
            SizedBox(height: 12),
            _HighlightBox(
              icon: Icons.calendar_today,
              text: 'The calendar helps you plan meals for different days of the week',
            ),
          ],
        ),
        onNext: () {
          Navigator.of(context).pop();
          _navigateToScenario2();
        },
        onSkip: () {
          Navigator.of(context).pop();
          _navigateToScenario2();
        },
      ),
    );
  }

  void _navigateToScenario2() {
    Navigator.of(context).pushNamed(MealPlanScreen.routeName).then((_) {
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            _showScenario2Step2();
          }
        });
      }
    });
  }

  void _showScenario2Step2() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _TourStepDialog(
        title: 'Scenario 2: Meal Prepping',
        stepNumber: 2,
        totalSteps: 6,
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Step 2: Select Tomorrow\'s Date',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _InstructionStep(
              number: '1',
              text: 'Tap on tomorrow\'s date in the calendar',
            ),
            _InstructionStep(
              number: '2',
              text: 'The selected date will be highlighted',
            ),
            _InstructionStep(
              number: '3',
              text: 'You\'ll see meal slots: Breakfast, Lunch, Dinner, and Snacks',
            ),
            SizedBox(height: 12),
            _HighlightBox(
              icon: Icons.restaurant,
              text: 'You can plan different recipes for each meal of the day',
            ),
          ],
        ),
        onNext: () {
          Navigator.of(context).pop();
          _showScenario2Step3();
        },
        onSkip: () {
          Navigator.of(context).pop();
          _showScenario2Step3();
        },
      ),
    );
  }

  void _showScenario2Step3() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _TourStepDialog(
        title: 'Scenario 2: Meal Prepping',
        stepNumber: 3,
        totalSteps: 6,
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Step 3: Add Recipes to Meal Slots',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _InstructionStep(
              number: '1',
              text: 'Scroll down to see the recipe suggestions below the calendar',
            ),
            _InstructionStep(
              number: '2',
              text: 'Tap on a recipe card to add it to a meal slot',
            ),
            _InstructionStep(
              number: '3',
              text: 'Select which meal (Breakfast, Lunch, Dinner, or Snack)',
            ),
            _InstructionStep(
              number: '4',
              text: 'Repeat for other meals you want to plan',
            ),
            SizedBox(height: 12),
            _HighlightBox(
              icon: Icons.lightbulb,
              text: 'The app suggests recipes based on shared ingredients to reduce waste!',
            ),
          ],
        ),
        onNext: () {
          Navigator.of(context).pop();
          _showScenario2Step4();
        },
        onSkip: () {
          Navigator.of(context).pop();
          _showScenario2Step4();
        },
      ),
    );
  }

  void _showScenario2Step4() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _TourStepDialog(
        title: 'Scenario 2: Meal Prepping',
        stepNumber: 4,
        totalSteps: 6,
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Step 4: Create Shopping List',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _InstructionStep(
              number: '1',
              text: 'After adding recipes, scroll to find the "Add to shopping list" button',
            ),
            _InstructionStep(
              number: '2',
              text: 'Tap "Add to shopping list" - this adds all ingredients from your planned meals',
            ),
            _InstructionStep(
              number: '3',
              text: 'The app automatically combines duplicate ingredients',
            ),
            SizedBox(height: 12),
            _HighlightBox(
              icon: Icons.shopping_cart,
              text: 'Your shopping list is now ready! Let\'s check it out.',
            ),
          ],
        ),
        onNext: () {
          Navigator.of(context).pop();
          _navigateToShoppingList();
        },
        onSkip: () {
          Navigator.of(context).pop();
          _navigateToShoppingList();
        },
      ),
    );
  }

  void _navigateToShoppingList() {
    Navigator.of(context).pushNamed(ShoppingListScreen.routeName).then((_) {
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            _showScenario2Step5();
          }
        });
      }
    });
  }

  void _showScenario2Step5() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _TourStepDialog(
        title: 'Scenario 2: Meal Prepping',
        stepNumber: 5,
        totalSteps: 6,
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Step 5: Check Off Items While Shopping',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _InstructionStep(
              number: '1',
              text: 'When you\'re at the store, tap the checkbox next to each item as you add it to your cart',
            ),
            _InstructionStep(
              number: '2',
              text: 'Checked items move to the bottom of the list',
            ),
            _InstructionStep(
              number: '3',
              text: 'You can swipe left on any item to remove it',
            ),
            SizedBox(height: 12),
            _HighlightBox(
              icon: Icons.checklist,
              text: 'The list is organized by category to make shopping easier',
            ),
          ],
        ),
        onNext: () {
          Navigator.of(context).pop();
          _showScenario2Step6();
        },
        onSkip: () {
          Navigator.of(context).pop();
          _showScenario2Step6();
        },
      ),
    );
  }

  void _showScenario2Step6() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _TourStepDialog(
        title: 'Scenario 2: Meal Prepping',
        stepNumber: 6,
        totalSteps: 6,
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Step 6: Add Purchased Items to Inventory',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _InstructionStep(
              number: '1',
              text: 'After checking off an item, a dialog will appear',
            ),
            _InstructionStep(
              number: '2',
              text: 'Tap "Add to inventory & remove" to track what you have at home',
            ),
            _InstructionStep(
              number: '3',
              text: 'Enter the quantity and unit (optional)',
            ),
            _InstructionStep(
              number: '4',
              text: 'The item is now in your inventory and removed from the shopping list',
            ),
            SizedBox(height: 12),
            _HighlightBox(
              icon: Icons.inventory_2,
              text: 'Your inventory helps the app suggest recipes based on what you already have!',
            ),
          ],
        ),
        onNext: () {
          Navigator.of(context).pop();
          _navigateToScenario3();
        },
        onSkip: () {
          Navigator.of(context).pop();
          _navigateToScenario3();
        },
        isLast: true,
      ),
    );
  }

  void _navigateToScenario3() {
    Navigator.of(context).pushNamed(StoredRecipesScreen.routeName).then((_) {
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            _showScenario3Step1();
          }
        });
      }
    });
  }

  // Scenario 3: Preparing Recipe
  void _showScenario3Step1() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _TourStepDialog(
        title: 'Scenario 3: Preparing a Recipe',
        stepNumber: 1,
        totalSteps: 4,
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Step 1: Select a Recipe',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _InstructionStep(
              number: '1',
              text: 'From the "Stored recipes" screen, tap on any recipe card',
            ),
            _InstructionStep(
              number: '2',
              text: 'This opens the detailed recipe view',
            ),
            _InstructionStep(
              number: '3',
              text: 'You\'ll see tabs for Overview, Ingredients, and Preparation',
            ),
            SizedBox(height: 12),
            _HighlightBox(
              icon: Icons.menu_book,
              text: 'The recipe detail screen is your cooking companion!',
            ),
          ],
        ),
        onNext: () {
          Navigator.of(context).pop();
          _showScenario3Step2();
        },
        onSkip: () {
          Navigator.of(context).pop();
          _showScenario3Step2();
        },
      ),
    );
  }

  void _showScenario3Step2() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _TourStepDialog(
        title: 'Scenario 3: Preparing a Recipe',
        stepNumber: 2,
        totalSteps: 4,
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Step 2: Review Ingredients',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _InstructionStep(
              number: '1',
              text: 'Tap on the "Ingredients" tab at the top',
            ),
            _InstructionStep(
              number: '2',
              text: 'You\'ll see a complete list of all ingredients with quantities',
            ),
            _InstructionStep(
              number: '3',
              text: 'Check off ingredients as you gather them',
            ),
            _InstructionStep(
              number: '4',
              text: 'Use the shopping cart icon in the app bar to add missing ingredients to your shopping list',
            ),
            SizedBox(height: 12),
            _HighlightBox(
              icon: Icons.list_alt,
              text: 'The ingredients list helps you prepare everything before cooking',
            ),
          ],
        ),
        onNext: () {
          Navigator.of(context).pop();
          _showScenario3Step3();
        },
        onSkip: () {
          Navigator.of(context).pop();
          _showScenario3Step3();
        },
      ),
    );
  }

  void _showScenario3Step3() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _TourStepDialog(
        title: 'Scenario 3: Preparing a Recipe',
        stepNumber: 3,
        totalSteps: 4,
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Step 3: Follow Preparation Steps',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _InstructionStep(
              number: '1',
              text: 'Tap on the "Preparation" tab',
            ),
            _InstructionStep(
              number: '2',
              text: 'You\'ll see step-by-step cooking instructions',
            ),
            _InstructionStep(
              number: '3',
              text: 'Check off each step as you complete it',
            ),
            _InstructionStep(
              number: '4',
              text: 'The recipe shows cooking time, servings, and other details in the Overview tab',
            ),
            SizedBox(height: 12),
            _HighlightBox(
              icon: Icons.receipt_long,
              text: 'Following steps in order ensures the best cooking results!',
            ),
          ],
        ),
        onNext: () {
          Navigator.of(context).pop();
          _showScenario3Step4();
        },
        onSkip: () {
          Navigator.of(context).pop();
          _showScenario3Step4();
        },
      ),
    );
  }

  void _showScenario3Step4() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _TourStepDialog(
        title: 'Scenario 3: Preparing a Recipe',
        stepNumber: 4,
        totalSteps: 4,
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Step 4: Favorite Your Best Recipes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _InstructionStep(
              number: '1',
              text: 'Tap the star icon in the app bar to favorite a recipe',
            ),
            _InstructionStep(
              number: '2',
              text: 'Favorited recipes appear in the "Favourites" section',
            ),
            _InstructionStep(
              number: '3',
              text: 'They also get priority in meal planning suggestions',
            ),
            SizedBox(height: 12),
            _HighlightBox(
              icon: Icons.star,
              text: 'Favorites make it easy to find your go-to recipes quickly!',
            ),
          ],
        ),
        onNext: () {
          Navigator.of(context).pop();
          _completeTour();
        },
        onSkip: () {
          Navigator.of(context).pop();
          _completeTour();
        },
        isLast: true,
      ),
    );
  }

  void _completeTour() {
    TourService.instance.markTourCompleted();
    Navigator.of(context).pushNamedAndRemoveUntil(
      HomeScreen.routeName,
      (route) => false,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.t.tour.completed),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: BackAwareAppBar(title: Text(context.t.tour.title)),
      drawer: const AppDrawer(currentRoute: TourScreen.routeName),
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
              const SizedBox(height: 32),
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
                description:
                    'Learn step-by-step how to add recipes from websites or create them manually',
                onTap: () => _showScenario1Step1(),
              ),
              const SizedBox(height: 16),
              _ScenarioCard(
                icon: Icons.calendar_today,
                title: 'Scenario 2: Meal prepping for next day',
                description:
                    'Plan meals, create shopping lists, and manage inventory - complete workflow',
                onTap: () => _showScenario2Step1(),
              ),
              const SizedBox(height: 16),
              _ScenarioCard(
                icon: Icons.restaurant_menu,
                title: 'Scenario 3: Preparing a recipe',
                description:
                    'Use your saved recipes to cook with step-by-step guidance and ingredient tracking',
                onTap: () => _showScenario3Step1(),
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
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: colorScheme.primary,
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
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TourStepDialog extends StatelessWidget {
  const _TourStepDialog({
    required this.title,
    required this.stepNumber,
    required this.totalSteps,
    required this.content,
    required this.onNext,
    required this.onSkip,
    this.isLast = false,
    this.onComplete,
  });

  final String title;
  final int stepNumber;
  final int totalSteps;
  final Widget content;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final bool isLast;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: stepNumber / totalSteps,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
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
      content: SingleChildScrollView(child: content),
      actions: [
        TextButton(
          onPressed: onSkip,
          child: Text(context.t.tour.skip),
        ),
        FilledButton(
          onPressed: () {
            if (isLast && onComplete != null) {
              onComplete!();
            } else {
              onNext();
            }
          },
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
