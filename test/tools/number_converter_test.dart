import 'package:dash_tools/tools/number_converter/number_converter_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NumberConverterController', () {
    late NumberConverterController controller;

    setUp(() => controller = NumberConverterController());
    tearDown(() => controller.dispose());

    test('initialises with decimal 95', () {
      expect(controller.decimal, '95');
      expect(controller.hex, '5f');
      expect(controller.octal, '137');
      expect(controller.binary, '1011111');
    });

    group('convertFromDecimal', () {
      test('converts known value', () {
        controller.convertFromDecimal('255');
        expect(controller.decimal, '255');
        expect(controller.hex, 'ff');
        expect(controller.octal, '377');
        expect(controller.binary, '11111111');
      });

      test('converts zero', () {
        controller.convertFromDecimal('0');
        expect(controller.decimal, '0');
        expect(controller.hex, '0');
        expect(controller.octal, '0');
        expect(controller.binary, '0');
      });

      test('clears all fields for invalid input', () {
        controller.convertFromDecimal('abc');
        expect(controller.decimal, '');
        expect(controller.hex, '');
        expect(controller.octal, '');
        expect(controller.binary, '');
      });

      test('clears all fields for empty input', () {
        controller.convertFromDecimal('');
        expect(controller.decimal, '');
        expect(controller.hex, '');
      });
    });

    group('convertFromHex', () {
      test('converts ff', () {
        controller.convertFromHex('ff');
        expect(controller.decimal, '255');
        expect(controller.octal, '377');
        expect(controller.binary, '11111111');
        expect(controller.hex, 'ff');
      });

      test('accepts uppercase hex', () {
        controller.convertFromHex('FF');
        expect(controller.decimal, '255');
      });

      test('clears all fields for non-hex input', () {
        controller.convertFromHex('GG');
        expect(controller.decimal, '');
        expect(controller.hex, '');
      });
    });

    group('convertFromOctal', () {
      test('converts 377', () {
        controller.convertFromOctal('377');
        expect(controller.decimal, '255');
        expect(controller.hex, 'ff');
        expect(controller.binary, '11111111');
      });

      test('clears all fields for invalid octal', () {
        controller.convertFromOctal('89');
        expect(controller.decimal, '');
      });
    });

    group('convertFromBinary', () {
      test('converts 11111111', () {
        controller.convertFromBinary('11111111');
        expect(controller.decimal, '255');
        expect(controller.hex, 'ff');
        expect(controller.octal, '377');
      });

      test('clears all fields for non-binary input', () {
        controller.convertFromBinary('102');
        expect(controller.decimal, '');
      });
    });

    test('notifies listeners on conversion', () {
      var count = 0;
      controller.addListener(() => count++);
      controller.convertFromDecimal('42');
      expect(count, greaterThan(0));
    });

    test('round-trip: decimal → hex → decimal', () {
      controller.convertFromDecimal('1234');
      final h = controller.hex;
      controller.convertFromHex(h);
      expect(controller.decimal, '1234');
    });
  });
}
