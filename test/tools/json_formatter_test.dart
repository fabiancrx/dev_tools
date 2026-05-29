import 'package:dash_tools/tools/json/json_screen_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ProviderContainer container;
  late JsonPageController controller;

  setUp(() {
    container = ProviderContainer();
    controller = container.read(jsonControllerProvider.notifier);
  });

  tearDown(() => container.dispose());

  const sample = '{"store":{"book":[{"title":"A","price":5},{"title":"B","price":15}],"name":"Books"}}';

  group('queryJson', () {
    test('returns single match unwrapped', () {
      final result = controller.queryJson(sample, r'$.store.name');
      expect(result, '"Books"');
    });

    test('returns multiple matches as array', () {
      final result = controller.queryJson(sample, r'$.store.book[*].title');
      expect(result, contains('"A"'));
      expect(result, contains('"B"'));
      expect(result, startsWith('['));
    });

    test('returns empty array when nothing matches', () {
      final result = controller.queryJson(sample, r'$.store.magazine');
      expect(result, '[]');
    });

    test('throws on invalid JSON', () {
      expect(() => controller.queryJson('not json', r'$.foo'), throwsFormatException);
    });

    test('throws on invalid JSONPath expression', () {
      expect(() => controller.queryJson(sample, r'$.[invalid'), throwsA(anything));
    });

    test('respects current indent mode', () {
      controller.changeMode(JsonMode.fourSpaces);
      final result = controller.queryJson('{"a":{"b":1}}', r'$.a');
      expect(result, contains('    "b"'));
    });

    test('unwraps nested object result', () {
      final result = controller.queryJson(sample, r'$.store.book[0]');
      expect(result, contains('"title"'));
      expect(result, contains('"price"'));
      expect(result, isNot(startsWith('[')));
    });
  });

  group('process success', () {
    test('prettifies with two-space indent by default', () {
      final result = controller.process('{"a":1}');
      expect(result, isA<JsonFormatSuccess>());
      expect((result as JsonFormatSuccess).output, '{\n  "a": 1\n}');
    });

    test('minifies when mode is minify', () {
      controller.changeMode(JsonMode.minify);
      final result = controller.process('{ "a" : 1 }');
      expect(result, isA<JsonFormatSuccess>());
      expect((result as JsonFormatSuccess).output, '{"a":1}');
    });

    test('prettifies with four-space indent', () {
      controller.changeMode(JsonMode.fourSpaces);
      final result = controller.process('{"a":1}');
      expect((result as JsonFormatSuccess).output, '{\n    "a": 1\n}');
    });

    test('prettifies with tab indent', () {
      controller.changeMode(JsonMode.tab);
      final result = controller.process('{"a":1}');
      expect((result as JsonFormatSuccess).output, '{\n\t"a": 1\n}');
    });
  });

  group('process error — type', () {
    test('empty string returns error', () {
      expect(controller.process(''), isA<JsonFormatError>());
    });

    test('bare word returns error', () {
      expect(controller.process('BAD'), isA<JsonFormatError>());
    });

    test('trailing comma returns error', () {
      expect(controller.process('{"a": 1,}'), isA<JsonFormatError>());
    });

    test('unclosed object returns error', () {
      expect(controller.process('{"a": 1'), isA<JsonFormatError>());
    });

    test('unclosed string returns error', () {
      expect(controller.process('{"a": "unterminated'), isA<JsonFormatError>());
    });

    test('duplicate key is valid JSON (returns success)', () {
      // Dart's JSON parser accepts duplicate keys — last value wins
      expect(controller.process('{"a":1,"a":2}'), isA<JsonFormatSuccess>());
    });

    test('error message is non-empty', () {
      final err = controller.process('BAD') as JsonFormatError;
      expect(err.message, isNotEmpty);
    });

    test('error result is independent of indent mode', () {
      controller.changeMode(JsonMode.minify);
      expect(controller.process('BAD'), isA<JsonFormatError>());
      controller.changeMode(JsonMode.fourSpaces);
      expect(controller.process('BAD'), isA<JsonFormatError>());
    });
  });

  group('process error — position', () {
    JsonFormatError err(String input) => controller.process(input) as JsonFormatError;

    test('empty string: error at line 1 col 1', () {
      final e = err('');
      expect(e.line, 1);
      expect(e.col, 1);
    });

    test('error at very first character: line 1', () {
      // 'B' is not a valid JSON value start → offset 0
      final e = err('BAD');
      expect(e.line, 1);
      expect(e.col, 1);
    });

    test('error mid first line: col advances past valid prefix', () {
      // {"a": BAD} — 'B' comes after {"a":  (6 chars) → col 7
      final e = err('{"a": BAD}');
      expect(e.line, 1);
      expect(e.col, greaterThan(1));
    });

    test('error on line 2', () {
      // Second line has the bad token
      final e = err('{\n  "a": BAD\n}');
      expect(e.line, 2);
    });

    test('error on line 3 with correct column', () {
      // Line 3 content: '  "b": BAD' — 'B' is the 8th character → col 8
      final e = err('{\n  "a": 1,\n  "b": BAD\n}');
      expect(e.line, 3);
      expect(e.col, 8);
    });

    test('error line tracks deeper nesting', () {
      const input = '{\n  "a": 1,\n  "b": 2,\n  "c": 3,\n  "d": BAD\n}';
      expect(err(input).line, 5);
    });

    test('unclosed object: error position is valid (line >= 1, col >= 1)', () {
      final e = err('{"a": 1');
      expect(e.line, greaterThanOrEqualTo(1));
      expect(e.col, greaterThanOrEqualTo(1));
    });
  });
}
