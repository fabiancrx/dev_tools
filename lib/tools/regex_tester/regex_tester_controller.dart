import 'package:dash_tools/tools/regex_tester/regex_tester.dart';
import 'package:flutter/foundation.dart';

class RegexTesterController extends ChangeNotifier {
  String _pattern = '';
  String _input = '';
  RegexResult _result = RegexResult.empty;
  bool _caseSensitive = true;
  bool _multiLine = false;
  bool _dotAll = false;
  bool _unicode = false;

  String get pattern => _pattern;
  String get input => _input;
  RegexResult get result => _result;
  bool get caseSensitive => _caseSensitive;
  bool get multiLine => _multiLine;
  bool get dotAll => _dotAll;
  bool get unicode => _unicode;

  void setPattern(String v) {
    _pattern = v;
    _update();
  }

  void setInput(String v) {
    _input = v;
    _update();
  }

  void setCaseSensitive(bool v) {
    _caseSensitive = v;
    _update();
  }

  void setMultiLine(bool v) {
    _multiLine = v;
    _update();
  }

  void setDotAll(bool v) {
    _dotAll = v;
    _update();
  }

  void setUnicode(bool v) {
    _unicode = v;
    _update();
  }

  void _update() {
    _result = runRegex(
      _pattern,
      _input,
      caseSensitive: _caseSensitive,
      multiLine: _multiLine,
      dotAll: _dotAll,
      unicode: _unicode,
    );
    notifyListeners();
  }
}
