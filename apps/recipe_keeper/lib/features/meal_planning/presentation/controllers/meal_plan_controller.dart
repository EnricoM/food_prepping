import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/meal_plan_day_model.dart';
import '../../domain/models/meal_slot.dart';
import '../../domain/repositories/meal_plan_repository.dart';
import '../../domain/usecases/meal_plan_usecases.dart';

/// State for meal plan
class MealPlanState {
  const MealPlanState({
    this.plansByDay = const {},
    this.isLoading = false,
    this.error,
  });

  final Map<DateTime, MealPlanDayModel> plansByDay;
  final bool isLoading;
  final String? error;

  MealPlanState copyWith({
    Map<DateTime, MealPlanDayModel>? plansByDay,
    bool? isLoading,
    String? error,
  }) {
    return MealPlanState(
      plansByDay: plansByDay ?? this.plansByDay,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Controller for meal plan operations
class MealPlanController extends StateNotifier<MealPlanState> {
  MealPlanController(
    this._repository, {
    GetMealPlansBetweenUseCase? getMealPlansBetweenUseCase,
  })  : _getMealPlansBetweenUseCase =
            getMealPlansBetweenUseCase ?? const GetMealPlansBetweenUseCase(),
        super(const MealPlanState()) {
    _planSubscription = _repository.watchAll().listen((plans) {
      state = state.copyWith(plansByDay: plans, isLoading: false);
    }, onError: (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    });
    state = state.copyWith(isLoading: true);
  }

  final MealPlanRepository _repository;
  final GetMealPlansBetweenUseCase _getMealPlansBetweenUseCase;
  late final StreamSubscription<Map<DateTime, MealPlanDayModel>> _planSubscription;

  @override
  void dispose() {
    _planSubscription.cancel();
    super.dispose();
  }

  MealPlanDayModel dayFor(DateTime date) {
    return _repository.dayFor(date);
  }

  Future<void> setMeal({
    required DateTime date,
    required MealSlot slot,
    String? recipeUrl,
  }) async {
    try {
      await _repository.setMeal(date: date, slot: slot, recipeUrl: recipeUrl);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> addMeal({
    required DateTime date,
    required MealSlot slot,
    required String recipeUrl,
  }) async {
    try {
      await _repository.addMeal(date: date, slot: slot, recipeUrl: recipeUrl);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> removeMeal({
    required DateTime date,
    required MealSlot slot,
    required String recipeUrl,
  }) async {
    try {
      await _repository.removeMeal(date: date, slot: slot, recipeUrl: recipeUrl);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> setMeals({
    required DateTime date,
    required Map<MealSlot, List<String>> meals,
  }) async {
    try {
      await _repository.setMeals(date: date, meals: meals);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> setNotes({
    required DateTime date,
    String? notes,
  }) async {
    try {
      await _repository.setNotes(date: date, notes: notes);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteDay(DateTime date) async {
    try {
      await _repository.deleteDay(date);
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

  MealPlanDayModel copyPreviousAvailable(DateTime date) {
    return _repository.copyPreviousAvailable(date);
  }

  MealPlanDayModel? dayMatchingRecipes(Set<String> recipeUrls) {
    return _repository.dayMatchingRecipes(recipeUrls);
  }

  List<MealPlanDayModel> getMealPlansBetween({
    required DateTime start,
    required DateTime end,
  }) {
    return _getMealPlansBetweenUseCase(
      allPlans: state.plansByDay,
      start: start,
      end: end,
    );
  }
}

