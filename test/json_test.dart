import 'dart:convert';

import 'package:dash_tools/tools/json/json_screen_controller.dart';
import 'package:flutter_test/flutter_test.dart';

// https://github.com/nst/JSONTestSuite
void main() {
  setUp(() {});
  group('Check Json Parsing', () {
    test('Json Parsing', () {

      const encoder = JsonEncoder();
      final result = encoder.convert(jsonDecode(_kSampleJson));

      final ja = unEscapeJson('$result"');

      final jo =jsonDecode(ja);
    });
  });
}
const _kSampleJson = r'''{
    "widget": {
    "debug": "on",
    "window": {
        "title": "Sample Konfabulator Widget",
        "name": "main_window",
        "width": 500,
        "height": 500
    },
    "image": { 
        "src": "Images/Sun.png",
        "name": "sun1",
        "hOffset": 250,
        "vOffset": 250,
        "alignment": "center"
    },
    "text": {
        "data": "Click Here",
        "size": 36,
        "style": "bold",
        "name": "text1",
        "hOffset": 250,
        "vOffset": 100,
        "alignment": "center",
        "onMouseUp": "sun1.opacity = (sun1.opacity / 100) * 90;"
    }
}}    
    ''';

