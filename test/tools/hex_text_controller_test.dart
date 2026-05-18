import 'package:dash_tools/tools/hex_text_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('asciiToHex', () {
    test('converts basic ASCII string', () {
      expect(asciiToHex('abc'), '616263');
    });

    test('returns empty string for empty input', () {
      expect(asciiToHex(''), '');
    });

    test('pads single-digit hex values with a leading zero', () {
      expect(asciiToHex('\x09'), '09');
    });

    test('round-trips with hexToAscii', () {
      const s = 'hello world';
      expect(hexToAscii(asciiToHex(s)), s);
    });
  });

  group('hexToAscii', () {
    test('converts basic hex string', () {
      expect(hexToAscii('616263'), 'abc');
    });

    test('returns empty string for empty input', () {
      expect(hexToAscii(''), '');
    });
  });

  group('HexTextController', () {
    late HexTextController controller;

    setUp(() => controller = HexTextController());
    tearDown(() => controller.dispose());

    test('starts in hexToText mode', () {
      expect(controller.mode, HexTextConvertMode.hexToText);
    });

    test('initial output decodes the initial hex input', () {
      expect(
        controller.outputController.text,
        hexToAscii(controller.inputController.text),
      );
    });

    test('strips whitespace from hex input before converting', () {
      controller.inputController.text = '61 62 63';
      expect(controller.outputController.text, 'abc');
    });

    test('switches to textToHex mode and re-converts', () {
      controller.setMode(HexTextConvertMode.textToHex);
      controller.inputController.text = 'hello';
      expect(controller.outputController.text, asciiToHex('hello'));
    });

    test('notifies listeners on mode change', () {
      var notified = false;
      controller.addListener(() => notified = true);
      controller.setMode(HexTextConvertMode.textToHex);
      expect(notified, isTrue);
    });
  });
}
