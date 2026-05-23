import 'dart:convert';

import 'package:dash_tools/tools/html_entity/html_entity.dart';

/// One-shot transforms used by the tray's Quick Action and Instant Replace.
/// Each function picks the most likely direction (encode vs decode, etc.)
/// from the input shape. Returns null when nothing sensible can be done.

String? base64Quick(String input) {
  final trimmed = input.trim();
  if (trimmed.length % 4 == 0 && RegExp(r'^[A-Za-z0-9+/=]+$').hasMatch(trimmed)) {
    try {
      return utf8.decode(base64.decode(trimmed));
    } catch (_) {}
  }
  return base64.encode(utf8.encode(input));
}

String? urlQuick(String input) {
  if (RegExp(r'%[0-9A-Fa-f]{2}').hasMatch(input)) {
    try {
      return Uri.decodeFull(input);
    } catch (_) {
      return null;
    }
  }
  return Uri.encodeFull(input);
}

String? jsonFormatQuick(String input) {
  try {
    final decoded = jsonDecode(input);
    return const JsonEncoder.withIndent('  ').convert(decoded);
  } catch (_) {
    return null;
  }
}

String? htmlEntityQuick(String input) {
  if (RegExp(r'&(?:#\d+|#x[0-9a-fA-F]+|[a-zA-Z][a-zA-Z0-9]*);').hasMatch(input)) {
    return decodeHtml(input);
  }
  return encodeHtml(input);
}

String? hexAsciiQuick(String input) {
  final cleaned = input.replaceAll(RegExp(r'\s+'), '');
  if (cleaned.isNotEmpty && cleaned.length % 2 == 0 && RegExp(r'^[0-9a-fA-F]+$').hasMatch(cleaned)) {
    try {
      final bytes = <int>[
        for (int i = 0; i < cleaned.length; i += 2)
          int.parse(cleaned.substring(i, i + 2), radix: 16),
      ];
      return utf8.decode(bytes);
    } catch (_) {
      return null;
    }
  }
  return input.codeUnits.map((c) => c.toRadixString(16).padLeft(2, '0')).join(' ');
}

String? jwtQuick(String input) {
  final parts = input.trim().split('.');
  if (parts.length != 3) return null;
  try {
    final header = _b64UrlDecode(parts[0]);
    final payload = _b64UrlDecode(parts[1]);
    return '$header\n.\n$payload';
  } catch (_) {
    return null;
  }
}

String _b64UrlDecode(String input) {
  var padded = input.replaceAll('-', '+').replaceAll('_', '/');
  while (padded.length % 4 != 0) {
    padded += '=';
  }
  final bytes = base64.decode(padded);
  final text = utf8.decode(bytes);
  try {
    final json = jsonDecode(text);
    return const JsonEncoder.withIndent('  ').convert(json);
  } catch (_) {
    return text;
  }
}
