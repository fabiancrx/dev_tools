import 'package:dash_tools/common/app_logger.dart';
import 'package:dash_tools/common/app_settings.dart';
import 'package:flutter/foundation.dart';

import 'xml_formatter.dart';

class XmlFormatterController extends ChangeNotifier {
  XmlMode _mode = XmlMode.twoSpaces;
  String _input = '';
  String _output = '';
  XmlFormatError? _parseError;
  String _query = '';
  bool _queryError = false;
  String? _baseOutput; // formatted XML before XPath filter

  XmlMode get mode => _mode;
  String get input => _input;
  String get output => _output;
  XmlFormatError? get parseError => _parseError;
  bool get queryError => _queryError;
  bool get hasActiveQuery => _query.isNotEmpty;

  void setMode(XmlMode mode) {
    _mode = mode;
    _update();
  }

  void setInput(String value) {
    _input = value;
    if (AppSettings.instance.autoRun) _update();
  }

  void setQuery(String expr) {
    _query = expr.trim();
    if (_query.isEmpty) {
      _queryError = false;
      if (_baseOutput != null) {
        _output = _baseOutput!;
        _baseOutput = null;
      }
      notifyListeners();
      return;
    }
    final source = _baseOutput ?? _output;
    if (source.isEmpty) return;
    _baseOutput ??= source;
    try {
      _output = queryXpath(source, _query);
      _queryError = false;
    } catch (_) {
      _queryError = true;
    }
    notifyListeners();
  }

  void run() => _update();

  void _update() {
    if (_input.trim().isEmpty) {
      _output = '';
      _baseOutput = null;
      _parseError = null;
      _queryError = false;
      notifyListeners();
      return;
    }
    final result = processXml(_input, _mode);
    switch (result) {
      case XmlFormatSuccess(:final output):
        _parseError = null;
        if (_query.isNotEmpty) {
          _baseOutput = output;
          try {
            _output = queryXpath(output, _query);
            _queryError = false;
          } catch (_) {
            _queryError = true;
            _output = output;
            _baseOutput = null;
          }
        } else {
          _output = output;
          _baseOutput = null;
        }
      case XmlFormatError(:final message, :final line, :final col):
        _parseError = XmlFormatError(message: message, line: line, col: col);
        _output = '';
        _baseOutput = null;
        log.w('XML formatting failed: $message at $line:$col');
    }
    notifyListeners();
  }
}
