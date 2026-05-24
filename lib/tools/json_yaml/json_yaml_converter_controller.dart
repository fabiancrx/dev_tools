import 'package:dash_tools/common/app_logger.dart';
import 'package:dash_tools/common/app_settings.dart';
import 'package:flutter/foundation.dart';

import 'json_yaml_converter.dart';

class JsonYamlConverterController extends ChangeNotifier {
  JsonYamlMode _mode = JsonYamlMode.jsonToYaml;
  String _input = '';
  String _output = '';
  String _error = '';

  JsonYamlMode get mode => _mode;
  String get input => _input;
  String get output => _output;
  String get error => _error;

  void setMode(JsonYamlMode mode) {
    _mode = mode;
    _update();
  }

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
      _output = switch (_mode) {
        JsonYamlMode.jsonToYaml => convertJsonToYaml(_input),
        JsonYamlMode.yamlToJson => convertYamlToJson(_input),
      };
      _error = '';
    } catch (e) {
      log.w('JSON/YAML conversion failed', error: e);
      _output = '';
      _error = e.toString();
    }
    notifyListeners();
  }
}
