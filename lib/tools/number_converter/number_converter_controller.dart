import 'package:flutter/foundation.dart';

class NumberConverterController extends ChangeNotifier {
  String _hex = '';
  String _decimal = '';
  String _octal = '';
  String _binary = '';

  String get hex => _hex;
  String get decimal => _decimal;
  String get octal => _octal;
  String get binary => _binary;

  NumberConverterController() {
    _setFromDecimal(95);
  }

  void convertFromHex(String value) {
    if (int.tryParse(value, radix: 16) case final d?) {
      _hex = value;
      _decimal = d.toString();
      _octal = d.toRadixString(8);
      _binary = d.toRadixString(2);
    } else {
      _clearAll();
    }
    notifyListeners();
  }

  void convertFromDecimal(String value) {
    if (int.tryParse(value) case final d?) {
      _hex = d.toRadixString(16);
      _decimal = value;
      _octal = d.toRadixString(8);
      _binary = d.toRadixString(2);
    } else {
      _clearAll();
    }
    notifyListeners();
  }

  void convertFromOctal(String value) {
    if (int.tryParse(value, radix: 8) case final d?) {
      _hex = d.toRadixString(16);
      _decimal = d.toString();
      _octal = value;
      _binary = d.toRadixString(2);
    } else {
      _clearAll();
    }
    notifyListeners();
  }

  void convertFromBinary(String value) {
    if (int.tryParse(value, radix: 2) case final d?) {
      _hex = d.toRadixString(16);
      _decimal = d.toString();
      _octal = d.toRadixString(8);
      _binary = value;
    } else {
      _clearAll();
    }
    notifyListeners();
  }

  void _setFromDecimal(int value) {
    _hex = value.toRadixString(16);
    _decimal = value.toString();
    _octal = value.toRadixString(8);
    _binary = value.toRadixString(2);
  }

  void _clearAll() {
    _hex = '';
    _decimal = '';
    _octal = '';
    _binary = '';
  }
}
