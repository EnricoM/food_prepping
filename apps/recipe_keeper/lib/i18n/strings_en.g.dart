///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final TranslationsAppEn app = TranslationsAppEn.internal(_root);
	late final TranslationsHomeEn home = TranslationsHomeEn.internal(_root);
	late final TranslationsCommonEn common = TranslationsCommonEn.internal(_root);
	late final TranslationsSettingsEn settings = TranslationsSettingsEn.internal(_root);
	late final TranslationsRecipesEn recipes = TranslationsRecipesEn.internal(_root);
	late final TranslationsRecipeDetailEn recipeDetail = TranslationsRecipeDetailEn.internal(_root);
	late final TranslationsFiltersEn filters = TranslationsFiltersEn.internal(_root);
	late final TranslationsShoppingListEn shoppingList = TranslationsShoppingListEn.internal(_root);
	late final TranslationsMealPlanEn mealPlan = TranslationsMealPlanEn.internal(_root);
	late final TranslationsInventoryEn inventory = TranslationsInventoryEn.internal(_root);
	late final TranslationsBarcodeScanEn barcodeScan = TranslationsBarcodeScanEn.internal(_root);
	late final TranslationsReceiptScanEn receiptScan = TranslationsReceiptScanEn.internal(_root);
	late final TranslationsBatchCookingEn batchCooking = TranslationsBatchCookingEn.internal(_root);
	late final TranslationsVisitedDomainsEn visitedDomains = TranslationsVisitedDomainsEn.internal(_root);
	late final TranslationsDomainDiscoveryEn domainDiscovery = TranslationsDomainDiscoveryEn.internal(_root);
	late final TranslationsInventorySuggestionsEn inventorySuggestions = TranslationsInventorySuggestionsEn.internal(_root);
	late final TranslationsUpgradeEn upgrade = TranslationsUpgradeEn.internal(_root);
	late final TranslationsTourEn tour = TranslationsTourEn.internal(_root);
	late final TranslationsManualRecipeEn manualRecipe = TranslationsManualRecipeEn.internal(_root);
	late final TranslationsRecipeEditEn recipeEdit = TranslationsRecipeEditEn.internal(_root);
	late final TranslationsErrorsEn errors = TranslationsErrorsEn.internal(_root);
}

// Path: app
class TranslationsAppEn {
	TranslationsAppEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Recipe Keeper'
	String get name => 'Recipe Keeper';
}

// Path: home
class TranslationsHomeEn {
	TranslationsHomeEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Recipe Keeper'
	String get title => 'Recipe Keeper';

	/// en: 'Hi there! 👋'
	String get greeting => 'Hi there! 👋';

	/// en: 'Manage your recipes, meal plans, and shopping lists all in one place.'
	String get description => 'Manage your recipes, meal plans, and shopping lists all in one place.';

	/// en: 'Add a recipe from URL'
	String get addRecipeFromUrl => 'Add a recipe from URL';

	/// en: 'Create manual recipe'
	String get createManualRecipe => 'Create manual recipe';

	/// en: 'Browse stored recipes'
	String get browseStoredRecipes => 'Browse stored recipes';

	/// en: 'Open shopping list'
	String get openShoppingList => 'Open shopping list';

	/// en: 'Manage inventory'
	String get manageInventory => 'Manage inventory';
}

// Path: common
class TranslationsCommonEn {
	TranslationsCommonEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Save'
	String get save => 'Save';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Delete'
	String get delete => 'Delete';

	/// en: 'Edit'
	String get edit => 'Edit';

	/// en: 'Done'
	String get done => 'Done';

	/// en: 'Close'
	String get close => 'Close';

	/// en: 'OK'
	String get ok => 'OK';

	/// en: 'Yes'
	String get yes => 'Yes';

	/// en: 'No'
	String get no => 'No';

	/// en: 'Loading...'
	String get loading => 'Loading...';

	/// en: 'Error'
	String get error => 'Error';

	/// en: 'Success'
	String get success => 'Success';
}

// Path: settings
class TranslationsSettingsEn {
	TranslationsSettingsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Settings'
	String get title => 'Settings';

