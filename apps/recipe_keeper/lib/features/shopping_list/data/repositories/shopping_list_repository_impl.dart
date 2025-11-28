import 'dart:async';

import '../../domain/models/shopping_list_item_model.dart';
import '../../domain/repositories/shopping_list_repository.dart' as domain;
import '../datasources/shopping_list_datasource.dart';

/// Implementation of [domain.ShoppingListRepository] using [ShoppingListDataSource]
class ShoppingListRepositoryImpl implements domain.ShoppingListRepository {
  ShoppingListRepositoryImpl(this._dataSource);

  final ShoppingListDataSource _dataSource;

  @override
  Stream<List<ShoppingListItemModel>> watchAll() {
    final listenable = _dataSource.listenable;
    return Stream<List<ShoppingListItemModel>>.multi((controller) {
      void emit() {
        final box = listenable.value;
        controller.add(box.values.map(_dataSource.toModel).toList());
      }
      emit();
      void listener() => emit();
      listenable.addListener(listener);
      controller.onCancel = () {
        listenable.removeListener(listener);
      };
    });
  }

  @override
  List<ShoppingListItemModel> getAll() {
    return _dataSource.getAll();
  }

  @override
  Future<void> addItems(List<ShoppingListItemModel> items) async {
    await _dataSource.addItems(items);
  }

  @override
  Future<void> updateChecked(ShoppingListItemModel item, bool checked) async {
    await _dataSource.updateChecked(item, checked);
  }

  @override
  Future<void> remove(ShoppingListItemModel item) async {
    await _dataSource.remove(item);
  }

  @override
  Future<void> clearCompleted() async {
    await _dataSource.clearCompleted();
  }

  @override
  Future<void> clearAll() async {
    await _dataSource.clearAll();
  }
}

