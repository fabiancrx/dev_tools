import 'package:flutter/widgets.dart';

enum HexTextConvertMode { hexToText, textToHex }

class HexTextController extends ChangeNotifier {
  HexTextController() {
    inputController.text = '6167756163617465';
    outputController.text = hexToAscii(inputController.text);
    inputController.addListener(_convert);
  }

  final inputController = TextEditingController();
  final outputController = TextEditingController();

  HexTextConvertMode _mode = HexTextConvertMode.hexToText;
  HexTextConvertMode get mode => _mode;

  void setMode(HexTextConvertMode mode) {
    _mode = mode;
    _convert();
    notifyListeners();
  }

  void _convert() {
    final cleanInput = inputController.text.replaceAll(RegExp(r'\s+'), '');
    outputController.text = switch (_mode) {
      HexTextConvertMode.hexToText => hexToAscii(cleanInput),
      HexTextConvertMode.textToHex => asciiToHex(cleanInput),
    };
  }

  @override
  void dispose() {
    inputController.dispose();
    outputController.dispose();
    super.dispose();
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
