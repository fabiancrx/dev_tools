import 'package:flutter/foundation.dart';

import 'url_encoder.dart';

class UrlEncoderController extends ChangeNotifier {
  String _input = '';
  String _output = '';
  UrlEncodeMode _mode = UrlEncodeMode.encode;
  UrlEncodeType _type = UrlEncodeType.component;

  String get input => _input;
  String get output => _output;
  UrlEncodeMode get mode => _mode;
  UrlEncodeType get type => _type;

  void setInput(String value) {
    _input = value;
    _update();
  }

  void setMode(UrlEncodeMode value) {
    _mode = value;
    _update();
  }

  void setType(UrlEncodeType value) {
    _type = value;
    _update();
  }

  void _update() {
    _output = switch (_mode) {
      UrlEncodeMode.encode => encodeUrl(_input, _type),
      UrlEncodeMode.decode => decodeUrl(_input, _type),
    };
    notifyListeners();
  }
}
