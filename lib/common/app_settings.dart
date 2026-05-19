import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kAutoRun = 'auto_run';

class AppSettings extends ChangeNotifier {
  AppSettings._();
  static final instance = AppSettings._();

  bool _autoRun = true;
  bool get autoRun => _autoRun;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    instance._autoRun = prefs.getBool(_kAutoRun) ?? true;
  }

  Future<void> setAutoRun(bool value) async {
    if (_autoRun == value) return;
    _autoRun = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAutoRun, value);
  }
}
