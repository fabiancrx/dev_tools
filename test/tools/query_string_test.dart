import 'package:dash_tools/tools/query_string/query_string.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseQueryString', () {
    test('parses simple key=value pairs', () {
      final result = parseQueryString('a=1&b=hello');
      expect(result, {'a': '1', 'b': 'hello'});
    });

    test('strips leading ? prefix', () {
      expect(parseQueryString('?key=val'), {'key': 'val'});
    });

    test('extracts query portion from a full URL', () {
      final result = parseQueryString('https://example.com/path?foo=bar&x=1');
      expect(result, {'foo': 'bar', 'x': '1'});
    });

    test('returns empty map for empty input', () {
      expect(parseQueryString(''), isEmpty);
      expect(parseQueryString('   '), isEmpty);
    });

    test('decodes percent-encoded values', () {
      final result = parseQueryString('q=hello%20world');
      expect(result['q'], 'hello world');
    });
  });

  group('queryStringToJson', () {
    test('returns valid JSON string', () {
      final json = queryStringToJson('a=1&b=2');
      expect(json, contains('"a"'));
      expect(json, contains('"1"'));
    });

    test('returns empty string for empty input', () {
      expect(queryStringToJson(''), '');
    });

    test('pretty-prints with two-space indent', () {
      final json = queryStringToJson('x=1');
      expect(json, contains('\n'));
    });
  });
}