	late final TranslationsSettingsMeasurementsEn measurements = TranslationsSettingsMeasurementsEn.internal(_root);
	late final TranslationsSettingsDataManagementEn dataManagement = TranslationsSettingsDataManagementEn.internal(_root);
	late final TranslationsSettingsVersionEn version = TranslationsSettingsVersionEn.internal(_root);
}

// Path: recipes
class TranslationsRecipesEn {
	TranslationsRecipesEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Recipes'
	String get title => 'Recipes';

	/// en: 'Favorites'
	String get favorites => 'Favorites';

	/// en: 'Recently Added'
	String get recentlyAdded => 'Recently Added';

	/// en: 'Stored Recipes'
	String get stored => 'Stored Recipes';

	/// en: 'Add Recipe'
	String get add => 'Add Recipe';

	/// en: 'Edit Recipe'
	String get edit => 'Edit Recipe';

	/// en: 'Delete Recipe'
	String get delete => 'Delete Recipe';

	/// en: 'Are you sure you want to delete "{title}"? This action cannot be undone.'
	String get deleteConfirm => 'Are you sure you want to delete "{title}"? This action cannot be undone.';

	/// en: 'No recipes yet'
	String get noRecipes => 'No recipes yet';

	/// en: 'Add your first recipe to get started'
	String get addFirstRecipe => 'Add your first recipe to get started';

	/// en: 'Filter'
	String get filter => 'Filter';

	/// en: 'Filters updated'
	String get filtersUpdated => 'Filters updated';

	/// en: 'Edit Filters'
	String get editFilters => 'Edit Filters';

	/// en: 'Add ingredients to shopping list'
	String get addToShoppingList => 'Add ingredients to shopping list';

	/// en: 'Recipe ingredients added to shopping list.'
	String get ingredientsAdded => 'Recipe ingredients added to shopping list.';

	/// en: 'Add to favourites'
	String get addToFavorites => 'Add to favourites';

	/// en: 'Remove favourite'
	String get removeFromFavorites => 'Remove favourite';

	/// en: 'Mark recipes as favourites to see them here.'
	String get favoritesEmpty => 'Mark recipes as favourites to see them here.';

	/// en: 'Recipe deleted'
	String get recipeDeleted => 'Recipe deleted';

	/// en: 'Edit recipe'
	String get editRecipe => 'Edit recipe';

	/// en: 'Delete recipe'
	String get deleteRecipe => 'Delete recipe';

	/// en: 'Add recipe from URL'
	String get addRecipeFromUrl => 'Add recipe from URL';

	/// en: 'Recipe saved to your library.'
	String get recipeSaved => 'Recipe saved to your library.';

	/// en: 'Failed to save recipe: {error}'
	String get failedToSave => 'Failed to save recipe: {error}';

	/// en: 'Save to library'
	String get saveToLibrary => 'Save to library';

	/// en: 'View details'
	String get viewDetails => 'View details';
}

// Path: recipeDetail
class TranslationsRecipeDetailEn {
	TranslationsRecipeDetailEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Overview'
	String get overview => 'Overview';

	/// en: 'Ingredients'
	String get ingredients => 'Ingredients';

	/// en: 'Preparation'
	String get preparation => 'Preparation';

	/// en: 'Scale Recipe'
	String get scaleRecipe => 'Scale Recipe';

	/// en: 'Original: {servings} servings'
	String get originalServings => 'Original: {servings} servings';

	/// en: 'Servings'
	String get servings => 'Servings';

	/// en: 'Showing {system}'
	String get showingMeasurement => 'Showing {system}';

	/// en: 'Change'
	String get changeMeasurement => 'Change';

	late final TranslationsRecipeDetailNutritionEn nutrition = TranslationsRecipeDetailNutritionEn.internal(_root);

	/// en: 'Highlights'
	String get highlights => 'Highlights';

	late final TranslationsRecipeDetailPrepAheadEn prepAhead = TranslationsRecipeDetailPrepAheadEn.internal(_root);

	/// en: 'Preparation steps were not provided for this recipe.'
	String get noInstructions => 'Preparation steps were not provided for this recipe.';

