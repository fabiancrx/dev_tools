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
      expect(controller.output, hexToAscii(controller.input));
    });

    test('strips whitespace from hex input before converting', () {
      controller.setInput('61 62 63');
      expect(controller.output, 'abc');
    });

    test('switches to textToHex mode and re-converts', () {
      controller.setMode(HexTextConvertMode.textToHex);
      controller.setInput('hello');
      expect(controller.output, asciiToHex('hello'));
    });

    test('uppercase hex input is normalised before conversion', () {
      controller.setInput('616263'.toUpperCase()); // '616263' → 'ABC' uppercase fails, but '61' → 'a'
      // hex input is case-insensitive via int.parse with radix 16
      expect(controller.output, 'abc');
    });

    test('odd-length hex input truncates last nibble', () {
      // '6162' + extra nibble '6' → only '616' is truncated to 1 full byte '61'
      controller.setInput('616'); // 3 chars → 1 full byte pair '61' = 'a'
      expect(controller.output, 'a');
    });

    test('non-ASCII char in textToHex encodes correctly', () {
      controller.setMode(HexTextConvertMode.textToHex);
      // '©' is U+00A9 → codeUnit 169 → 'a9'
      controller.setInput('©');
      expect(controller.output, 'a9');
    });

    test('notifies listeners on mode change', () {
      var notified = false;
      controller.addListener(() => notified = true);
      controller.setMode(HexTextConvertMode.textToHex);
      expect(notified, isTrue);
    });
  });
}
