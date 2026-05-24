import 'dart:convert';

import 'package:dash_tools/common/app_logger.dart';
import 'package:flutter/foundation.dart';

enum Base64ConverterMode { encode, decode }

enum Codec {
  utf8(Utf8Codec()),
  latin1(Latin1Codec()),
  ascii(AsciiCodec());

  final Encoding _encoding;

  const Codec(this._encoding);

  String decode(List<int> bytes) => _encoding.decode(bytes);
  List<int> encode(String s) => _encoding.encode(s);

  String get displayName => switch (this) {
        Codec.utf8 => 'UTF-8',
        Codec.latin1 => 'Latin-1',
        Codec.ascii => 'ASCII',
      };
}

class Base64Controller extends ChangeNotifier {
  static const _initialInput = 'aguacate';

  Base64Controller() {
    _output = _computeOutput(_input);
  }

  String _input = _initialInput;
  String _output = '';

  Base64ConverterMode _mode = Base64ConverterMode.encode;
  Codec _codec = Codec.utf8;

  String get input => _input;
  String get output => _output;
  Base64ConverterMode get mode => _mode;
  Codec get codec => _codec;

  void setInput(String value) {
    _input = value;
    _output = _computeOutput(value);
    notifyListeners();
  }

  void setMode(Base64ConverterMode mode) {
    _mode = mode;
    _output = _computeOutput(_input);
    notifyListeners();
  }

  void setCodec(Codec codec) {
    _codec = codec;
    _output = _computeOutput(_input);
    notifyListeners();
  }

  String _computeOutput(String input) {
    try {
      return switch (_mode) {
        Base64ConverterMode.encode => base64.encode(_codec.encode(input)),
        Base64ConverterMode.decode => _codec.decode(base64.decode(input)),
      };
    } catch (e, st) {
      log.w('Base64 conversion failed', error: e, stackTrace: st);
      return '';
    }
  }
}