	/// en: 'No ingredients listed'
	String get noIngredients => 'No ingredients listed';

	/// en: 'Change'
	String get change => 'Change';
}

// Path: filters
class TranslationsFiltersEn {
	TranslationsFiltersEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Continent'
	String get continent => 'Continent';

	/// en: 'Country'
	String get country => 'Country';

	/// en: 'Diet'
	String get diet => 'Diet';

	/// en: 'Course'
	String get course => 'Course';

	/// en: 'None'
	String get none => 'None';

	/// en: 'All'
	String get all => 'All';

	/// en: 'Search by name or ingredient'
	String get searchPlaceholder => 'Search by name or ingredient';

	/// en: 'Clear all filters'
	String get clearAll => 'Clear all filters';

	/// en: 'No recipes match your filters yet.'
	String get noMatch => 'No recipes match your filters yet.';
}

// Path: shoppingList
class TranslationsShoppingListEn {
	TranslationsShoppingListEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Shopping List'
	String get title => 'Shopping List';

	/// en: 'Your shopping list is empty'
	String get empty => 'Your shopping list is empty';

	/// en: 'Add ingredients from the meal planner or recipe details.'
	String get emptyDescription => 'Add ingredients from the meal planner or recipe details.';

	/// en: 'Add items from recipes or scan barcodes'
	String get addItems => 'Add items from recipes or scan barcodes';

	/// en: 'Clear Completed'
	String get clearCompleted => 'Clear Completed';

	/// en: 'Clear All'
	String get clearAll => 'Clear All';

	/// en: 'Clear checked items'
	String get clearChecked => 'Clear checked items';

	/// en: 'Clear all items'
	String get clearAllItems => 'Clear all items';

	/// en: 'Error loading shopping list'
	String get errorLoading => 'Error loading shopping list';

	/// en: 'Add manual item'
	String get addManualItem => 'Add manual item';

	/// en: 'Scan receipt (batch add)'
	String get scanReceipt => 'Scan receipt (batch add)';

	/// en: 'Scan barcode'
	String get scanBarcode => 'Scan barcode';

	/// en: 'Add item'
	String get addItem => 'Add item';

	/// en: 'Item name'
	String get itemName => 'Item name';

	/// en: 'Add to inventory?'
	String get addToInventory => 'Add to inventory?';

	/// en: 'Quantity'
	String get quantity => 'Quantity';

	/// en: 'Unit (optional)'
	String get unitOptional => 'Unit (optional)';

	/// en: 'Add to inventory & remove'
	String get addToInventoryAndRemove => 'Add to inventory & remove';

	/// en: 'Remove from list'
	String get removeFromList => 'Remove from list';

	/// en: 'Keep checked'
	String get keepChecked => 'Keep checked';

	/// en: 'Undo check'
	String get undoCheck => 'Undo check';

	/// en: 'Organization'
	String get organization => 'Organization';

	/// en: 'Group by'
	String get groupBy => 'Group by';

	/// en: 'None'
	String get groupNone => 'None';

	/// en: 'No grouping'
	String get groupNoneTooltip => 'No grouping';

	/// en: 'Category'
	String get groupCategory => 'Category';

	/// en: 'Group by store category'
	String get groupCategoryTooltip => 'Group by store category';

	/// en: 'Recipe'
	String get groupRecipe => 'Recipe';

	/// en: 'Group by recipe'
	String get groupRecipeTooltip => 'Group by recipe';

	/// en: 'Store'
	String get groupStore => 'Store';

	/// en: 'Group by store layout'
	String get groupStoreTooltip => 'Group by store layout';

	/// en: 'Merge duplicates'
	String get mergeDuplicates => 'Merge duplicates';

	/// en: 'Completed'
	String get completed => 'Completed';

	/// en: 'Added {name} to inventory.'
	String get addedToInventory => 'Added {name} to inventory.';

	/// en: 'Removed "{ingredient}" from the list.'
	String get removedFromList => 'Removed "{ingredient}" from the list.';

	/// en: 'Cleared checked items.'
	String get clearedChecked => 'Cleared checked items.';

