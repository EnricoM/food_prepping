import 'package:shared_preferences/shared_preferences.dart';

class TourProgress {
  TourProgress._();
  static final TourProgress instance = TourProgress._();

  static const String _keyScenario1Progress = 'tour_scenario1_progress';
  static const String _keyScenario2Progress = 'tour_scenario2_progress';
  static const String _keyScenario3Progress = 'tour_scenario3_progress';
  static const String _keyLastScenario = 'tour_last_scenario';
  static const String _keyLastStep = 'tour_last_step';
  static const String _keyAutoAdvance = 'tour_auto_advance';
  static const String _keyQuickTipsMode = 'tour_quick_tips';

  int _scenario1Progress = 0;
  int _scenario2Progress = 0;
  int _scenario3Progress = 0;
  int? _lastScenario;
  int? _lastStep;
  bool _autoAdvance = false;
  bool _quickTipsMode = false;

  int get scenario1Progress => _scenario1Progress;
  int get scenario2Progress => _scenario2Progress;
  int get scenario3Progress => _scenario3Progress;
  int? get lastScenario => _lastScenario;
  int? get lastStep => _lastStep;
  bool get autoAdvance => _autoAdvance;
  bool get quickTipsMode => _quickTipsMode;

  bool isScenarioComplete(int scenario) {
    switch (scenario) {
      case 1:
        return _scenario1Progress >= 4;
      case 2:
        return _scenario2Progress >= 6;
      case 3:
        return _scenario3Progress >= 4;
      default:
        return false;
    }
  }

  int getScenarioTotalSteps(int scenario) {
    switch (scenario) {
      case 1:
        return 4;
      case 2:
        return 6;
      case 3:
        return 4;
      default:
        return 0;
    }
  }

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _scenario1Progress = prefs.getInt(_keyScenario1Progress) ?? 0;
      _scenario2Progress = prefs.getInt(_keyScenario2Progress) ?? 0;
      _scenario3Progress = prefs.getInt(_keyScenario3Progress) ?? 0;
      _lastScenario = prefs.getInt(_keyLastScenario);
      _lastStep = prefs.getInt(_keyLastStep);
      _autoAdvance = prefs.getBool(_keyAutoAdvance) ?? false;
      _quickTipsMode = prefs.getBool(_keyQuickTipsMode) ?? false;
    } catch (e) {
      // Use defaults if initialization fails
      _scenario1Progress = 0;
      _scenario2Progress = 0;
      _scenario3Progress = 0;
      _lastScenario = null;
      _lastStep = null;
      _autoAdvance = false;
      _quickTipsMode = false;
    }
  }

  Future<void> updateProgress(int scenario, int step) async {
    final prefs = await SharedPreferences.getInstance();
    switch (scenario) {
      case 1:
        _scenario1Progress = step;
        await prefs.setInt(_keyScenario1Progress, step);
        break;
      case 2:
        _scenario2Progress = step;
        await prefs.setInt(_keyScenario2Progress, step);
        break;
      case 3:
        _scenario3Progress = step;
        await prefs.setInt(_keyScenario3Progress, step);
        break;
    }
    await prefs.setInt(_keyLastScenario, scenario);
    await prefs.setInt(_keyLastStep, step);
  }

  Future<void> setAutoAdvance(bool value) async {
    _autoAdvance = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoAdvance, value);
  }

  Future<void> setQuickTipsMode(bool value) async {
    _quickTipsMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyQuickTipsMode, value);
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    _scenario1Progress = 0;
    _scenario2Progress = 0;
    _scenario3Progress = 0;
    _lastScenario = null;
    _lastStep = null;
    await prefs.remove(_keyScenario1Progress);
    await prefs.remove(_keyScenario2Progress);
    await prefs.remove(_keyScenario3Progress);
    await prefs.remove(_keyLastScenario);
    await prefs.remove(_keyLastStep);
  }
}



