import 'package:dash_tools/tools/json_yaml/json_yaml_converter.dart';
import 'package:dash_tools/tools/json_yaml/json_yaml_converter_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('convertJsonToYaml', () {
    test('converts flat object', () {
      final result = convertJsonToYaml('{"name":"Alice","age":30}');
      expect(result, contains('name: Alice'));
      expect(result, contains('age: 30'));
    });

    test('converts nested object', () {
      final result = convertJsonToYaml('{"a":{"b":1}}');
      expect(result, contains('a:'));
      expect(result, contains('b: 1'));
    });

    test('converts array values inside object', () {
      final result = convertJsonToYaml('{"items":["x","y"]}');
      expect(result, contains('- x'));
      expect(result, contains('- y'));
    });

    test('throws on invalid JSON', () {
      expect(() => convertJsonToYaml('{bad}'), throwsA(anything));
    });
  });

  group('convertYamlToJson', () {
    test('converts flat YAML to JSON', () {
      final result = convertYamlToJson('name: Alice\nage: 30');
      expect(result, contains('"name": "Alice"'));
      expect(result, contains('"age": 30'));
    });

    test('converts nested YAML', () {
      final result = convertYamlToJson('a:\n  b: 1');
      expect(result, contains('"a"'));
      expect(result, contains('"b": 1'));
    });

    test('converts YAML list', () {
      final result = convertYamlToJson('- x\n- y');
      expect(result, contains('"x"'));
      expect(result, contains('"y"'));
    });

    test('respects indent parameter', () {
      final result = convertYamlToJson('name: Alice', indent: '    ');
      expect(result, contains('    "name"'));
    });

    test('throws on invalid YAML', () {
      expect(() => convertYamlToJson(': bad: :::'), throwsA(anything));
    });
  });

  group('JsonYamlConverterController', () {
    late JsonYamlConverterController controller;

    setUp(() => controller = JsonYamlConverterController());
    tearDown(() => controller.dispose());

    test('starts in jsonToYaml mode with empty output', () {
      expect(controller.mode, JsonYamlMode.jsonToYaml);
      expect(controller.output, '');
      expect(controller.error, '');
    });

    test('converts JSON to YAML on run()', () {
      controller.setInput('{"x":1}');
      controller.run();
      expect(controller.output, contains('x: 1'));
      expect(controller.error, '');
    });

    test('converts YAML to JSON after mode switch', () {
      controller.setMode(JsonYamlMode.yamlToJson);
      controller.setInput('x: 1');
      controller.run();
      expect(controller.output, contains('"x": 1'));
      expect(controller.error, '');
    });

    test('sets error on invalid input', () {
      controller.setInput('{bad json}');
      controller.run();
      expect(controller.error, isNotEmpty);
      expect(controller.output, '');
    });

    test('clears on empty input', () {
      controller.setInput('{"x":1}');
      controller.run();
      controller.setInput('');
      controller.run();
      expect(controller.output, '');
      expect(controller.error, '');
    });

    test('setMode re-processes existing input', () {
      controller.setInput('{"x":1}');
      controller.run();
      final yamlOut = controller.output;
      controller.setMode(JsonYamlMode.yamlToJson);
      expect(controller.output, isNot(yamlOut));
    });

    test('notifies listeners', () {
      var count = 0;
      controller.addListener(() => count++);
      controller.setInput('{"a":1}');
      controller.run();
      expect(count, greaterThan(0));
    });
  });
}
