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

    test(r'unescapes \uXXXX 4-digit unicode escape', () {
      expect(unescape(r'A'), 'A');
      expect(unescape(r'é'), 'é');
    });

    test(r'unescapes \u{XXXX} unicode escape', () {
      expect(unescape(r'\u{0041}'), 'A');
    });

    test(r'unescapes \xXX hex escape', () {
      expect(unescape(r'\x41'), 'A');
    });

    test(r'unescapes \f form-feed', () {
      expect(unescape(r'\f'), '\f');
    });

    test(r'unescapes \b backspace', () {
      expect(unescape(r'\b'), '\b');
    });

    test(r'unescapes \v vertical tab', () {
      expect(unescape(r'\v'), '\v');
    });

    test('handles multiple different escapes in sequence', () {
      expect(unescape(r'\n\t\r'), '\n\t\r');
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
      expect(controller.output, isNotEmpty);
    });

    test('escapes inner quotes without surrounding quotes', () {
      controller.setInput('say "hi"');
      final output = controller.output;
      expect(output, r'say \"hi\"');
      expect(output, isNot(startsWith('"')));
    });

    test('escapes a newline character', () {
      controller.setInput('line1\nline2');
      expect(controller.output, r'line1\nline2');
    });

    test('unescapes escaped quotes in unescape mode', () {
      controller.setMode(JsonEncodeMode.unescape);
      controller.setInput(r'say \"hi\"');
      expect(controller.output, 'say "hi"');
    });

    test('round-trip: escape then unescape recovers original', () {
      const original = 'Hello, "world"!\nNew line.';
      controller.setInput(original);
      final escaped = controller.output;

      controller.setMode(JsonEncodeMode.unescape);
      controller.setInput(escaped);
      expect(controller.output, original);
    });

    test('notifies listeners on mode change', () {
      var notified = false;
      controller.addListener(() => notified = true);
      controller.setMode(JsonEncodeMode.unescape);
      expect(notified, isTrue);
    });
  });
}
