import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/inventory_item_model.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../../domain/usecases/inventory_usecases.dart';

/// State for inventory
class InventoryState {
  const InventoryState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.sortBy = InventorySortBy.name,
    this.categoryFilter,
  });

  final List<InventoryItemModel> items;
  final bool isLoading;
  final String? error;
  final InventorySortBy sortBy;
  final String? categoryFilter;

  InventoryState copyWith({
    List<InventoryItemModel>? items,
    bool? isLoading,
    String? error,
    InventorySortBy? sortBy,
    String? categoryFilter,
  }) {
    return InventoryState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      sortBy: sortBy ?? this.sortBy,
      categoryFilter: categoryFilter,
    );
  }
}

/// Controller for inventory operations
class InventoryController extends StateNotifier<InventoryState> {
  InventoryController(
    this._repository, {
    SortInventoryItemsUseCase? sortItemsUseCase,
    FilterInventoryByCategoryUseCase? filterByCategoryUseCase,
    FilterLowStockItemsUseCase? filterLowStockUseCase,
  })  : _sortItemsUseCase = sortItemsUseCase ?? const SortInventoryItemsUseCase(),
        _filterByCategoryUseCase =
            filterByCategoryUseCase ?? const FilterInventoryByCategoryUseCase(),
        _filterLowStockUseCase =
            filterLowStockUseCase ?? const FilterLowStockItemsUseCase(),
        super(const InventoryState()) {
    _inventorySubscription = _repository.watchAll().listen((items) {
      state = state.copyWith(items: items, isLoading: false);
    }, onError: (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    });
    state = state.copyWith(isLoading: true);
  }

  final InventoryRepository _repository;
  final SortInventoryItemsUseCase _sortItemsUseCase;
  final FilterInventoryByCategoryUseCase _filterByCategoryUseCase;
  final FilterLowStockItemsUseCase _filterLowStockUseCase;
  late final StreamSubscription<List<InventoryItemModel>> _inventorySubscription;

  @override
  void dispose() {
    _inventorySubscription.cancel();
    super.dispose();
  }

  void setSortBy(InventorySortBy sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }

  void setCategoryFilter(String? category) {
    state = state.copyWith(categoryFilter: category);
  }

  Future<void> addItem(InventoryItemModel item) async {
    try {
      await _repository.addItem(item);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateItem({
    required InventoryItemModel item,
    String? name,
    double? quantity,
    String? unit,
    String? category,
    String? location,
    String? note,
    DateTime? expiry,
    double? costPerUnit,
    bool? isLowStock,
  }) async {
    try {
      await _repository.updateItem(
        item: item,
        name: name,
        quantity: quantity,
        unit: unit,
        category: category,
        location: location,
        note: note,
        expiry: expiry,
        costPerUnit: costPerUnit,
        isLowStock: isLowStock,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> adjustQuantity(InventoryItemModel item, double delta) async {
    try {
      await _repository.adjustQuantity(item, delta);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> toggleLowStock(InventoryItemModel item) async {
    try {
      await _repository.toggleLowStock(item);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> remove(InventoryItemModel item) async {
    try {
      await _repository.remove(item);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> clear() async {
    try {
      await _repository.clear();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  List<InventoryItemModel> get organizedItems {
    var items = List<InventoryItemModel>.from(state.items);

    // Apply category filter
    if (state.categoryFilter != null) {
      items = _filterByCategoryUseCase(
        items: items,
        category: state.categoryFilter,
      );
    }

    // Sort items
    items = _sortItemsUseCase(items, state.sortBy);

    return items;
  }

  List<InventoryItemModel> get lowStockItems {
    return _filterLowStockUseCase(state.items);
  }

  List<String> get allCategories {
    return state.items
        .where((item) => item.category != null && item.category!.isNotEmpty)
        .map((item) => item.category!)
        .toSet()
        .toList()
      ..sort();
  }
}

