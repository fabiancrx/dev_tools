import 'dart:convert';

import 'package:dash_tools/tools/base64/base64_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Base64Controller', () {
    late Base64Controller controller;

    setUp(() => controller = Base64Controller());
    tearDown(() => controller.dispose());

    test('starts in encode mode with utf8 codec', () {
      expect(controller.mode, Base64ConverterMode.encode);
      expect(controller.codec, Codec.utf8);
    });

    test('encodes initial input on construction', () {
      expect(
        controller.output,
        base64.encode(utf8.encode('aguacate')),
      );
    });

    test('encodes new input text', () {
      controller.setInput('hello');
      expect(controller.output, base64.encode(utf8.encode('hello')));
    });

    test('decodes base64 input in decode mode', () {
      controller.setMode(Base64ConverterMode.decode);
      controller.setInput(base64.encode(utf8.encode('world')));
      expect(controller.output, 'world');
    });

    test('produces empty output for invalid base64 in decode mode', () {
      controller.setMode(Base64ConverterMode.decode);
      controller.setInput('not!!valid!!base64');
      expect(controller.output, '');
    });

    test('re-encodes when codec changes', () {
      controller.setInput('hello');
      controller.setCodec(Codec.latin1);
      expect(controller.output, base64.encode(latin1.encode('hello')));
    });

    test('notifies listeners when mode changes', () {
      var notified = false;
      controller.addListener(() => notified = true);
      controller.setMode(Base64ConverterMode.decode);
      expect(notified, isTrue);
    });

    test('notifies listeners when codec changes', () {
      var notified = false;
      controller.addListener(() => notified = true);
      controller.setCodec(Codec.ascii);
      expect(notified, isTrue);
    });
  });

  group('Codec', () {
    test('has correct display names', () {
      expect(Codec.utf8.displayName, 'UTF-8');
      expect(Codec.latin1.displayName, 'Latin-1');
      expect(Codec.ascii.displayName, 'ASCII');
    });
  });
}
