import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'tour_progress.dart';

class TourService extends ChangeNotifier {
  TourService._();
  static final TourService instance = TourService._();

  static const String _keyTourCompleted = 'tour_completed';
  static const String _keyFirstLaunch = 'first_launch';

  bool _tourCompleted = false;
  bool _isFirstLaunch = true;

  bool get tourCompleted => _tourCompleted;
  bool get isFirstLaunch => _isFirstLaunch;
  bool get shouldShowTour => _isFirstLaunch && !_tourCompleted;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _tourCompleted = prefs.getBool(_keyTourCompleted) ?? false;
      _isFirstLaunch = prefs.getBool(_keyFirstLaunch) ?? true;
      await TourProgress.instance.init();
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing TourService: $e');
      // Use defaults if initialization fails
      _tourCompleted = false;
      _isFirstLaunch = true;
    }
  }

  Future<void> markTourCompleted() async {
    _tourCompleted = true;
    _isFirstLaunch = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTourCompleted, true);
    await prefs.setBool(_keyFirstLaunch, false);
    notifyListeners();
  }

  Future<void> resetTour() async {
    _tourCompleted = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTourCompleted, false);
    await TourProgress.instance.reset();
    notifyListeners();
  }

  bool canResume() {
    return TourProgress.instance.lastScenario != null;
  }

  int? getResumeScenario() => TourProgress.instance.lastScenario;
  int? getResumeStep() => TourProgress.instance.lastStep;
}

