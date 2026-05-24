import 'package:dash_tools/tools/html_entity/html_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('encodeHtml', () {
    test('encodes HTML special chars', () {
      expect(encodeHtml('<div class="foo">1 & 2</div>'), '&lt;div class=&quot;foo&quot;&gt;1 &amp; 2&lt;/div&gt;');
    });

    test('leaves plain text unchanged', () {
      expect(encodeHtml('hello world'), 'hello world');
    });

    test('encodeNonAscii uses numeric hex entities for chars > 127', () {
      final result = encodeHtml('café', encodeNonAscii: true);
      expect(result, 'caf&#xe9;');
    });

    test('encodeNonAscii still escapes HTML special chars', () {
      final result = encodeHtml('<é>', encodeNonAscii: true);
      expect(result, '&lt;&#xe9;&gt;');
    });
  });

  group('encodeHtml — edge cases', () {
    test('returns empty string for empty input', () {
      expect(encodeHtml(''), '');
    });

    test('single quote is not escaped in attribute mode', () {
      // HtmlEscapeMode.attribute escapes &, <, >, " but leaves single quotes
      expect(encodeHtml("it's"), "it's");
    });

    test('encodeNonAscii encodes emoji by codepoint', () {
      // 😀 is U+1F600 → &#x1f600;
      final result = encodeHtml('😀', encodeNonAscii: true);
      expect(result, '&#x1f600;');
    });

    test('encodeNonAscii: false leaves multi-byte chars intact', () {
      expect(encodeHtml('café'), 'café');
    });
  });

  group('decodeHtml', () {
    test('decodes named entities', () {
      expect(decodeHtml('&lt;div&gt;'), '<div>');
      expect(decodeHtml('&amp;'), '&');
      expect(decodeHtml('&quot;'), '"');
    });

    test('decodes numeric decimal entities', () {
      expect(decodeHtml('&#233;'), 'é');
    });

    test('decodes numeric hex entities', () {
      expect(decodeHtml('&#xe9;'), 'é');
    });

    test('round-trips encode → decode', () {
      const input = '<script>alert("xss & fun")</script>';
      expect(decodeHtml(encodeHtml(input)), input);
    });
  });
}