	/// en: 'Shopping list cleared.'
	String get clearedAll => 'Shopping list cleared.';
}

// Path: mealPlan
class TranslationsMealPlanEn {
	TranslationsMealPlanEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Meal Planner'
	String get title => 'Meal Planner';

	/// en: 'Breakfast'
	String get breakfast => 'Breakfast';

	/// en: 'Lunch'
	String get lunch => 'Lunch';

	/// en: 'Dinner'
	String get dinner => 'Dinner';

	/// en: 'Snack'
	String get snack => 'Snack';
}

// Path: inventory
class TranslationsInventoryEn {
	TranslationsInventoryEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Inventory'
	String get title => 'Inventory';

	/// en: 'Error loading inventory'
	String get errorLoading => 'Error loading inventory';

	/// en: 'Add item manually'
	String get addItemManually => 'Add item manually';

	/// en: 'Scan receipt (batch add)'
	String get scanReceipt => 'Scan receipt (batch add)';

	/// en: 'Scan barcode'
	String get scanBarcode => 'Scan barcode';

	/// en: 'Please enter an item name first'
	String get enterItemName => 'Please enter an item name first';

	/// en: 'Suggested price: {price} per unit'
	String get suggestedPrice => 'Suggested price: {price} per unit';

	/// en: 'No default price available for this item'
	String get noDefaultPrice => 'No default price available for this item';

	/// en: 'Marked low stock items.'
	String get markedLowStock => 'Marked low stock items.';

	/// en: 'Clear inventory'
	String get clearInventory => 'Clear inventory';

	/// en: 'Are you sure you want to remove all inventory items?'
	String get clearInventoryConfirm => 'Are you sure you want to remove all inventory items?';

	/// en: 'Clear'
	String get clear => 'Clear';

	/// en: 'Mark low stock (qty ≤ 1)'
	String get markLowStock => 'Mark low stock (qty ≤ 1)';

	/// en: 'Clear all items'
	String get clearAllItems => 'Clear all items';
}

// Path: barcodeScan
class TranslationsBarcodeScanEn {
	TranslationsBarcodeScanEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Barcode scanner'
	String get title => 'Barcode scanner';

	/// en: 'Rescan'
	String get rescan => 'Rescan';

	/// en: 'Quantity: {quantity}'
	String get quantity => 'Quantity: {quantity}';
}

// Path: receiptScan
class TranslationsReceiptScanEn {
	TranslationsReceiptScanEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Receipt scanner'
	String get title => 'Receipt scanner';

	/// en: 'Scan receipt to add to inventory'
	String get scanToInventory => 'Scan receipt to add to inventory';

	/// en: 'Scan receipt to add to shopping list'
	String get scanToShoppingList => 'Scan receipt to add to shopping list';

	/// en: 'Snap a clear photo of your grocery receipt or import an image. We will detect items and let you confirm before saving.'
	String get description => 'Snap a clear photo of your grocery receipt or import an image. We will detect items and let you confirm before saving.';

	/// en: 'Capture photo'
	String get capturePhoto => 'Capture photo';

	/// en: 'Pick from gallery'
	String get pickFromGallery => 'Pick from gallery';

	/// en: 'Clear selection'
	String get clearSelection => 'Clear selection';

	/// en: 'Please select at least one item.'
	String get selectAtLeastOne => 'Please select at least one item.';
}

// Path: batchCooking
class TranslationsBatchCookingEn {
	TranslationsBatchCookingEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Batch Cooking'
	String get title => 'Batch Cooking';
}

// Path: visitedDomains
class TranslationsVisitedDomainsEn {
	TranslationsVisitedDomainsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Visited Domains'
	String get title => 'Visited Domains';

	/// en: 'No domains visited yet.'
	String get noDomains => 'No domains visited yet.';

	/// en: 'Last import: {date}'
	String get lastImport => 'Last import: {date}';

	/// en: '{count} page{s} imported'
	String get pagesImported => '{count} page{s} imported';

	/// en: 'Scan for new recipes'
	String get scanForNew => 'Scan for new recipes';
}

