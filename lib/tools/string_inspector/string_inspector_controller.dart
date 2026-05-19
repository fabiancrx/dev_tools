import 'package:flutter/foundation.dart';

import 'string_inspector.dart';

class StringInspectorController extends ChangeNotifier {
  String _input = '';
  StringStats _stats = StringStats.empty;

  String get input => _input;
  StringStats get stats => _stats;

  void setInput(String value) {
    _input = value;
    _stats = inspectString(value);
    notifyListeners();
  }
}
