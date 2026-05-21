import 'package:dash_tools/tools/yaml/yaml_formatter.dart';
import 'package:dash_tools/tools/yaml/yaml_formatter_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatYaml', () {
    test('normalizes messy spacing', () {
      const messy = 'name:   John\nage:   30';
      final result = formatYaml(messy);
      expect(result, contains('name: John'));
      expect(result, contains('age: 30'));
    });

    test('expands inline map to block style', () {
      const input = 'address: {street: "123 Main", city: Anytown}';
      final result = formatYaml(input);
      expect(result, contains('street:'));
      expect(result, contains('city:'));
    });

    test('expands inline list to block style', () {
      const input = 'hobbies: [reading, coding]';
      final result = formatYaml(input);
      expect(result, contains('- reading'));
      expect(result, contains('- coding'));
    });

    test('preserves boolean values', () {
      final result = formatYaml('active: true');
      expect(result, contains('true'));
    });

    test('throws on invalid YAML', () {
      expect(() => formatYaml(': invalid: yaml: :::'), throwsA(anything));
    });
  });

  group('YamlFormatterController', () {
    late YamlFormatterController controller;

    setUp(() => controller = YamlFormatterController());
    tearDown(() => controller.dispose());

    test('starts with empty output and error', () {
      expect(controller.output, '');
      expect(controller.error, '');
    });

    test('formats on run()', () {
      controller.setInput('name:   Alice\nage:   25');
      controller.run();
      expect(controller.output, contains('name: Alice'));
      expect(controller.error, '');
    });

    test('sets error on invalid YAML', () {
      controller.setInput(': bad: yaml: :::');
      controller.run();
      expect(controller.error, isNotEmpty);
      expect(controller.output, '');
    });

    test('clears on empty input', () {
      controller.setInput('name: Alice');
      controller.run();
      controller.setInput('');
      controller.run();
      expect(controller.output, '');
      expect(controller.error, '');
    });

    test('notifies listeners', () {
      var count = 0;
      controller.addListener(() => count++);
      controller.setInput('x: 1');
      controller.run();
      expect(count, greaterThan(0));
    });
  });
}
