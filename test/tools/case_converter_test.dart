import 'package:dash_tools/tools/case_converter/case_converter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CaseStyleX.convert', () {
    const input = 'hello world foo';

    test('camelCase', () => expect(CaseStyle.camel.convert(input), 'helloWorldFoo'));
    test('PascalCase', () => expect(CaseStyle.pascal.convert(input), 'HelloWorldFoo'));
    test('snake_case', () => expect(CaseStyle.snake.convert(input), 'hello_world_foo'));
    test('CONSTANT_CASE', () => expect(CaseStyle.constant.convert(input), 'HELLO_WORLD_FOO'));
    test('kebab-case', () => expect(CaseStyle.kebab.convert(input), 'hello-world-foo'));
    test('dot.case', () => expect(CaseStyle.dot.convert(input), 'hello.world.foo'));
    test('path/case', () => expect(CaseStyle.path.convert(input), 'hello/world/foo'));
    test('Sentence case', () => expect(CaseStyle.sentence.convert(input), 'Hello world foo'));
    test('Title Case', () => expect(CaseStyle.title.convert(input), 'Hello World Foo'));

    test('returns empty for empty input', () {
      for (final style in CaseStyle.values) {
        expect(style.convert(''), '');
      }
    });
  });

  group('convertAllCases', () {
    test('returns a result for every CaseStyle', () {
      final result = convertAllCases('hello world');
      expect(result.keys, containsAll(CaseStyle.values));
    });

    test('returns empty strings for empty input', () {
      final result = convertAllCases('');
      expect(result.values, everyElement(''));
    });

    test('camel and pascal differ by first-letter capitalisation', () {
      final result = convertAllCases('my value');
      expect(result[CaseStyle.camel], 'myValue');
      expect(result[CaseStyle.pascal], 'MyValue');
    });
  });
}
