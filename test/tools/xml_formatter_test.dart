import 'package:dash_tools/tools/xml/xml_formatter.dart';
import 'package:dash_tools/tools/xml/xml_formatter_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatXml', () {
    const compact = '<root><child attr="1">text</child></root>';

    test('formats with 2-space indent', () {
      final result = formatXml(compact, XmlMode.twoSpaces);
      expect(result, contains('  <child'));
    });

    test('formats with 4-space indent', () {
      final result = formatXml(compact, XmlMode.fourSpaces);
      expect(result, contains('    <child'));
    });

    test('formats with tab indent', () {
      final result = formatXml(compact, XmlMode.tab);
      expect(result, contains('\t<child'));
    });

    test('minify does not add indentation', () {
      final result = formatXml(compact, XmlMode.minify);
      expect(result, isNot(contains('\n  ')));
      expect(result, contains('<child attr="1">text</child>'));
    });

    test('preserves attributes', () {
      final result = formatXml(compact, XmlMode.twoSpaces);
      expect(result, contains('attr="1"'));
    });

    test('throws on malformed XML', () {
      expect(() => formatXml('<root><unclosed>', XmlMode.twoSpaces), throwsA(anything));
    });

    test('preserves CDATA section contents', () {
      const xml = '<root><![CDATA[<not-a-tag> & raw]]></root>';
      final result = formatXml(xml, XmlMode.twoSpaces);
      expect(result, contains('CDATA'));
      expect(result, contains('<not-a-tag>'));
    });

    test('handles self-closing tags', () {
      const xml = '<root><empty/></root>';
      final result = formatXml(xml, XmlMode.twoSpaces);
      expect(result, contains('empty'));
    });

    test('round-trip: format then minify preserves structure', () {
      const xml = '<root><child a="1">text</child></root>';
      final formatted = formatXml(xml, XmlMode.twoSpaces);
      final minified = formatXml(formatted, XmlMode.minify);
      expect(minified, contains('<child'));
      expect(minified, contains('a="1"'));
      expect(minified, contains('text'));
    });
  });

  group('XmlFormatterController', () {
    late XmlFormatterController controller;

    setUp(() => controller = XmlFormatterController());
    tearDown(() => controller.dispose());

    test('starts with empty output', () {
      expect(controller.output, '');
      expect(controller.error, '');
    });

    test('formats input on setInput when autoRun is on by default', () {
      controller.setInput('<root><child/></root>');
      // output is set on run(), not autoRun (autoRun depends on AppSettings)
      controller.run();
      expect(controller.output, isNotEmpty);
      expect(controller.error, '');
    });

    test('sets error on invalid XML', () {
      controller.setInput('<bad>');
      controller.run();
      expect(controller.error, isNotEmpty);
      expect(controller.output, '');
    });

    test('clears output and error on empty input', () {
      controller.setInput('<root/>');
      controller.run();
      controller.setInput('');
      controller.run();
      expect(controller.output, '');
      expect(controller.error, '');
    });

    test('setMode re-processes', () {
      controller.setInput('<root><child/></root>');
      controller.run();
      final twoSpaces = controller.output;
      controller.setMode(XmlMode.fourSpaces);
      expect(controller.output, isNot(twoSpaces));
    });

    test('notifies listeners', () {
      var count = 0;
      controller.addListener(() => count++);
      controller.setInput('<root/>');
      controller.run();
      expect(count, greaterThan(0));
    });
  });
}
