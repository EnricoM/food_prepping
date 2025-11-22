import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionService extends ChangeNotifier {
  SubscriptionService._();
  static final SubscriptionService instance = SubscriptionService._();

  static const _kIsPremium = 'subs_is_premium';
  static const _kScanMonth = 'subs_scan_month';
  static const _kScanCount = 'subs_scan_count';

  SharedPreferences? _prefs;
  bool _isPremium = false;
  int _scanMonth = 0; // yyyymm
  int _scanCount = 0;

  bool get isPremium => _isPremium;
  int get scansThisMonth => _scanCount;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    _isPremium = _prefs!.getBool(_kIsPremium) ?? false;
    _scanMonth = _prefs!.getInt(_kScanMonth) ?? _currentMonthKey();
    _scanCount = _prefs!.getInt(_kScanCount) ?? 0;
    _rolloverIfNeeded();
  }

  void setPremium(bool value) {
    if (_isPremium == value) return;
    _isPremium = value;
    _prefs?.setBool(_kIsPremium, value);
    notifyListeners();
  }

  bool canScan({int freeCap = 30}) {
    _rolloverIfNeeded();
    if (_isPremium) return true;
    return _scanCount < freeCap;
  }

  void recordScan() {
    _rolloverIfNeeded();
    _scanCount += 1;
    _prefs?.setInt(_kScanCount, _scanCount);
    notifyListeners();
  }

  int _currentMonthKey() {
    final now = DateTime.now();
    return now.year * 100 + now.month;
  }

  void _rolloverIfNeeded() {
    final key = _currentMonthKey();
    if (_scanMonth != key) {
      _scanMonth = key;
      _scanCount = 0;
      _prefs?.setInt(_kScanMonth, _scanMonth);
      _prefs?.setInt(_kScanCount, _scanCount);
    }
  }
}