// Path: domainDiscovery
class TranslationsDomainDiscoveryEn {
	TranslationsDomainDiscoveryEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Discover recipes by domain'
	String get title => 'Discover recipes by domain';

	/// en: 'Select all'
	String get selectAll => 'Select all';

	/// en: 'Clear selection'
	String get clearSelection => 'Clear selection';

	/// en: 'Tap the icon to parse now'
	String get tapToParse => 'Tap the icon to parse now';

	/// en: 'No recipe structure found.'
	String get noRecipeStructure => 'No recipe structure found.';

	/// en: 'Skipped {count} already imported page{s}.'
	String get skippedImported => 'Skipped {count} already imported page{s}.';

	/// en: 'Saved {count} recipe{s} to your library.'
	String get savedRecipes => 'Saved {count} recipe{s} to your library.';
}

// Path: inventorySuggestions
class TranslationsInventorySuggestionsEn {
	TranslationsInventorySuggestionsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'What Can I Make?'
	String get title => 'What Can I Make?';

	/// en: 'No items in inventory'
	String get noItems => 'No items in inventory';

	/// en: 'Add items to your inventory to see recipe suggestions.'
	String get addItemsDescription => 'Add items to your inventory to see recipe suggestions.';

	/// en: 'Error loading recipes'
	String get errorLoading => 'Error loading recipes';
}

// Path: upgrade
class TranslationsUpgradeEn {
	TranslationsUpgradeEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Go Premium'
	String get title => 'Go Premium';

	/// en: 'Cook smarter. No ads. Unlimited scans.'
	String get tagline => 'Cook smarter. No ads. Unlimited scans.';

	/// en: 'Upgrade to unlock unlimited domain scans, remove ads, and enable smart conversions, translation, planning, and exports.'
	String get description => 'Upgrade to unlock unlimited domain scans, remove ads, and enable smart conversions, translation, planning, and exports.';

	/// en: 'Unlimited scans & faster discovery'
	String get unlimitedScans => 'Unlimited scans & faster discovery';

	/// en: 'No ads'
	String get noAds => 'No ads';

	/// en: 'Smart conversions + translate'
	String get smartConversions => 'Smart conversions + translate';

	/// en: 'Meal planner & PDF export'
	String get mealPlanner => 'Meal planner & PDF export';

	/// en: 'Premium unlocked'
	String get premiumUnlocked => 'Premium unlocked';

	/// en: 'Start 7‑day free trial'
	String get startTrial => 'Start 7‑day free trial';

	/// en: 'Continue with Free'
	String get continueFree => 'Continue with Free';
}

// Path: tour
class TranslationsTourEn {
	TranslationsTourEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'App Tour'
	String get title => 'App Tour';

	/// en: 'Start Complete Tour'
	String get startCompleteTour => 'Start Complete Tour';

	/// en: 'Skip'
	String get skip => 'Skip';

	/// en: 'Skip Scenario'
	String get skipScenario => 'Skip Scenario';

	/// en: 'Back'
	String get back => 'Back';

	/// en: '🎉 Tour completed! You're ready to start cooking!'
	String get completed => '🎉 Tour completed! You\'re ready to start cooking!';

	/// en: '🎉 Tour Completed!'
	String get tourCompleted => '🎉 Tour Completed!';

	/// en: 'You're now ready to start cooking with Recipe Keeper!'
	String get readyToStart => 'You\'re now ready to start cooking with Recipe Keeper!';

	/// en: 'What You Learned'
	String get whatYouLearned => 'What You Learned';

	/// en: 'Pro Tips'
	String get proTips => 'Pro Tips';

	/// en: 'Start Cooking!'
	String get startCooking => 'Start Cooking!';

	/// en: 'Auto-advance mode'
	String get autoAdvanceMode => 'Auto-advance mode';

	/// en: 'Automatically move to next step after 5 seconds'
	String get autoAdvanceDescription => 'Automatically move to next step after 5 seconds';

	/// en: 'Quick tips mode'
	String get quickTipsMode => 'Quick tips mode';

	/// en: 'Show condensed instructions'
	String get quickTipsDescription => 'Show condensed instructions';

