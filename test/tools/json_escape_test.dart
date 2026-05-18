import 'package:dash_tools/tools/json/json_escape_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('unescape', () {
    test('returns plain string unchanged', () {
      expect(unescape('hello world'), 'hello world');
    });

    test('returns empty string for empty input', () {
      expect(unescape(''), '');
    });

    test(r'unescapes \n as newline', () {
      expect(unescape(r'\n'), '\n');
    });

    test(r'unescapes \t as tab', () {
      expect(unescape(r'\t'), '\t');
    });

    test(r'unescapes \r as carriage return', () {
      expect(unescape(r'\r'), '\r');
    });

    test(r'unescapes \\ as a single backslash', () {
      expect(unescape(r'\\'), r'\');
    });

    test(r'unescapes \uXXXX unicode escape', () {
      expect(unescape(r'A'), 'A');
    });

    test(r'unescapes \u{XXXX} unicode escape', () {
      expect(unescape(r'\u{0041}'), 'A');
    });

    test(r'unescapes \xXX hex escape', () {
      expect(unescape(r'\x41'), 'A');
    });

    test('passes through unknown escape sequences as the literal character', () {
      expect(unescape(r'\q'), 'q');
    });

    test('handles mixed escape sequences in a single string', () {
      expect(unescape(r'foo\nbar\ttab'), 'foo\nbar\ttab');
    });
  });

  group('JsonEscapeController', () {
    late JsonEscapeController controller;

    setUp(() => controller = JsonEscapeController());
    tearDown(() => controller.dispose());

    test('starts in escape mode', () {
      expect(controller.mode, JsonEncodeMode.escape);
    });

    test('produces non-empty output for the initial populated text', () {
      expect(controller.outputController.text, isNotEmpty);
    });

    test('escapes inner quotes without surrounding quotes', () {
      controller.inputController.text = 'say "hi"';
      final output = controller.outputController.text;
      expect(output, r'say \"hi\"');
      expect(output, isNot(startsWith('"')));
    });

    test('escapes a newline character', () {
      controller.inputController.text = 'line1\nline2';
      expect(controller.outputController.text, r'line1\nline2');
    });

    test('unescapes escaped quotes in unescape mode', () {
      controller.setMode(JsonEncodeMode.unescape);
      controller.inputController.text = r'say \"hi\"';
      expect(controller.outputController.text, 'say "hi"');
    });

    test('round-trip: escape then unescape recovers original', () {
      const original = 'Hello, "world"!\nNew line.';
      controller.inputController.text = original;
      final escaped = controller.outputController.text;

      controller.setMode(JsonEncodeMode.unescape);
      controller.inputController.text = escaped;
      expect(controller.outputController.text, original);
    });

    test('notifies listeners on mode change', () {
      var notified = false;
      controller.addListener(() => notified = true);
      controller.setMode(JsonEncodeMode.unescape);
      expect(notified, isTrue);
    });
  });
}
