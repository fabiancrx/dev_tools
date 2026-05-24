import 'package:dash_tools/tools/qr_code/qr_code_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('QrCodeController', () {
    late QrCodeController controller;

    setUp(() => controller = QrCodeController());
    tearDown(() => controller.dispose());

    test('starts with default input and builds QrImage', () {
      expect(controller.input, 'https://flutter.dev');
      expect(controller.qrImage, isNotNull);
    });

    test('setInput with non-empty value builds QrImage', () {
      controller.setInput('Hello, World!');
      expect(controller.input, 'Hello, World!');
      expect(controller.qrImage, isNotNull);
    });

    test('setInput with empty string clears QrImage', () {
      controller.setInput('');
      expect(controller.qrImage, isNull);
    });

    test('setErrorCorrectionLevel changes level and notifies', () {
      var count = 0;
      controller.addListener(() => count++);
      controller.setErrorCorrectionLevel(QrErrorCorrectLevel.H);
      expect(controller.errorCorrectionLevel, QrErrorCorrectLevel.H);
      expect(count, greaterThan(0));
    });

    test('setShapeType updates shapeType and notifies', () {
      var count = 0;
      controller.addListener(() => count++);
      controller.setShapeType(QrShapeType.dots);
      expect(controller.shapeType, QrShapeType.dots);
      expect(count, greaterThan(0));
    });

    test('setFillType updates fillType', () {
      controller.setFillType(QrFillType.gradient);
      expect(controller.fillType, QrFillType.gradient);
    });

    test('setSolidColor updates solidColor', () {
      controller.setSolidColor(Colors.red);
      expect(controller.solidColor, Colors.red);
    });

    test('setGradientIndex updates gradientIndex', () {
      controller.setGradientIndex(2);
      expect(controller.gradientIndex, 2);
    });

    test('setRoundFactor updates roundFactor', () {
      controller.setRoundFactor(0.5);
      expect(controller.roundFactor, 0.5);
    });

    test('setRounding updates rounding', () {
      controller.setRounding(0.3);
      expect(controller.rounding, 0.3);
    });

    test('setDensity updates density', () {
      controller.setDensity(0.8);
      expect(controller.density, 0.8);
    });

    test('run() notifies listeners', () {
      var count = 0;
      controller.addListener(() => count++);
      controller.run();
      expect(count, greaterThan(0));
    });

    group('buildDecoration', () {
      test('returns PrettyQrDecoration with smooth shape by default', () {
        controller.setShapeType(QrShapeType.smooth);
        final dec = controller.buildDecoration();
        expect(dec, isA<PrettyQrDecoration>());
        expect(dec.shape, isA<PrettyQrSmoothSymbol>());
      });

      test('returns squares shape when QrShapeType.squares', () {
        controller.setShapeType(QrShapeType.squares);
        final dec = controller.buildDecoration();
        expect(dec.shape, isA<PrettyQrSquaresSymbol>());
      });

      test('returns dots shape when QrShapeType.dots', () {
        controller.setShapeType(QrShapeType.dots);
        final dec = controller.buildDecoration();
        expect(dec.shape, isA<PrettyQrDotsSymbol>());
      });

      test('background is white', () {
        final dec = controller.buildDecoration();
        expect(dec.background, Colors.white);
      });
    });
  });
}