	/// en: 'Use domain discovery to pull whole recipe libraries'
	String get proTip1 => 'Use domain discovery to pull whole recipe libraries';

	/// en: 'Favorite recipes to surface them in meal planning'
	String get proTip2 => 'Favorite recipes to surface them in meal planning';

	/// en: 'Keep your inventory updated for better recipe suggestions'
	String get proTip3 => 'Keep your inventory updated for better recipe suggestions';
}

// Path: manualRecipe
class TranslationsManualRecipeEn {
	TranslationsManualRecipeEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Create manual recipe'
	String get title => 'Create manual recipe';

	/// en: 'Ingredients'
	String get ingredients => 'Ingredients';

	/// en: 'Instructions'
	String get instructions => 'Instructions';

	/// en: 'Categories'
	String get categories => 'Categories';

	/// en: 'Add'
	String get add => 'Add';

	/// en: 'Add step'
	String get addStep => 'Add step';

	/// en: 'Add at least one ingredient.'
	String get addIngredientRequired => 'Add at least one ingredient.';

	/// en: 'Add at least one instruction step.'
	String get instructionRequired => 'Add at least one instruction step.';

	/// en: 'Manual recipe saved.'
	String get recipeSaved => 'Manual recipe saved.';

	/// en: 'Mark as favourite'
	String get markAsFavourite => 'Mark as favourite';
}

// Path: recipeEdit
class TranslationsRecipeEditEn {
	TranslationsRecipeEditEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Edit recipe'
	String get title => 'Edit recipe';

	/// en: 'Ingredients'
	String get ingredients => 'Ingredients';

	/// en: 'Instructions'
	String get instructions => 'Instructions';

	/// en: 'Categories'
	String get categories => 'Categories';

	/// en: 'Add'
	String get add => 'Add';

	/// en: 'Add step'
	String get addStep => 'Add step';

	/// en: 'Add at least one ingredient.'
	String get addIngredientRequired => 'Add at least one ingredient.';

	/// en: 'Add at least one instruction step.'
	String get addInstructionRequired => 'Add at least one instruction step.';

	/// en: 'Recipe updated successfully.'
	String get recipeUpdated => 'Recipe updated successfully.';

	/// en: 'Failed to update recipe: {error}'
	String get updateFailed => 'Failed to update recipe: {error}';
}

// Path: errors
class TranslationsErrorsEn {
	TranslationsErrorsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Initialization Error'
	String get initializationError => 'Initialization Error';

	/// en: 'Failed to Initialize App'
	String get initializationFailed => 'Failed to Initialize App';

	/// en: 'The app encountered an error while loading your data. This can happen if data was corrupted during an update.'
	String get initializationDescription => 'The app encountered an error while loading your data. This can happen if data was corrupted during an update.';

	/// en: 'Error Details:'
	String get errorDetails => 'Error Details:';

	/// en: 'Try Again'
	String get tryAgain => 'Try Again';

	/// en: 'The app's data appears to be corrupted and cannot be loaded.'
	String get dataCorrupted => 'The app\'s data appears to be corrupted and cannot be loaded.';

	/// en: 'Retry'
	String get retry => 'Retry';

	/// en: 'Clear All Data'
	String get clearData => 'Clear All Data';

	/// en: 'This will permanently delete all your recipes, meal plans, shopping list, and inventory. This action cannot be undone.'
	String get clearDataConfirm => 'This will permanently delete all your recipes, meal plans, shopping list, and inventory. This action cannot be undone.';

	/// en: 'All data has been cleared. The app will restart.'
	String get clearDataSuccess => 'All data has been cleared. The app will restart.';

	/// en: 'Clear All Data & Restart'
	String get clearDataAndRestart => 'Clear All Data & Restart';

	/// en: 'Error loading recipes'
	String get errorLoadingRecipes => 'Error loading recipes';

	/// en: 'Error loading favorites'
	String get errorLoadingFavorites => 'Error loading favorites';
}

// Path: settings.measurements
class TranslationsSettingsMeasurementsEn {
	TranslationsSettingsMeasurementsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Measurements'
	String get title => 'Measurements';

