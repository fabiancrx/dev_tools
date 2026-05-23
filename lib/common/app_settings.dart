import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kAutoRun = 'auto_run';
const _kCompactMode = 'compact_mode';
const _kAccentVariant = 'accent_variant';

class AppSettings extends ChangeNotifier {
  AppSettings._();
  static final instance = AppSettings._();

  bool _autoRun = true;
  bool get autoRun => _autoRun;

  bool _compactMode = false;
  bool get compactMode => _compactMode;

  /// The name of the selected [YaruVariant], or null to follow the OS accent.
  String? _accentVariant;
  String? get accentVariant => _accentVariant;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    instance._autoRun = prefs.getBool(_kAutoRun) ?? true;
    instance._compactMode = prefs.getBool(_kCompactMode) ?? false;
    instance._accentVariant = prefs.getString(_kAccentVariant);
  }

  Future<void> setAutoRun(bool value) async {
    if (_autoRun == value) return;
    _autoRun = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAutoRun, value);
  }

  Future<void> setCompactMode(bool value) async {
    if (_compactMode == value) return;
    _compactMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kCompactMode, value);
  }

  Future<void> setAccentVariant(String? value) async {
    if (_accentVariant == value) return;
    _accentVariant = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove(_kAccentVariant);
    } else {
      await prefs.setString(_kAccentVariant, value);
    }
  }
}
