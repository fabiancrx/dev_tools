import 'dart:convert';

import 'package:flutter/widgets.dart';

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
  Base64Controller() {
    inputController.text = 'aguacate';
    _convert();
    inputController.addListener(_convert);
  }

  final inputController = TextEditingController();
  final outputController = TextEditingController();

  Base64ConverterMode _mode = Base64ConverterMode.encode;
  Codec _codec = Codec.utf8;

  Base64ConverterMode get mode => _mode;
  Codec get codec => _codec;

  void setMode(Base64ConverterMode mode) {
    _mode = mode;
    _convert();
    notifyListeners();
  }

  void setCodec(Codec codec) {
    _codec = codec;
    _convert();
    notifyListeners();
  }

  void _convert() {
    try {
      outputController.text = switch (_mode) {
        Base64ConverterMode.encode => base64.encode(_codec.encode(inputController.text)),
        Base64ConverterMode.decode => _codec.decode(base64.decode(inputController.text)),
      };
    } catch (_) {
      outputController.text = '';
    }
  }

  @override
  void dispose() {
    inputController.dispose();
    outputController.dispose();
    super.dispose();
  }
}
