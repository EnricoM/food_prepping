import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/shopping_list_item_model.dart';
import '../../domain/repositories/shopping_list_repository.dart';
import '../../domain/usecases/shopping_list_usecases.dart';

/// State for shopping list
class ShoppingListState {
  const ShoppingListState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  final List<ShoppingListItemModel> items;
  final bool isLoading;
  final String? error;

  ShoppingListState copyWith({
    List<ShoppingListItemModel>? items,
    bool? isLoading,
    String? error,
  }) {
    return ShoppingListState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Controller for shopping list operations
class ShoppingListController extends StateNotifier<ShoppingListState> {
  ShoppingListController(
    this._repository, {
    MergeDuplicatesUseCase? mergeDuplicatesUseCase,
    SortAlphabeticallyUseCase? sortAlphabeticallyUseCase,
    SortByStoreLayoutUseCase? sortByStoreLayoutUseCase,
  })  : _mergeDuplicatesUseCase = mergeDuplicatesUseCase ?? const MergeDuplicatesUseCase(),
        _sortAlphabeticallyUseCase = sortAlphabeticallyUseCase ?? const SortAlphabeticallyUseCase(),
        _sortByStoreLayoutUseCase = sortByStoreLayoutUseCase ?? const SortByStoreLayoutUseCase(),
        super(const ShoppingListState()) {
    _itemSubscription = _repository.watchAll().listen((items) {
      state = state.copyWith(items: items, isLoading: false);
    }, onError: (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    });
    state = state.copyWith(isLoading: true);
  }

  final ShoppingListRepository _repository;
  final MergeDuplicatesUseCase _mergeDuplicatesUseCase;
  final SortAlphabeticallyUseCase _sortAlphabeticallyUseCase;
  final SortByStoreLayoutUseCase _sortByStoreLayoutUseCase;
  late final StreamSubscription<List<ShoppingListItemModel>> _itemSubscription;

  @override
  void dispose() {
    _itemSubscription.cancel();
    super.dispose();
  }

  Future<void> addItems(List<ShoppingListItemModel> items) async {
    try {
      await _repository.addItems(items);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateChecked(ShoppingListItemModel item, bool checked) async {
    try {
      await _repository.updateChecked(item, checked);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> remove(ShoppingListItemModel item) async {
    try {
      await _repository.remove(item);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> clearCompleted() async {
    try {
      await _repository.clearCompleted();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> clearAll() async {
    try {
      await _repository.clearAll();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  List<ShoppingListItemModel> mergeDuplicates(List<ShoppingListItemModel> items) {
    return _mergeDuplicatesUseCase(items);
  }

  List<ShoppingListItemModel> sortAlphabetically(List<ShoppingListItemModel> items) {
    return _sortAlphabeticallyUseCase(items);
  }

  List<ShoppingListItemModel> sortByStoreLayout(List<ShoppingListItemModel> items) {
    return _sortByStoreLayoutUseCase(items);
  }

  Future<void> refresh() async {
    // Trigger a refresh by reading the repository
    final items = _repository.getAll();
    state = state.copyWith(items: items);
  }
}

