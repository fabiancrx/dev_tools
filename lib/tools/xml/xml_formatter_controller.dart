import 'package:dash_tools/common/app_logger.dart';
import 'package:dash_tools/common/app_settings.dart';
import 'package:flutter/foundation.dart';

import 'xml_formatter.dart';

class XmlFormatterController extends ChangeNotifier {
  XmlMode _mode = XmlMode.twoSpaces;
  String _input = '';
  String _output = '';
  String _error = '';

  XmlMode get mode => _mode;
  String get input => _input;
  String get output => _output;
  String get error => _error;

  void setMode(XmlMode mode) {
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
      _output = formatXml(_input, _mode);
      _error = '';
    } catch (e) {
      log.w('XML formatting failed', error: e);
      _output = '';
      _error = e.toString();
    }
    notifyListeners();
  }
}
