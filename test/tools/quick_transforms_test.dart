import 'package:dash_tools/tools/quick_transforms.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('base64Quick', () {
    test('encodes plain text', () {
      expect(base64Quick('hello'), 'aGVsbG8=');
    });

    test('decodes base64-shaped input', () {
      expect(base64Quick('aGVsbG8='), 'hello');
    });
  });

  group('urlQuick', () {
    test('decodes when input has percent escapes', () {
      expect(urlQuick('hello%20world'), 'hello world');
    });

    test('encodes when input has none', () {
      expect(urlQuick('hello world'), 'hello%20world');
    });
  });

  group('jsonFormatQuick', () {
    test('pretty-prints valid json', () {
      expect(jsonFormatQuick('{"a":1}'), '{\n  "a": 1\n}');
    });

    test('returns null for invalid json', () {
      expect(jsonFormatQuick('not json'), isNull);
    });
  });

  group('htmlEntityQuick', () {
    test('decodes when input has entities', () {
      expect(htmlEntityQuick('&lt;p&gt;'), '<p>');
    });

    test('encodes when input has special chars', () {
      expect(htmlEntityQuick('<p>'), '&lt;p&gt;');
    });
  });

  group('hexAsciiQuick', () {
    test('hex to text for valid hex string', () {
      expect(hexAsciiQuick('68656c6c6f'), 'hello');
    });

    test('text to hex for non-hex input', () {
      expect(hexAsciiQuick('hi'), '68 69');
    });
  });

  group('jwtQuick', () {
    test('decodes header and payload', () {
      // {"alg":"HS256","typ":"JWT"}.{"sub":"123","name":"John"} (unsigned)
      const jwt = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjMiLCJuYW1lIjoiSm9obiJ9.sig';
      final out = jwtQuick(jwt);
      expect(out, isNotNull);
      expect(out, contains('"alg": "HS256"'));
      expect(out, contains('"sub": "123"'));
    });

    test('returns null for non-JWT input', () {
      expect(jwtQuick('not a jwt'), isNull);
    });
  });
}
