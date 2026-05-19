import 'package:flutter/foundation.dart';

class QrCodeController extends ChangeNotifier {
  String _input = 'https://flutter.dev';

  String get input => _input;

  void setInput(String value) {
    _input = value;
    notifyListeners();
  }
}
