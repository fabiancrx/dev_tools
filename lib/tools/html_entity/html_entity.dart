import 'dart:convert';

import 'package:html_unescape/html_unescape.dart';

// attribute mode escapes &, <, >, " — the most useful set for a developer tool
const _kEscape = HtmlEscape(HtmlEscapeMode.attribute);
final _kUnescape = HtmlUnescape();

String encodeHtml(String input, {bool encodeNonAscii = false}) {
  if (!encodeNonAscii) return _kEscape.convert(input);
  final buf = StringBuffer();
  for (final rune in input.runes) {
    if (rune > 127) {
      buf.write('&#x${rune.toRadixString(16)};');
    } else {
      buf.write(_kEscape.convert(String.fromCharCode(rune)));
    }
  }
  return buf.toString();
}

String decodeHtml(String input) => _kUnescape.convert(input);
