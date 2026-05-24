import 'package:dash_tools/tools/string_inspector/string_inspector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('inspectString', () {
    test('returns all zeros for empty input', () {
      final s = inspectString('');
      expect(s.charCount, 0);
      expect(s.wordCount, 0);
      expect(s.lineCount, 0);
    });

    test('counts characters correctly', () {
      final s = inspectString('hello');
      expect(s.charCount, 5);
    });

    test('excludes spaces from charCountNoSpaces', () {
      final s = inspectString('hi there');
      expect(s.charCount, 8);
      expect(s.charCountNoSpaces, 7);
    });

    test('counts words', () {
      expect(inspectString('one two three').wordCount, 3);
      expect(inspectString('  spaced  ').wordCount, 1);
    });

    test('counts lines', () {
      expect(inspectString('a\nb\nc').lineCount, 3);
      expect(inspectString('single').lineCount, 1);
    });

    test('counts sentences via terminal punctuation', () {
      expect(inspectString('Hello! How are you? Fine.').sentenceCount, 3);
    });

    test('counts UTF-8 bytes for ASCII', () {
      final s = inspectString('abc');
      expect(s.byteCountUtf8, 3);
    });

    test('counts UTF-8 bytes for multi-byte chars', () {
      // '€' is 3 bytes in UTF-8
      final s = inspectString('€');
      expect(s.byteCountUtf8, 3);
      expect(s.charCount, 1);
    });

    test('counts unique characters', () {
      expect(inspectString('aabbcc').uniqueCharCount, 3);
      expect(inspectString('abc').uniqueCharCount, 3);
    });

    test('counts paragraphs separated by blank lines', () {
      const text = 'Para one.\n\nPara two.\n\nPara three.';
      expect(inspectString(text).paragraphCount, 3);
    });

    test('single paragraph with no blank lines', () {
      expect(inspectString('just one paragraph').paragraphCount, 1);
    });

    test('tab counts as whitespace, not a word', () {
      // 'hello\tworld' is 2 words
      expect(inspectString('hello\tworld').wordCount, 2);
    });

    test('multiple consecutive spaces count as one separator', () {
      expect(inspectString('a   b   c').wordCount, 3);
    });

    test('emoji counts as one character', () {
      final s = inspectString('😀');
      expect(s.charCount, 1);
    });

    test('emoji uses more bytes than char count', () {
      final s = inspectString('😀');
      expect(s.byteCountUtf8, greaterThan(s.charCount));
    });
  });
}
