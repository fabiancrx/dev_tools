import 'package:dash_tools/tools/regex_tester/regex_tester.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('runRegex', () {
    test('returns empty result for empty pattern', () {
      final result = runRegex('', 'hello');
      expect(result.matches, isEmpty);
      expect(result.error, isNull);
    });

    test('finds simple matches', () {
      final result = runRegex(r'\d+', 'abc 123 def 456');
      expect(result.matches.length, 2);
      expect(result.matches[0].full, '123');
      expect(result.matches[1].full, '456');
    });

    test('captures groups', () {
      final result = runRegex(r'(\w+)@(\w+)', 'user@example');
      expect(result.matches.length, 1);
      expect(result.matches[0].groups, ['user', 'example']);
    });

    test('respects caseSensitive flag', () {
      final sensitive = runRegex('hello', 'Hello world', caseSensitive: true);
      expect(sensitive.matches, isEmpty);

      final insensitive = runRegex('hello', 'Hello world', caseSensitive: false);
      expect(insensitive.matches.length, 1);
    });

    test('respects multiLine flag', () {
      final singleLine = runRegex(r'^bar', 'foo\nbar', multiLine: false);
      expect(singleLine.matches, isEmpty);

      final multiLine = runRegex(r'^bar', 'foo\nbar', multiLine: true);
      expect(multiLine.matches.length, 1);
    });

    test('respects dotAll flag', () {
      final noDotAll = runRegex(r'a.b', 'a\nb', dotAll: false);
      expect(noDotAll.matches, isEmpty);

      final dotAll = runRegex(r'a.b', 'a\nb', dotAll: true);
      expect(dotAll.matches.length, 1);
    });

    test('returns error for invalid pattern', () {
      final result = runRegex(r'[invalid', 'test');
      expect(result.error, isNotNull);
      expect(result.matches, isEmpty);
    });

    test('reports start and end positions', () {
      final result = runRegex('foo', 'barfoobaz');
      expect(result.matches[0].start, 3);
      expect(result.matches[0].end, 6);
    });
  });
}
