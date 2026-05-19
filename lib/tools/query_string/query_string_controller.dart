import 'package:flutter/foundation.dart';

import 'query_string.dart';

class QueryStringController extends ChangeNotifier {
  String _input = '';
  String _output = '';

  String get input => _input;
  String get output => _output;

  void setInput(String value) {
    _input = value;
    _output = queryStringToJson(value);
    notifyListeners();
  }
}
