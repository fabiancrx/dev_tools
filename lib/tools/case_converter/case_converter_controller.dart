import 'package:dash_tools/common/app_settings.dart';
import 'package:flutter/foundation.dart';

import 'case_converter.dart';

class CaseConverterController extends ChangeNotifier {
  String _input = '';
  Map<CaseStyle, String> _results = {for (final s in CaseStyle.values) s: ''};

  String get input => _input;
  Map<CaseStyle, String> get results => _results;

  void setInput(String value) {
    _input = value;
    if (AppSettings.instance.autoRun) _update();
  }

  void run() => _update();

  void _update() {
    _results = convertAllCases(_input);
    notifyListeners();
  }
}
