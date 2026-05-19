import 'package:flutter/foundation.dart';

import 'hash_generator.dart';

class HashGeneratorController extends ChangeNotifier {
  String _input = '';
  String _hmacKey = '';
  HashAlgorithm _algorithm = HashAlgorithm.sha256;
  HashResult _result = HashResult.empty;

  String get input => _input;
  String get hmacKey => _hmacKey;
  HashAlgorithm get algorithm => _algorithm;
  HashResult get result => _result;

  void setInput(String value) {
    _input = value;
    _update();
  }

  void setHmacKey(String value) {
    _hmacKey = value;
    _update();
  }

  void setAlgorithm(HashAlgorithm value) {
    _algorithm = value;
    _update();
  }

  void _update() {
    _result = computeHash(
      _input,
      _algorithm,
      hmacKey: _hmacKey.isNotEmpty ? _hmacKey : null,
    );
    notifyListeners();
  }
}
