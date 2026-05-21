import 'package:dash_tools/common/app_settings.dart';
import 'package:flutter/foundation.dart';

import 'yaml_formatter.dart';

class YamlFormatterController extends ChangeNotifier {
  String _input = '';
  String _output = '';
  String _error = '';

  String get input => _input;
  String get output => _output;
  String get error => _error;

  void setInput(String value) {
    _input = value;
    if (AppSettings.instance.autoRun) _update();
  }

  void run() => _update();

  void _update() {
    if (_input.trim().isEmpty) {
      _output = '';
      _error = '';
      notifyListeners();
      return;
    }
    try {
      _output = formatYaml(_input);
      _error = '';
    } catch (e) {
      _output = '';
      _error = e.toString();
    }
    notifyListeners();
  }
}
