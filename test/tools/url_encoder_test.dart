import 'package:dash_tools/tools/url_encoder/url_encoder.dart';
import 'package:dash_tools/tools/url_encoder/url_encoder_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('encodeUrl / decodeUrl', () {
    test('encodes component special chars', () {
      expect(encodeUrl('hello world', UrlEncodeType.component), 'hello%20world');
      expect(encodeUrl('a=1&b=2', UrlEncodeType.component), 'a%3D1%26b%3D2');
    });

    test('encodes full URL preserves scheme and slashes', () {
      const url = 'https://example.com/path?q=hello world';
      final encoded = encodeUrl(url, UrlEncodeType.full);
      expect(encoded, contains('https://'));
      expect(encoded, contains('hello%20world'));
    });

    test('decodes component-encoded string', () {
      expect(decodeUrl('hello%20world', UrlEncodeType.component), 'hello world');
      expect(decodeUrl('a%3D1%26b%3D2', UrlEncodeType.component), 'a=1&b=2');
    });

    test('returns empty string for empty input', () {
      expect(encodeUrl('', UrlEncodeType.component), '');
      expect(decodeUrl('', UrlEncodeType.full), '');
    });

    test('returns empty string for invalid percent-encoding', () {
      expect(decodeUrl('%GG', UrlEncodeType.component), '');
    });
  });

  group('UrlEncoderController', () {
    late UrlEncoderController controller;

    setUp(() => controller = UrlEncoderController());
    tearDown(() => controller.dispose());

    test('starts in encode / component mode with empty output', () {
      expect(controller.mode, UrlEncodeMode.encode);
      expect(controller.type, UrlEncodeType.component);
      expect(controller.output, '');
    });

    test('encodes input on setInput', () {
      controller.setInput('hello world');
      expect(controller.output, 'hello%20world');
    });

    test('decodes input after mode change', () {
      controller.setMode(UrlEncodeMode.decode);
      controller.setInput('hello%20world');
      expect(controller.output, 'hello world');
    });

    test('re-processes when type changes', () {
      controller.setInput('https://example.com/path?q=1 2');
      final componentEncoded = controller.output;
      controller.setType(UrlEncodeType.full);
      expect(controller.output, isNot(componentEncoded));
    });

    test('run() forces update', () {
      controller.setInput('test value');
      final first = controller.output;
      controller.run();
      expect(controller.output, first);
    });

    test('notifies listeners on setInput', () {
      var count = 0;
      controller.addListener(() => count++);
      controller.setInput('x');
      expect(count, greaterThan(0));
    });
  });
}
