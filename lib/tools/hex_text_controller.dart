import 'package:flutter/foundation.dart';

enum HexTextConvertMode { hexToText, textToHex }

class HexTextController extends ChangeNotifier {
  static const _initialInput = '6167756163617465';

  HexTextController() {
    _output = _computeOutput(_input);
  }

  String _input = _initialInput;
  String _output = '';

  HexTextConvertMode _mode = HexTextConvertMode.hexToText;

  String get input => _input;
  String get output => _output;
  HexTextConvertMode get mode => _mode;

  void setInput(String value) {
    _input = value;
    _output = _computeOutput(value);
    notifyListeners();
  }

  void setMode(HexTextConvertMode mode) {
    _mode = mode;
    _output = _computeOutput(_input);
    notifyListeners();
  }

  String _computeOutput(String input) {
    final clean = input.replaceAll(RegExp(r'\s+'), '');
    return switch (_mode) {
      HexTextConvertMode.hexToText => hexToAscii(clean),
      HexTextConvertMode.textToHex => asciiToHex(clean),
    };
  }
}

String asciiToHex(String asciiStr) {
  final hex = StringBuffer();
  for (final ch in asciiStr.codeUnits) {
    hex.write(ch.toRadixString(16).padLeft(2, '0'));
  }
  return hex.toString();
}

String hexToAscii(String hexString) => List.generate(
      hexString.length ~/ 2,
      (i) => String.fromCharCode(
        int.parse(hexString.substring(i * 2, (i * 2) + 2), radix: 16),
      ),
    ).join();
