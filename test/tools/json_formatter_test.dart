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

  group('process', () {
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

    test('returns error with line and column for invalid JSON', () {
      final result = controller.process('not json');
      expect(result, isA<JsonFormatError>());
      final err = result as JsonFormatError;
      expect(err.line, greaterThanOrEqualTo(1));
      expect(err.col, greaterThanOrEqualTo(1));
      expect(err.message, isNotEmpty);
    });

    test('reports correct line and column for mid-document error', () {
      const input = '{\n  "a": 1,\n  "b": BAD\n}';
      final result = controller.process(input);
      expect(result, isA<JsonFormatError>());
      final err = result as JsonFormatError;
      expect(err.line, 3);
    });
  });
}
