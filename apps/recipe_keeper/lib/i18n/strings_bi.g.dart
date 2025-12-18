///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'strings.g.dart';

// Path: <root>
class TranslationsBi extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsBi({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.bi,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <bi>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final TranslationsBi _root = this; // ignore: unused_field

	@override 
	TranslationsBi $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsBi(meta: meta ?? this.$meta);

	// Translations
	@override late final _TranslationsAppBi app = _TranslationsAppBi._(_root);
	@override late final _TranslationsHomeBi home = _TranslationsHomeBi._(_root);
	@override late final _TranslationsCommonBi common = _TranslationsCommonBi._(_root);
	@override late final _TranslationsSettingsBi settings = _TranslationsSettingsBi._(_root);
	@override late final _TranslationsRecipesBi recipes = _TranslationsRecipesBi._(_root);
	@override late final _TranslationsRecipeDetailBi recipeDetail = _TranslationsRecipeDetailBi._(_root);
	@override late final _TranslationsFiltersBi filters = _TranslationsFiltersBi._(_root);
	@override late final _TranslationsShoppingListBi shoppingList = _TranslationsShoppingListBi._(_root);
	@override late final _TranslationsMealPlanBi mealPlan = _TranslationsMealPlanBi._(_root);
	@override late final _TranslationsInventoryBi inventory = _TranslationsInventoryBi._(_root);
	@override late final _TranslationsBarcodeScanBi barcodeScan = _TranslationsBarcodeScanBi._(_root);
	@override late final _TranslationsReceiptScanBi receiptScan = _TranslationsReceiptScanBi._(_root);
	@override late final _TranslationsBatchCookingBi batchCooking = _TranslationsBatchCookingBi._(_root);
	@override late final _TranslationsVisitedDomainsBi visitedDomains = _TranslationsVisitedDomainsBi._(_root);
	@override late final _TranslationsDomainDiscoveryBi domainDiscovery = _TranslationsDomainDiscoveryBi._(_root);
	@override late final _TranslationsInventorySuggestionsBi inventorySuggestions = _TranslationsInventorySuggestionsBi._(_root);
	@override late final _TranslationsUpgradeBi upgrade = _TranslationsUpgradeBi._(_root);
	@override late final _TranslationsTourBi tour = _TranslationsTourBi._(_root);
	@override late final _TranslationsManualRecipeBi manualRecipe = _TranslationsManualRecipeBi._(_root);
	@override late final _TranslationsRecipeEditBi recipeEdit = _TranslationsRecipeEditBi._(_root);
	@override late final _TranslationsErrorsBi errors = _TranslationsErrorsBi._(_root);
}

// Path: app
class _TranslationsAppBi extends TranslationsAppEn {
	_TranslationsAppBi._(TranslationsBi root) : this._root = root, super.internal(root);

	final TranslationsBi _root; // ignore: unused_field

	// Translations
	@override String get name => 'Recipe Keeper';
}

// Path: home
class _TranslationsHomeBi extends TranslationsHomeEn {
	_TranslationsHomeBi._(TranslationsBi root) : this._root = root, super.internal(root);

	final TranslationsBi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Recipe Keeper';
	@override String get greeting => 'Hi there! 👋';
	@override String get description => 'Manage your recipes, meal plans, and shopping lists all in one place.';
	@override String get addRecipeFromUrl => 'Add a recipe from URL';
	@override String get createManualRecipe => 'Create manual recipe';
	@override String get browseStoredRecipes => 'Browse stored recipes';
	@override String get openShoppingList => 'Open shopping list';
	@override String get manageInventory => 'Manage inventory';
}

// Path: common
class _TranslationsCommonBi extends TranslationsCommonEn {
	_TranslationsCommonBi._(TranslationsBi root) : this._root = root, super.internal(root);

	final TranslationsBi _root; // ignore: unused_field

	// Translations
	@override String get save => 'Save';
	@override String get cancel => 'Cancel';
	@override String get delete => 'Delete';
	@override String get edit => 'Edit';
	@override String get done => 'Done';
	@override String get close => 'Close';
	@override String get ok => 'OK';
	@override String get yes => 'Yes';
	@override String get no => 'No';
	@override String get loading => 'Loading...';
	@override String get error => 'Error';
	@override String get success => 'Success';
}

// Path: settings
class _TranslationsSettingsBi extends TranslationsSettingsEn {
	_TranslationsSettingsBi._(TranslationsBi root) : this._root = root, super.internal(root);

	final TranslationsBi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Settings';
	@override late final _TranslationsSettingsMeasurementsBi measurements = _TranslationsSettingsMeasurementsBi._(_root);
	@override late final _TranslationsSettingsDataManagementBi dataManagement = _TranslationsSettingsDataManagementBi._(_root);
	@override late final _TranslationsSettingsVersionBi version = _TranslationsSettingsVersionBi._(_root);
}

// Path: recipes
class _TranslationsRecipesBi extends TranslationsRecipesEn {
	_TranslationsRecipesBi._(TranslationsBi root) : this._root = root, super.internal(root);

	final TranslationsBi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Recipes';
	@override String get favorites => 'Favorites';
	@override String get recentlyAdded => 'Recently Added';
	@override String get stored => 'Stored Recipes';
	@override String get add => 'Add Recipe';
	@override String get edit => 'Edit Recipe';
	@override String get delete => 'Delete Recipe';
	@override String get deleteConfirm => 'Are you sure you want to delete "{title}"? This action cannot be undone.';
	@override String get noRecipes => 'No recipes yet';
	@override String get addFirstRecipe => 'Add your first recipe to get started';
	@override String get filter => 'Filter';
	@override String get filtersUpdated => 'Filters updated';
	@override String get editFilters => 'Edit Filters';
	@override String get addToShoppingList => 'Add ingredients to shopping list';
	@override String get ingredientsAdded => 'Recipe ingredients added to shopping list.';
	@override String get addToFavorites => 'Add to favourites';
	@override String get removeFromFavorites => 'Remove favourite';
	@override String get favoritesEmpty => 'Mark recipes as favourites to see them here.';
	@override String get recipeDeleted => 'Recipe deleted';
	@override String get editRecipe => 'Edit recipe';
	@override String get deleteRecipe => 'Delete recipe';
	@override String get addRecipeFromUrl => 'Add recipe from URL';
	@override String get recipeSaved => 'Recipe saved to your library.';
	@override String get failedToSave => 'Failed to save recipe: {error}';
	@override String get saveToLibrary => 'Save to library';
	@override String get viewDetails => 'View details';
}

// Path: recipeDetail
class _TranslationsRecipeDetailBi extends TranslationsRecipeDetailEn {
	_TranslationsRecipeDetailBi._(TranslationsBi root) : this._root = root, super.internal(root);

	final TranslationsBi _root; // ignore: unused_field

	// Translations
	@override String get overview => 'Overview';
	@override String get ingredients => 'Ingredients';
	@override String get preparation => 'Preparation';
	@override String get scaleRecipe => 'Scale Recipe';
	@override String get originalServings => 'Original: {servings} servings';
	@override String get servings => 'Servings';
	@override String get showingMeasurement => 'Showing {system}';
	@override String get changeMeasurement => 'Change';
	@override late final _TranslationsRecipeDetailNutritionBi nutrition = _TranslationsRecipeDetailNutritionBi._(_root);
	@override String get highlights => 'Highlights';
	@override late final _TranslationsRecipeDetailPrepAheadBi prepAhead = _TranslationsRecipeDetailPrepAheadBi._(_root);
	@override String get noInstructions => 'Preparation steps were not provided for this recipe.';
	@override String get noIngredients => 'No ingredients listed';
	@override String get change => 'Change';
}

// Path: filters
class _TranslationsFiltersBi extends TranslationsFiltersEn {
	_TranslationsFiltersBi._(TranslationsBi root) : this._root = root, super.internal(root);

	final TranslationsBi _root; // ignore: unused_field

	// Translations
	@override String get continent => 'Continent';
	@override String get country => 'Country';
	@override String get diet => 'Diet';
	@override String get course => 'Course';
	@override String get none => 'None';
	@override String get all => 'All';
	@override String get searchPlaceholder => 'Search by name or ingredient';
	@override String get clearAll => 'Clear all filters';
	@override String get noMatch => 'No recipes match your filters yet.';
}

// Path: shoppingList
class _TranslationsShoppingListBi extends TranslationsShoppingListEn {
	_TranslationsShoppingListBi._(TranslationsBi root) : this._root = root, super.internal(root);

	final TranslationsBi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Shopping List';
	@override String get empty => 'Your shopping list is empty';
	@override String get emptyDescription => 'Add ingredients from the meal planner or recipe details.';
	@override String get addItems => 'Add items from recipes or scan barcodes';
	@override String get clearCompleted => 'Clear Completed';
	@override String get clearAll => 'Clear All';
	@override String get clearChecked => 'Clear checked items';
	@override String get clearAllItems => 'Clear all items';
	@override String get errorLoading => 'Error loading shopping list';
	@override String get addManualItem => 'Add manual item';
	@override String get scanReceipt => 'Scan receipt (batch add)';
	@override String get scanBarcode => 'Scan barcode';
	@override String get addItem => 'Add item';
	@override String get itemName => 'Item name';
	@override String get addToInventory => 'Add to inventory?';
	@override String get quantity => 'Quantity';
	@override String get unitOptional => 'Unit (optional)';
	@override String get addToInventoryAndRemove => 'Add to inventory & remove';
	@override String get removeFromList => 'Remove from list';
	@override String get keepChecked => 'Keep checked';
	@override String get undoCheck => 'Undo check';
	@override String get organization => 'Organization';
	@override String get groupBy => 'Group by';
	@override String get groupNone => 'None';
	@override String get groupNoneTooltip => 'No grouping';
	@override String get groupCategory => 'Category';
	@override String get groupCategoryTooltip => 'Group by store category';
	@override String get groupRecipe => 'Recipe';
	@override String get groupRecipeTooltip => 'Group by recipe';
	@override String get groupStore => 'Store';
	@override String get groupStoreTooltip => 'Group by store layout';
	@override String get mergeDuplicates => 'Merge duplicates';
	@override String get completed => 'Completed';
	@override String get addedToInventory => 'Added {name} to inventory.';
	@override String get removedFromList => 'Removed "{ingredient}" from the list.';
	@override String get clearedChecked => 'Cleared checked items.';
	@override String get clearedAll => 'Shopping list cleared.';
}

// Path: mealPlan
class _TranslationsMealPlanBi extends TranslationsMealPlanEn {
	_TranslationsMealPlanBi._(TranslationsBi root) : this._root = root, super.internal(root);

	final TranslationsBi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Meal Planner';
	@override String get breakfast => 'Breakfast';
	@override String get lunch => 'Lunch';
	@override String get dinner => 'Dinner';
	@override String get snack => 'Snack';
}

// Path: inventory
class _TranslationsInventoryBi extends TranslationsInventoryEn {
	_TranslationsInventoryBi._(TranslationsBi root) : this._root = root, super.internal(root);

	final TranslationsBi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Inventory';
	@override String get errorLoading => 'Error loading inventory';
	@override String get addItemManually => 'Add item manually';
	@override String get scanReceipt => 'Scan receipt (batch add)';
	@override String get scanBarcode => 'Scan barcode';
	@override String get enterItemName => 'Please enter an item name first';
	@override String get suggestedPrice => 'Suggested price: {price} per unit';
	@override String get noDefaultPrice => 'No default price available for this item';
	@override String get markedLowStock => 'Marked low stock items.';
	@override String get clearInventory => 'Clear inventory';
	@override String get clearInventoryConfirm => 'Are you sure you want to remove all inventory items?';
	@override String get clear => 'Clear';
	@override String get markLowStock => 'Mark low stock (qty ≤ 1)';
	@override String get clearAllItems => 'Clear all items';
}

// Path: barcodeScan
class _TranslationsBarcodeScanBi extends TranslationsBarcodeScanEn {
	_TranslationsBarcodeScanBi._(TranslationsBi root) : this._root = root, super.internal(root);

	final TranslationsBi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Barcode scanner';
	@override String get rescan => 'Rescan';
	@override String get quantity => 'Quantity: {quantity}';
}

// Path: receiptScan
class _TranslationsReceiptScanBi extends TranslationsReceiptScanEn {
	_TranslationsReceiptScanBi._(TranslationsBi root) : this._root = root, super.internal(root);

	final TranslationsBi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Receipt scanner';
	@override String get scanToInventory => 'Scan receipt to add to inventory';
	@override String get scanToShoppingList => 'Scan receipt to add to shopping list';
	@override String get description => 'Snap a clear photo of your grocery receipt or import an image. We will detect items and let you confirm before saving.';
	@override String get capturePhoto => 'Capture photo';
	@override String get pickFromGallery => 'Pick from gallery';
	@override String get clearSelection => 'Clear selection';
	@override String get selectAtLeastOne => 'Please select at least one item.';
}

// Path: batchCooking
class _TranslationsBatchCookingBi extends TranslationsBatchCookingEn {
	_TranslationsBatchCookingBi._(TranslationsBi root) : this._root = root, super.internal(root);

	final TranslationsBi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Batch Cooking';
}

// Path: visitedDomains
class _TranslationsVisitedDomainsBi extends TranslationsVisitedDomainsEn {
	_TranslationsVisitedDomainsBi._(TranslationsBi root) : this._root = root, super.internal(root);

	final TranslationsBi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Visited Domains';
	@override String get noDomains => 'No domains visited yet.';
	@override String get lastImport => 'Last import: {date}';
	@override String get pagesImported => '{count} page{s} imported';
	@override String get scanForNew => 'Scan for new recipes';
}

// Path: domainDiscovery
class _TranslationsDomainDiscoveryBi extends TranslationsDomainDiscoveryEn {
	_TranslationsDomainDiscoveryBi._(TranslationsBi root) : this._root = root, super.internal(root);

	final TranslationsBi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Discover recipes by domain';
	@override String get selectAll => 'Select all';
	@override String get clearSelection => 'Clear selection';
	@override String get tapToParse => 'Tap the icon to parse now';
	@override String get noRecipeStructure => 'No recipe structure found.';
	@override String get skippedImported => 'Skipped {count} already imported page{s}.';
	@override String get savedRecipes => 'Saved {count} recipe{s} to your library.';
}

// Path: inventorySuggestions
class _TranslationsInventorySuggestionsBi extends TranslationsInventorySuggestionsEn {
	_TranslationsInventorySuggestionsBi._(TranslationsBi root) : this._root = root, super.internal(root);

	final TranslationsBi _root; // ignore: unused_field

	// Translations
	@override String get title => 'What Can I Make?';
	@override String get noItems => 'No items in inventory';
	@override String get addItemsDescription => 'Add items to your inventory to see recipe suggestions.';
	@override String get errorLoading => 'Error loading recipes';
}

// Path: upgrade
class _TranslationsUpgradeBi extends TranslationsUpgradeEn {
	_TranslationsUpgradeBi._(TranslationsBi root) : this._root = root, super.internal(root);

	final TranslationsBi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Go Premium';
	@override String get tagline => 'Cook smarter. No ads. Unlimited scans.';
	@override String get description => 'Upgrade to unlock unlimited domain scans, remove ads, and enable smart conversions, translation, planning, and exports.';
	@override String get unlimitedScans => 'Unlimited scans & faster discovery';
	@override String get noAds => 'No ads';
	@override String get smartConversions => 'Smart conversions + translate';
	@override String get mealPlanner => 'Meal planner & PDF export';
	@override String get premiumUnlocked => 'Premium unlocked';
	@override String get startTrial => 'Start 7‑day free trial';
	@override String get continueFree => 'Continue with Free';
}

// Path: tour
class _TranslationsTourBi extends TranslationsTourEn {
	_TranslationsTourBi._(TranslationsBi root) : this._root = root, super.internal(root);

	final TranslationsBi _root; // ignore: unused_field

	// Translations
	@override String get title => 'App Tour';
	@override String get startCompleteTour => 'Start Complete Tour';
	@override String get skip => 'Skip';
	@override String get skipScenario => 'Skip Scenario';
	@override String get back => 'Back';
	@override String get completed => '🎉 Tour completed! You\'re ready to start cooking!';
	@override String get tourCompleted => '🎉 Tour Completed!';
	@override String get readyToStart => 'You\'re now ready to start cooking with Recipe Keeper!';
	@override String get whatYouLearned => 'What You Learned';
	@override String get proTips => 'Pro Tips';
	@override String get startCooking => 'Start Cooking!';
	@override String get autoAdvanceMode => 'Auto-advance mode';
	@override String get autoAdvanceDescription => 'Automatically move to next step after 5 seconds';
	@override String get quickTipsMode => 'Quick tips mode';
	@override String get quickTipsDescription => 'Show condensed instructions';
	@override String get proTip1 => 'Use domain discovery to pull whole recipe libraries';
	@override String get proTip2 => 'Favorite recipes to surface them in meal planning';
	@override String get proTip3 => 'Keep your inventory updated for better recipe suggestions';
}

// Path: manualRecipe
class _TranslationsManualRecipeBi extends TranslationsManualRecipeEn {
	_TranslationsManualRecipeBi._(TranslationsBi root) : this._root = root, super.internal(root);

	final TranslationsBi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Create manual recipe';
	@override String get ingredients => 'Ingredients';
	@override String get instructions => 'Instructions';
	@override String get categories => 'Categories';
	@override String get add => 'Add';
	@override String get addStep => 'Add step';
	@override String get addIngredientRequired => 'Add at least one ingredient.';
	@override String get instructionRequired => 'Add at least one instruction step.';
	@override String get recipeSaved => 'Manual recipe saved.';
	@override String get markAsFavourite => 'Mark as favourite';
}

// Path: recipeEdit
class _TranslationsRecipeEditBi extends TranslationsRecipeEditEn {
	_TranslationsRecipeEditBi._(TranslationsBi root) : this._root = root, super.internal(root);

	final TranslationsBi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Edit recipe';
	@override String get ingredients => 'Ingredients';
	@override String get instructions => 'Instructions';
	@override String get categories => 'Categories';
	@override String get add => 'Add';
	@override String get addStep => 'Add step';
	@override String get addIngredientRequired => 'Add at least one ingredient.';
	@override String get addInstructionRequired => 'Add at least one instruction step.';
	@override String get recipeUpdated => 'Recipe updated successfully.';
	@override String get updateFailed => 'Failed to update recipe: {error}';
}

// Path: errors
class _TranslationsErrorsBi extends TranslationsErrorsEn {
	_TranslationsErrorsBi._(TranslationsBi root) : this._root = root, super.internal(root);

	final TranslationsBi _root; // ignore: unused_field

	// Translations
	@override String get initializationError => 'Initialization Error';
	@override String get initializationFailed => 'Failed to Initialize App';
	@override String get initializationDescription => 'The app encountered an error while loading your data. This can happen if data was corrupted during an update.';
	@override String get errorDetails => 'Error Details:';
	@override String get tryAgain => 'Try Again';
	@override String get dataCorrupted => 'The app\'s data appears to be corrupted and cannot be loaded.';
	@override String get retry => 'Retry';
	@override String get clearData => 'Clear All Data';
	@override String get clearDataConfirm => 'This will permanently delete all your recipes, meal plans, shopping list, and inventory. This action cannot be undone.';
	@override String get clearDataSuccess => 'All data has been cleared. The app will restart.';
	@override String get clearDataAndRestart => 'Clear All Data & Restart';
	@override String get errorLoadingRecipes => 'Error loading recipes';
	@override String get errorLoadingFavorites => 'Error loading favorites';
}

// Path: settings.measurements
class _TranslationsSettingsMeasurementsBi extends TranslationsSettingsMeasurementsEn {
	_TranslationsSettingsMeasurementsBi._(TranslationsBi root) : this._root = root, super.internal(root);

	final TranslationsBi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Measurements';
	@override String get description => 'Choose how ingredient units are displayed. Recipes using a different system will be automatically converted to your preference.';
	@override late final _TranslationsSettingsMeasurementsMetricBi metric = _TranslationsSettingsMeasurementsMetricBi._(_root);
	@override late final _TranslationsSettingsMeasurementsImperialBi imperial = _TranslationsSettingsMeasurementsImperialBi._(_root);
}

// Path: settings.dataManagement
class _TranslationsSettingsDataManagementBi extends TranslationsSettingsDataManagementEn {
	_TranslationsSettingsDataManagementBi._(TranslationsBi root) : this._root = root, super.internal(root);

	final TranslationsBi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Data Management';
	@override String get description => 'Export your recipes, meal plans, shopping list, and inventory to a JSON file. You can import this file later to restore your data.';
	@override String get exportData => 'Export Data';
	@override String get exportDataDescription => 'Save all your data to a JSON file';
	@override String get importData => 'Import Data';
	@override String get importDataDescription => 'Restore data from a JSON backup file';
	@override String get exportSuccess => 'Data exported successfully to:\n{path}';
	@override String get exportError => 'Failed to export data: {error}';
	@override String get importSuccess => 'Data imported successfully!';
	@override String get importError => 'Failed to import data: {error}';
}

// Path: settings.version
class _TranslationsSettingsVersionBi extends TranslationsSettingsVersionEn {
	_TranslationsSettingsVersionBi._(TranslationsBi root) : this._root = root, super.internal(root);

	final TranslationsBi _root; // ignore: unused_field

	// Translations
	@override String get loading => 'Loading version info...';
	@override String get format => 'Version {version} (Build {buildNumber})';
	@override String get package => 'Package: {packageName}';
}

// Path: recipeDetail.nutrition
class _TranslationsRecipeDetailNutritionBi extends TranslationsRecipeDetailNutritionEn {
	_TranslationsRecipeDetailNutritionBi._(TranslationsBi root) : this._root = root, super.internal(root);

	final TranslationsBi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Nutrition';
	@override String get calories => 'Calories';
	@override String get caloriesPerServing => '{calories} kcal/serving';
	@override String get protein => 'Protein';
	@override String get carbs => 'Carbs';
	@override String get fat => 'Fat';
	@override String get fiber => 'Fiber';
	@override String get sugar => 'Sugar';
	@override String get sodium => 'Sodium';
	@override String get estimated => 'Estimated nutrition values';
}

// Path: recipeDetail.prepAhead
class _TranslationsRecipeDetailPrepAheadBi extends TranslationsRecipeDetailPrepAheadEn {
	_TranslationsRecipeDetailPrepAheadBi._(TranslationsBi root) : this._root = root, super.internal(root);

	final TranslationsBi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Prep Ahead';
	@override String get description => 'These steps can be done ahead of time to save you time on cooking day:';
}

// Path: settings.measurements.metric
class _TranslationsSettingsMeasurementsMetricBi extends TranslationsSettingsMeasurementsMetricEn {
	_TranslationsSettingsMeasurementsMetricBi._(TranslationsBi root) : this._root = root, super.internal(root);

	final TranslationsBi _root; // ignore: unused_field

	// Translations
	@override String get name => 'Metric (grams & milliliters)';
	@override String get description => 'Ingredients show grams, kilograms, milliliters and liters.';
}

// Path: settings.measurements.imperial
class _TranslationsSettingsMeasurementsImperialBi extends TranslationsSettingsMeasurementsImperialEn {
	_TranslationsSettingsMeasurementsImperialBi._(TranslationsBi root) : this._root = root, super.internal(root);

	final TranslationsBi _root; // ignore: unused_field

	// Translations
	@override String get name => 'US Customary (cups & ounces)';
	@override String get description => 'Ingredients show cups, tablespoons, teaspoons, ounces and pounds.';
}

/// The flat map containing all translations for locale <bi>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsBi {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'app.name' => 'Recipe Keeper',
			'home.title' => 'Recipe Keeper',
			'home.greeting' => 'Hi there! 👋',
			'home.description' => 'Manage your recipes, meal plans, and shopping lists all in one place.',
			'home.addRecipeFromUrl' => 'Add a recipe from URL',
			'home.createManualRecipe' => 'Create manual recipe',
			'home.browseStoredRecipes' => 'Browse stored recipes',
			'home.openShoppingList' => 'Open shopping list',
			'home.manageInventory' => 'Manage inventory',
			'common.save' => 'Save',
			'common.cancel' => 'Cancel',
			'common.delete' => 'Delete',
			'common.edit' => 'Edit',
			'common.done' => 'Done',
			'common.close' => 'Close',
			'common.ok' => 'OK',
			'common.yes' => 'Yes',
			'common.no' => 'No',
			'common.loading' => 'Loading...',
			'common.error' => 'Error',
			'common.success' => 'Success',
			'settings.title' => 'Settings',
			'settings.measurements.title' => 'Measurements',
			'settings.measurements.description' => 'Choose how ingredient units are displayed. Recipes using a different system will be automatically converted to your preference.',
			'settings.measurements.metric.name' => 'Metric (grams & milliliters)',
			'settings.measurements.metric.description' => 'Ingredients show grams, kilograms, milliliters and liters.',
			'settings.measurements.imperial.name' => 'US Customary (cups & ounces)',
			'settings.measurements.imperial.description' => 'Ingredients show cups, tablespoons, teaspoons, ounces and pounds.',
			'settings.dataManagement.title' => 'Data Management',
			'settings.dataManagement.description' => 'Export your recipes, meal plans, shopping list, and inventory to a JSON file. You can import this file later to restore your data.',
			'settings.dataManagement.exportData' => 'Export Data',
			'settings.dataManagement.exportDataDescription' => 'Save all your data to a JSON file',
			'settings.dataManagement.importData' => 'Import Data',
			'settings.dataManagement.importDataDescription' => 'Restore data from a JSON backup file',
			'settings.dataManagement.exportSuccess' => 'Data exported successfully to:\n{path}',
			'settings.dataManagement.exportError' => 'Failed to export data: {error}',
			'settings.dataManagement.importSuccess' => 'Data imported successfully!',
			'settings.dataManagement.importError' => 'Failed to import data: {error}',
			'settings.version.loading' => 'Loading version info...',
			'settings.version.format' => 'Version {version} (Build {buildNumber})',
			'settings.version.package' => 'Package: {packageName}',
			'recipes.title' => 'Recipes',
			'recipes.favorites' => 'Favorites',
			'recipes.recentlyAdded' => 'Recently Added',
			'recipes.stored' => 'Stored Recipes',
			'recipes.add' => 'Add Recipe',
			'recipes.edit' => 'Edit Recipe',
			'recipes.delete' => 'Delete Recipe',
			'recipes.deleteConfirm' => 'Are you sure you want to delete "{title}"? This action cannot be undone.',
			'recipes.noRecipes' => 'No recipes yet',
			'recipes.addFirstRecipe' => 'Add your first recipe to get started',
			'recipes.filter' => 'Filter',
			'recipes.filtersUpdated' => 'Filters updated',
			'recipes.editFilters' => 'Edit Filters',
			'recipes.addToShoppingList' => 'Add ingredients to shopping list',
			'recipes.ingredientsAdded' => 'Recipe ingredients added to shopping list.',
			'recipes.addToFavorites' => 'Add to favourites',
			'recipes.removeFromFavorites' => 'Remove favourite',
			'recipes.favoritesEmpty' => 'Mark recipes as favourites to see them here.',
			'recipes.recipeDeleted' => 'Recipe deleted',
			'recipes.editRecipe' => 'Edit recipe',
			'recipes.deleteRecipe' => 'Delete recipe',
			'recipes.addRecipeFromUrl' => 'Add recipe from URL',
			'recipes.recipeSaved' => 'Recipe saved to your library.',
			'recipes.failedToSave' => 'Failed to save recipe: {error}',
			'recipes.saveToLibrary' => 'Save to library',
			'recipes.viewDetails' => 'View details',
			'recipeDetail.overview' => 'Overview',
			'recipeDetail.ingredients' => 'Ingredients',
			'recipeDetail.preparation' => 'Preparation',
			'recipeDetail.scaleRecipe' => 'Scale Recipe',
			'recipeDetail.originalServings' => 'Original: {servings} servings',
			'recipeDetail.servings' => 'Servings',
			'recipeDetail.showingMeasurement' => 'Showing {system}',
			'recipeDetail.changeMeasurement' => 'Change',
			'recipeDetail.nutrition.title' => 'Nutrition',
			'recipeDetail.nutrition.calories' => 'Calories',
			'recipeDetail.nutrition.caloriesPerServing' => '{calories} kcal/serving',
			'recipeDetail.nutrition.protein' => 'Protein',
			'recipeDetail.nutrition.carbs' => 'Carbs',
			'recipeDetail.nutrition.fat' => 'Fat',
			'recipeDetail.nutrition.fiber' => 'Fiber',
			'recipeDetail.nutrition.sugar' => 'Sugar',
			'recipeDetail.nutrition.sodium' => 'Sodium',
			'recipeDetail.nutrition.estimated' => 'Estimated nutrition values',
			'recipeDetail.highlights' => 'Highlights',
			'recipeDetail.prepAhead.title' => 'Prep Ahead',
			'recipeDetail.prepAhead.description' => 'These steps can be done ahead of time to save you time on cooking day:',
			'recipeDetail.noInstructions' => 'Preparation steps were not provided for this recipe.',
			'recipeDetail.noIngredients' => 'No ingredients listed',
			'recipeDetail.change' => 'Change',
			'filters.continent' => 'Continent',
			'filters.country' => 'Country',
			'filters.diet' => 'Diet',
			'filters.course' => 'Course',
			'filters.none' => 'None',
			'filters.all' => 'All',
			'filters.searchPlaceholder' => 'Search by name or ingredient',
			'filters.clearAll' => 'Clear all filters',
			'filters.noMatch' => 'No recipes match your filters yet.',
			'shoppingList.title' => 'Shopping List',
			'shoppingList.empty' => 'Your shopping list is empty',
			'shoppingList.emptyDescription' => 'Add ingredients from the meal planner or recipe details.',
			'shoppingList.addItems' => 'Add items from recipes or scan barcodes',
			'shoppingList.clearCompleted' => 'Clear Completed',
			'shoppingList.clearAll' => 'Clear All',
			'shoppingList.clearChecked' => 'Clear checked items',
			'shoppingList.clearAllItems' => 'Clear all items',
			'shoppingList.errorLoading' => 'Error loading shopping list',
			'shoppingList.addManualItem' => 'Add manual item',
			'shoppingList.scanReceipt' => 'Scan receipt (batch add)',
			'shoppingList.scanBarcode' => 'Scan barcode',
			'shoppingList.addItem' => 'Add item',
			'shoppingList.itemName' => 'Item name',
			'shoppingList.addToInventory' => 'Add to inventory?',
			'shoppingList.quantity' => 'Quantity',
			'shoppingList.unitOptional' => 'Unit (optional)',
			'shoppingList.addToInventoryAndRemove' => 'Add to inventory & remove',
			'shoppingList.removeFromList' => 'Remove from list',
			'shoppingList.keepChecked' => 'Keep checked',
			'shoppingList.undoCheck' => 'Undo check',
			'shoppingList.organization' => 'Organization',
			'shoppingList.groupBy' => 'Group by',
			'shoppingList.groupNone' => 'None',
			'shoppingList.groupNoneTooltip' => 'No grouping',
			'shoppingList.groupCategory' => 'Category',
			'shoppingList.groupCategoryTooltip' => 'Group by store category',
			'shoppingList.groupRecipe' => 'Recipe',
			'shoppingList.groupRecipeTooltip' => 'Group by recipe',
			'shoppingList.groupStore' => 'Store',
			'shoppingList.groupStoreTooltip' => 'Group by store layout',
			'shoppingList.mergeDuplicates' => 'Merge duplicates',
			'shoppingList.completed' => 'Completed',
			'shoppingList.addedToInventory' => 'Added {name} to inventory.',
			'shoppingList.removedFromList' => 'Removed "{ingredient}" from the list.',
			'shoppingList.clearedChecked' => 'Cleared checked items.',
			'shoppingList.clearedAll' => 'Shopping list cleared.',
			'mealPlan.title' => 'Meal Planner',
			'mealPlan.breakfast' => 'Breakfast',
			'mealPlan.lunch' => 'Lunch',
			'mealPlan.dinner' => 'Dinner',
			'mealPlan.snack' => 'Snack',
			'inventory.title' => 'Inventory',
			'inventory.errorLoading' => 'Error loading inventory',
			'inventory.addItemManually' => 'Add item manually',
			'inventory.scanReceipt' => 'Scan receipt (batch add)',
			'inventory.scanBarcode' => 'Scan barcode',
			'inventory.enterItemName' => 'Please enter an item name first',
			'inventory.suggestedPrice' => 'Suggested price: {price} per unit',
			'inventory.noDefaultPrice' => 'No default price available for this item',
			'inventory.markedLowStock' => 'Marked low stock items.',
			'inventory.clearInventory' => 'Clear inventory',
			'inventory.clearInventoryConfirm' => 'Are you sure you want to remove all inventory items?',
			'inventory.clear' => 'Clear',
			'inventory.markLowStock' => 'Mark low stock (qty ≤ 1)',
			'inventory.clearAllItems' => 'Clear all items',
			'barcodeScan.title' => 'Barcode scanner',
			'barcodeScan.rescan' => 'Rescan',
			'barcodeScan.quantity' => 'Quantity: {quantity}',
			'receiptScan.title' => 'Receipt scanner',
			'receiptScan.scanToInventory' => 'Scan receipt to add to inventory',
			'receiptScan.scanToShoppingList' => 'Scan receipt to add to shopping list',
			'receiptScan.description' => 'Snap a clear photo of your grocery receipt or import an image. We will detect items and let you confirm before saving.',
			'receiptScan.capturePhoto' => 'Capture photo',
			'receiptScan.pickFromGallery' => 'Pick from gallery',
			'receiptScan.clearSelection' => 'Clear selection',
			'receiptScan.selectAtLeastOne' => 'Please select at least one item.',
			'batchCooking.title' => 'Batch Cooking',
			'visitedDomains.title' => 'Visited Domains',
			'visitedDomains.noDomains' => 'No domains visited yet.',
			'visitedDomains.lastImport' => 'Last import: {date}',
			'visitedDomains.pagesImported' => '{count} page{s} imported',
			'visitedDomains.scanForNew' => 'Scan for new recipes',
			'domainDiscovery.title' => 'Discover recipes by domain',
			'domainDiscovery.selectAll' => 'Select all',
			'domainDiscovery.clearSelection' => 'Clear selection',
			'domainDiscovery.tapToParse' => 'Tap the icon to parse now',
			'domainDiscovery.noRecipeStructure' => 'No recipe structure found.',
			'domainDiscovery.skippedImported' => 'Skipped {count} already imported page{s}.',
			'domainDiscovery.savedRecipes' => 'Saved {count} recipe{s} to your library.',
			'inventorySuggestions.title' => 'What Can I Make?',
			'inventorySuggestions.noItems' => 'No items in inventory',
			'inventorySuggestions.addItemsDescription' => 'Add items to your inventory to see recipe suggestions.',
			'inventorySuggestions.errorLoading' => 'Error loading recipes',
			'upgrade.title' => 'Go Premium',
			'upgrade.tagline' => 'Cook smarter. No ads. Unlimited scans.',
			'upgrade.description' => 'Upgrade to unlock unlimited domain scans, remove ads, and enable smart conversions, translation, planning, and exports.',
			'upgrade.unlimitedScans' => 'Unlimited scans & faster discovery',
			'upgrade.noAds' => 'No ads',
			'upgrade.smartConversions' => 'Smart conversions + translate',
			'upgrade.mealPlanner' => 'Meal planner & PDF export',
			'upgrade.premiumUnlocked' => 'Premium unlocked',
			'upgrade.startTrial' => 'Start 7‑day free trial',
			'upgrade.continueFree' => 'Continue with Free',
			'tour.title' => 'App Tour',
			'tour.startCompleteTour' => 'Start Complete Tour',
			'tour.skip' => 'Skip',
			'tour.skipScenario' => 'Skip Scenario',
			'tour.back' => 'Back',
			'tour.completed' => '🎉 Tour completed! You\'re ready to start cooking!',
			'tour.tourCompleted' => '🎉 Tour Completed!',
			'tour.readyToStart' => 'You\'re now ready to start cooking with Recipe Keeper!',
			'tour.whatYouLearned' => 'What You Learned',
			'tour.proTips' => 'Pro Tips',
			'tour.startCooking' => 'Start Cooking!',
			'tour.autoAdvanceMode' => 'Auto-advance mode',
			'tour.autoAdvanceDescription' => 'Automatically move to next step after 5 seconds',
			'tour.quickTipsMode' => 'Quick tips mode',
			'tour.quickTipsDescription' => 'Show condensed instructions',
			'tour.proTip1' => 'Use domain discovery to pull whole recipe libraries',
			'tour.proTip2' => 'Favorite recipes to surface them in meal planning',
			'tour.proTip3' => 'Keep your inventory updated for better recipe suggestions',
			'manualRecipe.title' => 'Create manual recipe',
			'manualRecipe.ingredients' => 'Ingredients',
			'manualRecipe.instructions' => 'Instructions',
			'manualRecipe.categories' => 'Categories',
			'manualRecipe.add' => 'Add',
			'manualRecipe.addStep' => 'Add step',
			'manualRecipe.addIngredientRequired' => 'Add at least one ingredient.',
			'manualRecipe.instructionRequired' => 'Add at least one instruction step.',
			'manualRecipe.recipeSaved' => 'Manual recipe saved.',
			'manualRecipe.markAsFavourite' => 'Mark as favourite',
			'recipeEdit.title' => 'Edit recipe',
			'recipeEdit.ingredients' => 'Ingredients',
			'recipeEdit.instructions' => 'Instructions',
			'recipeEdit.categories' => 'Categories',
			'recipeEdit.add' => 'Add',
			'recipeEdit.addStep' => 'Add step',
			'recipeEdit.addIngredientRequired' => 'Add at least one ingredient.',
			'recipeEdit.addInstructionRequired' => 'Add at least one instruction step.',
			'recipeEdit.recipeUpdated' => 'Recipe updated successfully.',
			'recipeEdit.updateFailed' => 'Failed to update recipe: {error}',
			'errors.initializationError' => 'Initialization Error',
			'errors.initializationFailed' => 'Failed to Initialize App',
			'errors.initializationDescription' => 'The app encountered an error while loading your data. This can happen if data was corrupted during an update.',
			'errors.errorDetails' => 'Error Details:',
			'errors.tryAgain' => 'Try Again',
			'errors.dataCorrupted' => 'The app\'s data appears to be corrupted and cannot be loaded.',
			'errors.retry' => 'Retry',
			'errors.clearData' => 'Clear All Data',
			'errors.clearDataConfirm' => 'This will permanently delete all your recipes, meal plans, shopping list, and inventory. This action cannot be undone.',
			'errors.clearDataSuccess' => 'All data has been cleared. The app will restart.',
			'errors.clearDataAndRestart' => 'Clear All Data & Restart',
			'errors.errorLoadingRecipes' => 'Error loading recipes',
			'errors.errorLoadingFavorites' => 'Error loading favorites',
			_ => null,
		};
	}
}
