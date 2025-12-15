import 'package:flutter/material.dart';

class TourManager {
  TourManager._();
  static final TourManager instance = TourManager._();

  // Scenario 1: Adding recipes
  static const String scenario1Step1 = 'scenario1_step1'; // URL field
  static const String scenario1Step2 = 'scenario1_step2'; // Paste button
  static const String scenario1Step3 = 'scenario1_step3'; // Parse button
  static const String scenario1Step4 = 'scenario1_step4'; // Save button

  // Scenario 2: Meal planning
  static const String scenario2Step1 = 'scenario2_step1'; // Calendar/date selection
  static const String scenario2Step2 = 'scenario2_step2'; // Add recipe to meal
  static const String scenario2Step3 = 'scenario2_step3'; // Add to shopping list button
  static const String scenario2Step4 = 'scenario2_step4'; // Shopping list screen
  static const String scenario2Step5 = 'scenario2_step5'; // Check item
  static const String scenario2Step6 = 'scenario2_step6'; // Add to inventory button

  // Scenario 3: Preparing recipe
  static const String scenario3Step1 = 'scenario3_step1'; // Recipe card
  static const String scenario3Step2 = 'scenario3_step2'; // Ingredients tab
  static const String scenario3Step3 = 'scenario3_step3'; // Preparation tab
  static const String scenario3Step4 = 'scenario3_step4'; // Favorite button

  int? _currentScenario;
  int? _currentStep;
  final Map<String, GlobalKey> _keys = {};

  void registerKey(String stepId, GlobalKey key) {
    _keys[stepId] = key;
  }

  GlobalKey? getKey(String stepId) {
    return _keys[stepId];
  }

  void startScenario(int scenario) {
    _currentScenario = scenario;
    _currentStep = 0;
  }

  void nextStep() {
    if (_currentStep != null) {
      _currentStep = _currentStep! + 1;
    }
  }

  void reset() {
    _currentScenario = null;
    _currentStep = null;
  }

  bool isActive(int? scenario) {
    return _currentScenario == scenario;
  }

  int? get currentStep => _currentStep;
  int? get currentScenario => _currentScenario;
}



