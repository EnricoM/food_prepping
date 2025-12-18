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
class TranslationsNl extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsNl({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.nl,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <nl>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final TranslationsNl _root = this; // ignore: unused_field

	@override 
	TranslationsNl $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsNl(meta: meta ?? this.$meta);

	// Translations
	@override late final _TranslationsAppNl app = _TranslationsAppNl._(_root);
	@override late final _TranslationsHomeNl home = _TranslationsHomeNl._(_root);
	@override late final _TranslationsCommonNl common = _TranslationsCommonNl._(_root);
	@override late final _TranslationsSettingsNl settings = _TranslationsSettingsNl._(_root);
	@override late final _TranslationsRecipesNl recipes = _TranslationsRecipesNl._(_root);
	@override late final _TranslationsRecipeDetailNl recipeDetail = _TranslationsRecipeDetailNl._(_root);
	@override late final _TranslationsFiltersNl filters = _TranslationsFiltersNl._(_root);
	@override late final _TranslationsShoppingListNl shoppingList = _TranslationsShoppingListNl._(_root);
	@override late final _TranslationsMealPlanNl mealPlan = _TranslationsMealPlanNl._(_root);
	@override late final _TranslationsInventoryNl inventory = _TranslationsInventoryNl._(_root);
	@override late final _TranslationsBarcodeScanNl barcodeScan = _TranslationsBarcodeScanNl._(_root);
	@override late final _TranslationsReceiptScanNl receiptScan = _TranslationsReceiptScanNl._(_root);
	@override late final _TranslationsBatchCookingNl batchCooking = _TranslationsBatchCookingNl._(_root);
	@override late final _TranslationsVisitedDomainsNl visitedDomains = _TranslationsVisitedDomainsNl._(_root);
	@override late final _TranslationsDomainDiscoveryNl domainDiscovery = _TranslationsDomainDiscoveryNl._(_root);
	@override late final _TranslationsInventorySuggestionsNl inventorySuggestions = _TranslationsInventorySuggestionsNl._(_root);
	@override late final _TranslationsUpgradeNl upgrade = _TranslationsUpgradeNl._(_root);
	@override late final _TranslationsTourNl tour = _TranslationsTourNl._(_root);
	@override late final _TranslationsManualRecipeNl manualRecipe = _TranslationsManualRecipeNl._(_root);
	@override late final _TranslationsRecipeEditNl recipeEdit = _TranslationsRecipeEditNl._(_root);
	@override late final _TranslationsErrorsNl errors = _TranslationsErrorsNl._(_root);
}

// Path: app
class _TranslationsAppNl extends TranslationsAppEn {
	_TranslationsAppNl._(TranslationsNl root) : this._root = root, super.internal(root);

	final TranslationsNl _root; // ignore: unused_field

	// Translations
	@override String get name => 'Receptenboek';
}

// Path: home
class _TranslationsHomeNl extends TranslationsHomeEn {
	_TranslationsHomeNl._(TranslationsNl root) : this._root = root, super.internal(root);

	final TranslationsNl _root; // ignore: unused_field

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
class _TranslationsCommonNl extends TranslationsCommonEn {
	_TranslationsCommonNl._(TranslationsNl root) : this._root = root, super.internal(root);

	final TranslationsNl _root; // ignore: unused_field

	// Translations
	@override String get save => 'Opslaan';
	@override String get cancel => 'Annuleren';
	@override String get delete => 'Verwijderen';
	@override String get edit => 'Bewerken';
	@override String get done => 'Gereed';
	@override String get close => 'Sluiten';
	@override String get ok => 'OK';
	@override String get yes => 'Ja';
	@override String get no => 'Nee';
	@override String get loading => 'Bezig met laden...';
	@override String get error => 'Fout';
	@override String get success => 'Geslaagd';
}

// Path: settings
class _TranslationsSettingsNl extends TranslationsSettingsEn {
	_TranslationsSettingsNl._(TranslationsNl root) : this._root = root, super.internal(root);

	final TranslationsNl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Instellingen';
	@override late final _TranslationsSettingsMeasurementsNl measurements = _TranslationsSettingsMeasurementsNl._(_root);
	@override late final _TranslationsSettingsDataManagementNl dataManagement = _TranslationsSettingsDataManagementNl._(_root);
	@override late final _TranslationsSettingsVersionNl version = _TranslationsSettingsVersionNl._(_root);
}

// Path: recipes
class _TranslationsRecipesNl extends TranslationsRecipesEn {
	_TranslationsRecipesNl._(TranslationsNl root) : this._root = root, super.internal(root);

	final TranslationsNl _root; // ignore: unused_field

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
class _TranslationsRecipeDetailNl extends TranslationsRecipeDetailEn {
	_TranslationsRecipeDetailNl._(TranslationsNl root) : this._root = root, super.internal(root);

	final TranslationsNl _root; // ignore: unused_field

	// Translations
	@override String get overview => 'Overview';
	@override String get ingredients => 'Ingredients';
	@override String get preparation => 'Preparation';
	@override String get scaleRecipe => 'Scale Recipe';
	@override String get originalServings => 'Original: {servings} servings';
	@override String get servings => 'Servings';
	@override String get showingMeasurement => 'Showing {system}';
	@override String get changeMeasurement => 'Change';
	@override late final _TranslationsRecipeDetailNutritionNl nutrition = _TranslationsRecipeDetailNutritionNl._(_root);
	@override String get highlights => 'Highlights';
	@override late final _TranslationsRecipeDetailPrepAheadNl prepAhead = _TranslationsRecipeDetailPrepAheadNl._(_root);
	@override String get noInstructions => 'Preparation steps were not provided for this recipe.';
	@override String get noIngredients => 'No ingredients listed';
	@override String get change => 'Change';
}

// Path: filters
class _TranslationsFiltersNl extends TranslationsFiltersEn {
	_TranslationsFiltersNl._(TranslationsNl root) : this._root = root, super.internal(root);

	final TranslationsNl _root; // ignore: unused_field

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
class _TranslationsShoppingListNl extends TranslationsShoppingListEn {
	_TranslationsShoppingListNl._(TranslationsNl root) : this._root = root, super.internal(root);

	final TranslationsNl _root; // ignore: unused_field

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
class _TranslationsMealPlanNl extends TranslationsMealPlanEn {
	_TranslationsMealPlanNl._(TranslationsNl root) : this._root = root, super.internal(root);

	final TranslationsNl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Meal Planner';
	@override String get breakfast => 'Breakfast';
	@override String get lunch => 'Lunch';
	@override String get dinner => 'Dinner';
	@override String get snack => 'Snack';
}

// Path: inventory
class _TranslationsInventoryNl extends TranslationsInventoryEn {
	_TranslationsInventoryNl._(TranslationsNl root) : this._root = root, super.internal(root);

	final TranslationsNl _root; // ignore: unused_field

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
class _TranslationsBarcodeScanNl extends TranslationsBarcodeScanEn {
	_TranslationsBarcodeScanNl._(TranslationsNl root) : this._root = root, super.internal(root);

	final TranslationsNl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Barcode scanner';
	@override String get rescan => 'Rescan';
	@override String get quantity => 'Quantity: {quantity}';
}

// Path: receiptScan
class _TranslationsReceiptScanNl extends TranslationsReceiptScanEn {
	_TranslationsReceiptScanNl._(TranslationsNl root) : this._root = root, super.internal(root);

	final TranslationsNl _root; // ignore: unused_field

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
class _TranslationsBatchCookingNl extends TranslationsBatchCookingEn {
	_TranslationsBatchCookingNl._(TranslationsNl root) : this._root = root, super.internal(root);

	final TranslationsNl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Batch Cooking';
}

// Path: visitedDomains
class _TranslationsVisitedDomainsNl extends TranslationsVisitedDomainsEn {
	_TranslationsVisitedDomainsNl._(TranslationsNl root) : this._root = root, super.internal(root);

	final TranslationsNl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Visited Domains';
	@override String get noDomains => 'No domains visited yet.';
	@override String get lastImport => 'Last import: {date}';
	@override String get pagesImported => '{count} page{s} imported';
	@override String get scanForNew => 'Scan for new recipes';
}

// Path: domainDiscovery
class _TranslationsDomainDiscoveryNl extends TranslationsDomainDiscoveryEn {
	_TranslationsDomainDiscoveryNl._(TranslationsNl root) : this._root = root, super.internal(root);

	final TranslationsNl _root; // ignore: unused_field

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
class _TranslationsInventorySuggestionsNl extends TranslationsInventorySuggestionsEn {
	_TranslationsInventorySuggestionsNl._(TranslationsNl root) : this._root = root, super.internal(root);

	final TranslationsNl _root; // ignore: unused_field

	// Translations
	@override String get title => 'What Can I Make?';
	@override String get noItems => 'No items in inventory';
	@override String get addItemsDescription => 'Add items to your inventory to see recipe suggestions.';
	@override String get errorLoading => 'Error loading recipes';
}

// Path: upgrade
class _TranslationsUpgradeNl extends TranslationsUpgradeEn {
	_TranslationsUpgradeNl._(TranslationsNl root) : this._root = root, super.internal(root);

	final TranslationsNl _root; // ignore: unused_field

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
class _TranslationsTourNl extends TranslationsTourEn {
	_TranslationsTourNl._(TranslationsNl root) : this._root = root, super.internal(root);

	final TranslationsNl _root; // ignore: unused_field

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
class _TranslationsManualRecipeNl extends TranslationsManualRecipeEn {
	_TranslationsManualRecipeNl._(TranslationsNl root) : this._root = root, super.internal(root);

	final TranslationsNl _root; // ignore: unused_field

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
class _TranslationsRecipeEditNl extends TranslationsRecipeEditEn {
	_TranslationsRecipeEditNl._(TranslationsNl root) : this._root = root, super.internal(root);

	final TranslationsNl _root; // ignore: unused_field

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
class _TranslationsErrorsNl extends TranslationsErrorsEn {
	_TranslationsErrorsNl._(TranslationsNl root) : this._root = root, super.internal(root);

	final TranslationsNl _root; // ignore: unused_field

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
class _TranslationsSettingsMeasurementsNl extends TranslationsSettingsMeasurementsEn {
	_TranslationsSettingsMeasurementsNl._(TranslationsNl root) : this._root = root, super.internal(root);

	final TranslationsNl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Maten';
	@override String get description => 'Kies hoe ingrediënten worden weergegeven. Recepten die een ander systeem gebruiken, worden automatisch omgezet naar jouw voorkeur.';
	@override late final _TranslationsSettingsMeasurementsMetricNl metric = _TranslationsSettingsMeasurementsMetricNl._(_root);
	@override late final _TranslationsSettingsMeasurementsImperialNl imperial = _TranslationsSettingsMeasurementsImperialNl._(_root);
}

// Path: settings.dataManagement
class _TranslationsSettingsDataManagementNl extends TranslationsSettingsDataManagementEn {
	_TranslationsSettingsDataManagementNl._(TranslationsNl root) : this._root = root, super.internal(root);

	final TranslationsNl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Gegevensbeheer';
	@override String get description => 'Exporteer uw recepten, maaltijdplannen, boodschappenlijstjes en voorraad naar een JSON-bestand. U kunt dit bestand later importeren om uw gegevens te herstellen.';
	@override String get exportData => 'Gegevens exporteren';
	@override String get exportDataDescription => 'Sla al uw gegevens op in een JSON-bestand';
	@override String get importData => 'Gegevens importeren';
	@override String get importDataDescription => 'Gegevens herstellen vanuit een JSON-back-upbestand';
	@override String get exportSuccess => 'Gegevens succesvol geëxporteerd naar:\n{path}';
	@override String get exportError => 'Exporteren van gegevens mislukt: {error}';
	@override String get importSuccess => 'Gegevens succesvol geïmporteerd!';
	@override String get importError => 'Kan gegevens niet importeren: {error}';
}

// Path: settings.version
class _TranslationsSettingsVersionNl extends TranslationsSettingsVersionEn {
	_TranslationsSettingsVersionNl._(TranslationsNl root) : this._root = root, super.internal(root);

	final TranslationsNl _root; // ignore: unused_field

	// Translations
	@override String get loading => 'Loading version info...';
	@override String get format => 'Version {version} (Build {buildNumber})';
	@override String get package => 'Package: {packageName}';
}

// Path: recipeDetail.nutrition
class _TranslationsRecipeDetailNutritionNl extends TranslationsRecipeDetailNutritionEn {
	_TranslationsRecipeDetailNutritionNl._(TranslationsNl root) : this._root = root, super.internal(root);

	final TranslationsNl _root; // ignore: unused_field

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
class _TranslationsRecipeDetailPrepAheadNl extends TranslationsRecipeDetailPrepAheadEn {
	_TranslationsRecipeDetailPrepAheadNl._(TranslationsNl root) : this._root = root, super.internal(root);

	final TranslationsNl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Prep Ahead';
	@override String get description => 'These steps can be done ahead of time to save you time on cooking day:';
}

// Path: settings.measurements.metric
class _TranslationsSettingsMeasurementsMetricNl extends TranslationsSettingsMeasurementsMetricEn {
	_TranslationsSettingsMeasurementsMetricNl._(TranslationsNl root) : this._root = root, super.internal(root);

	final TranslationsNl _root; // ignore: unused_field

	// Translations
	@override String get name => 'Metrisch (grammen en milliliters)';
	@override String get description => 'Ingrediënten worden weergegeven in gram, kilogram, milliliter en liter.';
}

// Path: settings.measurements.imperial
class _TranslationsSettingsMeasurementsImperialNl extends TranslationsSettingsMeasurementsImperialEn {
	_TranslationsSettingsMeasurementsImperialNl._(TranslationsNl root) : this._root = root, super.internal(root);

	final TranslationsNl _root; // ignore: unused_field

	// Translations
	@override String get name => 'Amerikaanse maatstaven (kopjes en ounces)';
	@override String get description => 'Ingrediënten worden weergegeven in kopjes, eetlepels, theelepels, ounces en ponden.';
}

/// The flat map containing all translations for locale <nl>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsNl {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'app.name' => 'Receptenboek',
			'home.title' => 'Recipe Keeper',
			'home.greeting' => 'Hi there! 👋',
			'home.description' => 'Manage your recipes, meal plans, and shopping lists all in one place.',
			'home.addRecipeFromUrl' => 'Add a recipe from URL',
			'home.createManualRecipe' => 'Create manual recipe',
			'home.browseStoredRecipes' => 'Browse stored recipes',
			'home.openShoppingList' => 'Open shopping list',
			'home.manageInventory' => 'Manage inventory',
			'common.save' => 'Opslaan',
			'common.cancel' => 'Annuleren',
			'common.delete' => 'Verwijderen',
			'common.edit' => 'Bewerken',
			'common.done' => 'Gereed',
			'common.close' => 'Sluiten',
			'common.ok' => 'OK',
			'common.yes' => 'Ja',
			'common.no' => 'Nee',
			'common.loading' => 'Bezig met laden...',
			'common.error' => 'Fout',
			'common.success' => 'Geslaagd',
			'settings.title' => 'Instellingen',
			'settings.measurements.title' => 'Maten',
			'settings.measurements.description' => 'Kies hoe ingrediënten worden weergegeven. Recepten die een ander systeem gebruiken, worden automatisch omgezet naar jouw voorkeur.',
			'settings.measurements.metric.name' => 'Metrisch (grammen en milliliters)',
			'settings.measurements.metric.description' => 'Ingrediënten worden weergegeven in gram, kilogram, milliliter en liter.',
			'settings.measurements.imperial.name' => 'Amerikaanse maatstaven (kopjes en ounces)',
			'settings.measurements.imperial.description' => 'Ingrediënten worden weergegeven in kopjes, eetlepels, theelepels, ounces en ponden.',
			'settings.dataManagement.title' => 'Gegevensbeheer',
			'settings.dataManagement.description' => 'Exporteer uw recepten, maaltijdplannen, boodschappenlijstjes en voorraad naar een JSON-bestand. U kunt dit bestand later importeren om uw gegevens te herstellen.',
			'settings.dataManagement.exportData' => 'Gegevens exporteren',
			'settings.dataManagement.exportDataDescription' => 'Sla al uw gegevens op in een JSON-bestand',
			'settings.dataManagement.importData' => 'Gegevens importeren',
			'settings.dataManagement.importDataDescription' => 'Gegevens herstellen vanuit een JSON-back-upbestand',
			'settings.dataManagement.exportSuccess' => 'Gegevens succesvol geëxporteerd naar:\n{path}',
			'settings.dataManagement.exportError' => 'Exporteren van gegevens mislukt: {error}',
			'settings.dataManagement.importSuccess' => 'Gegevens succesvol geïmporteerd!',
			'settings.dataManagement.importError' => 'Kan gegevens niet importeren: {error}',
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
