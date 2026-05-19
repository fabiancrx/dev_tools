import 'dart:convert';

Map<String, dynamic> parseQueryString(String input) {
  final cleaned = input.trim();
  if (cleaned.isEmpty) return {};
  final withoutLeadingQ = cleaned.startsWith('?') ? cleaned.substring(1) : cleaned;
  // Extract query part if a full URL was pasted
  final queryPart = withoutLeadingQ.contains('?') ? withoutLeadingQ.split('?').last : withoutLeadingQ;
  return Map.fromEntries(Uri.splitQueryString(queryPart).entries);
}

String queryStringToJson(String input) {
  try {
    final map = parseQueryString(input);
    if (map.isEmpty) return '';
    return const JsonEncoder.withIndent('  ').convert(map);
  } catch (_) {
    return '';
  }
}
