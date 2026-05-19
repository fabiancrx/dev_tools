import 'package:flutter/foundation.dart';

import 'uuid_generator.dart';

class UuidGeneratorController extends ChangeNotifier {
  UuidVersion _version = UuidVersion.v4;
  int _count = 5;
  List<String> _uuids = [];

  UuidVersion get version => _version;
  int get count => _count;
  List<String> get uuids => _uuids;

  UuidGeneratorController() {
    generate();
  }

  void setVersion(UuidVersion value) {
    _version = value;
    generate();
  }

  void setCount(int value) {
    _count = value.clamp(1, 20);
    generate();
  }

  void generate() {
    _uuids = generateUuids(_version, _count);
    notifyListeners();
  }
}