	/// en: 'Choose how ingredient units are displayed. Recipes using a different system will be automatically converted to your preference.'
	String get description => 'Choose how ingredient units are displayed. Recipes using a different system will be automatically converted to your preference.';

	late final TranslationsSettingsMeasurementsMetricEn metric = TranslationsSettingsMeasurementsMetricEn.internal(_root);
	late final TranslationsSettingsMeasurementsImperialEn imperial = TranslationsSettingsMeasurementsImperialEn.internal(_root);
}

// Path: settings.dataManagement
class TranslationsSettingsDataManagementEn {
	TranslationsSettingsDataManagementEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Data Management'
	String get title => 'Data Management';

	/// en: 'Export your recipes, meal plans, shopping list, and inventory to a JSON file. You can import this file later to restore your data.'
	String get description => 'Export your recipes, meal plans, shopping list, and inventory to a JSON file. You can import this file later to restore your data.';

	/// en: 'Export Data'
	String get exportData => 'Export Data';

	/// en: 'Save all your data to a JSON file'
	String get exportDataDescription => 'Save all your data to a JSON file';

	/// en: 'Import Data'
	String get importData => 'Import Data';

	/// en: 'Restore data from a JSON backup file'
	String get importDataDescription => 'Restore data from a JSON backup file';

	/// en: 'Data exported successfully to: {path}'
	String get exportSuccess => 'Data exported successfully to:\n{path}';

	/// en: 'Failed to export data: {error}'
	String get exportError => 'Failed to export data: {error}';

	/// en: 'Data imported successfully!'
	String get importSuccess => 'Data imported successfully!';

	/// en: 'Failed to import data: {error}'
	String get importError => 'Failed to import data: {error}';
}

// Path: settings.version
class TranslationsSettingsVersionEn {
	TranslationsSettingsVersionEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Loading version info...'
	String get loading => 'Loading version info...';

	/// en: 'Version {version} (Build {buildNumber})'
	String get format => 'Version {version} (Build {buildNumber})';

	/// en: 'Package: {packageName}'
	String get package => 'Package: {packageName}';
}

// Path: recipeDetail.nutrition
class TranslationsRecipeDetailNutritionEn {
	TranslationsRecipeDetailNutritionEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Nutrition'
	String get title => 'Nutrition';

	/// en: 'Calories'
	String get calories => 'Calories';

	/// en: '{calories} kcal/serving'
	String get caloriesPerServing => '{calories} kcal/serving';

	/// en: 'Protein'
	String get protein => 'Protein';

	/// en: 'Carbs'
	String get carbs => 'Carbs';

	/// en: 'Fat'
	String get fat => 'Fat';

	/// en: 'Fiber'
	String get fiber => 'Fiber';

	/// en: 'Sugar'
	String get sugar => 'Sugar';

	/// en: 'Sodium'
	String get sodium => 'Sodium';

	/// en: 'Estimated nutrition values'
	String get estimated => 'Estimated nutrition values';
}

// Path: recipeDetail.prepAhead
class TranslationsRecipeDetailPrepAheadEn {
	TranslationsRecipeDetailPrepAheadEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Prep Ahead'
	String get title => 'Prep Ahead';

	/// en: 'These steps can be done ahead of time to save you time on cooking day:'
	String get description => 'These steps can be done ahead of time to save you time on cooking day:';
}

// Path: settings.measurements.metric
class TranslationsSettingsMeasurementsMetricEn {
	TranslationsSettingsMeasurementsMetricEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Metric (grams & milliliters)'
	String get name => 'Metric (grams & milliliters)';

	/// en: 'Ingredients show grams, kilograms, milliliters and liters.'
	String get description => 'Ingredients show grams, kilograms, milliliters and liters.';
}

// Path: settings.measurements.imperial
class TranslationsSettingsMeasurementsImperialEn {
	TranslationsSettingsMeasurementsImperialEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'US Customary (cups & ounces)'
	String get name => 'US Customary (cups & ounces)';

	/// en: 'Ingredients show cups, tablespoons, teaspoons, ounces and pounds.'
	String get description => 'Ingredients show cups, tablespoons, teaspoons, ounces and pounds.';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
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
