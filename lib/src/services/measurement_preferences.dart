import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum MeasurementSystem { metric, imperial }

extension MeasurementSystemLabels on MeasurementSystem {
  String get displayName {
    switch (this) {
      case MeasurementSystem.metric:
        return 'Metric (grams & milliliters)';
      case MeasurementSystem.imperial:
        return 'US Customary (cups & ounces)';
    }
  }
}

class MeasurementPreferences extends ChangeNotifier {
  MeasurementPreferences._();

  static final MeasurementPreferences instance = MeasurementPreferences._();
  static const _storageKey = 'measurement_system';

  SharedPreferences? _prefs;
  MeasurementSystem _system = MeasurementSystem.metric;

  MeasurementSystem get system => _system;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    final stored = _prefs!.getString(_storageKey);
    if (stored != null) {
      final resolved = MeasurementSystem.values.firstWhere(
        (value) => value.name == stored,
        orElse: () => _system,
      );
      _system = resolved;
    }
  }

  void setSystem(MeasurementSystem system) {
    if (_system == system) {
      return;
    }
    _system = system;
    notifyListeners();
    _prefs?.setString(_storageKey, system.name);
  }
}

