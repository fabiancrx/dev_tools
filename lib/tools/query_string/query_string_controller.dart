import 'package:dash_tools/common/app_settings.dart';
import 'package:flutter/foundation.dart';

import 'query_string.dart';

class QueryStringController extends ChangeNotifier {
  String _input = '';
  String _output = '';

  String get input => _input;
  String get output => _output;

  void setInput(String value) {
    _input = value;
    if (AppSettings.instance.autoRun) _update();
  }

  void run() => _update();

  void _update() {
    _output = queryStringToJson(_input);
    notifyListeners();
  }
}
