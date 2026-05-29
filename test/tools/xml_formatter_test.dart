import 'package:dash_tools/tools/xml/xml_formatter.dart';
import 'package:dash_tools/tools/xml/xml_formatter_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late XmlFormatterController controller;

  setUp(() => controller = XmlFormatterController());
  tearDown(() => controller.dispose());

  // ── processXml success ────────────────────────────────────────────────────

  group('processXml success', () {
    const compact = '<root><child attr="1">text</child></root>';

    test('prettifies with two-space indent', () {
      final result = processXml(compact, XmlMode.twoSpaces) as XmlFormatSuccess;
      expect(result.output, contains('  <child'));
    });

    test('prettifies with four-space indent', () {
      final result = processXml(compact, XmlMode.fourSpaces) as XmlFormatSuccess;
      expect(result.output, contains('    <child'));
    });

    test('prettifies with tab indent', () {
      final result = processXml(compact, XmlMode.tab) as XmlFormatSuccess;
      expect(result.output, contains('\t<child'));
    });

    test('minifies removes indentation', () {
      final result = processXml(compact, XmlMode.minify) as XmlFormatSuccess;
      expect(result.output, isNot(contains('\n  ')));
      expect(result.output, contains('<child attr="1">text</child>'));
    });

    test('preserves attributes', () {
      final result = processXml(compact, XmlMode.twoSpaces) as XmlFormatSuccess;
      expect(result.output, contains('attr="1"'));
    });

    test('preserves CDATA contents', () {
      const xml = '<root><![CDATA[<not-a-tag> & raw]]></root>';
      final result = processXml(xml, XmlMode.twoSpaces) as XmlFormatSuccess;
      expect(result.output, contains('CDATA'));
      expect(result.output, contains('<not-a-tag>'));
    });

    test('handles self-closing tags', () {
      final result = processXml('<root><empty/></root>', XmlMode.twoSpaces) as XmlFormatSuccess;
      expect(result.output, contains('empty'));
    });

    test('round-trips: format then minify preserves content', () {
      final formatted = (processXml(compact, XmlMode.twoSpaces) as XmlFormatSuccess).output;
      final minified = (processXml(formatted, XmlMode.minify) as XmlFormatSuccess).output;
      expect(minified, contains('attr="1"'));
      expect(minified, contains('text'));
    });

    test('round-trips the sample XML idempotently', () {
      final first = (processXml(kSampleXml, XmlMode.twoSpaces) as XmlFormatSuccess).output;
      final second = (processXml(first, XmlMode.twoSpaces) as XmlFormatSuccess).output;
      expect(first, second);
    });
  });

  // ── processXml error ─────────────────────────────────────────────────────

  group('processXml error — type', () {
    test('unclosed tag returns error', () {
      expect(processXml('<root><a>', XmlMode.twoSpaces), isA<XmlFormatError>());
    });

    test('malformed attribute returns error', () {
      expect(processXml('<root a=>', XmlMode.twoSpaces), isA<XmlFormatError>());
    });

    test('empty string returns error', () {
      expect(processXml('', XmlMode.twoSpaces), isA<XmlFormatError>());
    });

    test('plain text without root element returns error', () {
      expect(processXml('just text', XmlMode.twoSpaces), isA<XmlFormatError>());
    });

    test('error message is non-empty', () {
      final err = processXml('<bad', XmlMode.twoSpaces) as XmlFormatError;
      expect(err.message, isNotEmpty);
    });
  });

  group('processXml error — position', () {
    test('error on first line has line >= 1', () {
      final err = processXml('<bad', XmlMode.twoSpaces) as XmlFormatError;
      expect(err.line, greaterThanOrEqualTo(1));
      expect(err.col, greaterThanOrEqualTo(1));
    });

    test('error on second line reports line 2', () {
      final err = processXml('<root>\n  <bad', XmlMode.twoSpaces) as XmlFormatError;
      expect(err.line, 2);
    });

    test('error line advances with each newline before error', () {
      final err1 = processXml('<root>\n<bad', XmlMode.twoSpaces) as XmlFormatError;
      final err2 = processXml('<root>\n<ok/>\n<bad', XmlMode.twoSpaces) as XmlFormatError;
      expect(err2.line, greaterThan(err1.line));
    });
  });

  // ── queryXpath ────────────────────────────────────────────────────────────

  group('queryXpath', () {
    test('selects all elements by name', () {
      final result = queryXpath(kSampleXml, '//title');
      expect(result, contains('Everyday Italian'));
      expect(result, contains('Harry Potter'));
    });

    test('filters by attribute value', () {
      final result = queryXpath(kSampleXml, "//book[@category='cooking']");
      expect(result, contains('Everyday Italian'));
      expect(result, isNot(contains('Harry Potter')));
    });

    test('absolute path from root selects nodes', () {
      final result = queryXpath(kSampleXml, '/bookstore/book/author');
      expect(result, contains('Giada De Laurentiis'));
    });

    test('returns no-matches comment when nothing found', () {
      expect(queryXpath(kSampleXml, '//nonexistent'), '<!-- no matches -->');
    });

    test('returns scalar for string() function', () {
      final result = queryXpath(kSampleXml, 'string(//title[1])');
      expect(result, 'Everyday Italian');
    });

    test('throws on invalid XPath expression', () {
      expect(() => queryXpath(kSampleXml, '///!!!'), throwsA(anything));
    });

    test('throws on malformed XML', () {
      expect(() => queryXpath('<bad', '//title'), throwsA(anything));
    });
  });

  // ── controller format ─────────────────────────────────────────────────────

  group('controller — format', () {
    test('starts with empty output and no error', () {
      expect(controller.output, '');
      expect(controller.parseError, isNull);
    });

    test('formats on run()', () {
      controller.setInput('<root><child/></root>');
      controller.run();
      expect(controller.output, isNotEmpty);
      expect(controller.parseError, isNull);
    });

    test('sets parseError on invalid XML', () {
      controller.setInput('<bad>');
      controller.run();
      expect(controller.parseError, isNotNull);
      expect(controller.output, '');
    });

    test('clears parseError when input becomes valid', () {
      controller.setInput('<bad>');
      controller.run();
      controller.setInput('<root/>');
      controller.run();
      expect(controller.parseError, isNull);
    });

    test('clears output and error on empty input', () {
      controller.setInput('<root/>');
      controller.run();
      controller.setInput('');
      controller.run();
      expect(controller.output, '');
      expect(controller.parseError, isNull);
    });

    test('setMode re-formats existing input', () {
      controller.setInput('<root><child/></root>');
      controller.run();
      final twoSpaces = controller.output;
      controller.setMode(XmlMode.fourSpaces);
      expect(controller.output, isNot(twoSpaces));
    });

    test('notifies listeners on run()', () {
      var count = 0;
      controller.addListener(() => count++);
      controller.setInput('<root/>');
      controller.run();
      expect(count, greaterThan(0));
    });
  });

  // ── controller XPath ──────────────────────────────────────────────────────

  group('controller — XPath query', () {
    setUp(() {
      controller.setInput(kSampleXml);
      controller.run();
    });

    test('hasActiveQuery is false initially', () {
      expect(controller.hasActiveQuery, isFalse);
    });

    test('hasActiveQuery is true when query is set', () {
      controller.setQuery('//title');
      expect(controller.hasActiveQuery, isTrue);
    });

    test('filters output when query is set', () {
      controller.setQuery("//book[@category='cooking']");
      expect(controller.output, contains('Everyday Italian'));
      expect(controller.output, isNot(contains('Harry Potter')));
    });

    test('restores full output when query is cleared', () {
      controller.setQuery('//title');
      controller.setQuery('');
      expect(controller.hasActiveQuery, isFalse);
      expect(controller.output, contains('Everyday Italian'));
      expect(controller.output, contains('Harry Potter'));
    });

    test('sets queryError for invalid expression', () {
      controller.setQuery('///invalid!!!');
      expect(controller.queryError, isTrue);
    });

    test('clears queryError when expression becomes valid', () {
      controller.setQuery('///invalid!!!');
      controller.setQuery('//title');
      expect(controller.queryError, isFalse);
    });

    test('keeps full output visible when query errors', () {
      final full = controller.output;
      controller.setQuery('///invalid!!!');
      expect(controller.output, full);
    });

    test('re-applies query after mode change', () {
      controller.setQuery('//title');
      controller.setMode(XmlMode.minify);
      expect(controller.hasActiveQuery, isTrue);
      expect(controller.output, contains('Everyday Italian'));
    });
  });
}
