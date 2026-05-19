import 'dart:convert';

class StringStats {
  final int charCount;
  final int charCountNoSpaces;
  final int byteCountUtf8;
  final int wordCount;
  final int lineCount;
  final int sentenceCount;
  final int uniqueCharCount;
  final int paragraphCount;

  const StringStats({
    required this.charCount,
    required this.charCountNoSpaces,
    required this.byteCountUtf8,
    required this.wordCount,
    required this.lineCount,
    required this.sentenceCount,
    required this.uniqueCharCount,
    required this.paragraphCount,
  });

  static const empty = StringStats(
    charCount: 0,
    charCountNoSpaces: 0,
    byteCountUtf8: 0,
    wordCount: 0,
    lineCount: 0,
    sentenceCount: 0,
    uniqueCharCount: 0,
    paragraphCount: 0,
  );
}

StringStats inspectString(String input) {
  if (input.isEmpty) return StringStats.empty;

  final chars = input.runes.length;
  final charsNoSpaces = input.replaceAll(RegExp(r'\s'), '').runes.length;
  final bytes = utf8.encode(input).length;
  final words = input.trim().isEmpty ? 0 : input.trim().split(RegExp(r'\s+')).length;
  final lines = input.split('\n').length;
  final sentences = RegExp(r'[.!?]+').allMatches(input).length;
  final uniqueChars = input.runes.toSet().length;
  final paragraphs = input.split(RegExp(r'\n\s*\n')).where((p) => p.trim().isNotEmpty).length;

  return StringStats(
    charCount: chars,
    charCountNoSpaces: charsNoSpaces,
    byteCountUtf8: bytes,
    wordCount: words,
    lineCount: lines,
    sentenceCount: sentences,
    uniqueCharCount: uniqueChars,
    paragraphCount: paragraphs == 0 ? 1 : paragraphs,
  );
}
