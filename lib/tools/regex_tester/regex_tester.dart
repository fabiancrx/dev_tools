const _kMaxMatches = 500;

class RegexMatchResult {
  final String full;
  final int start;
  final int end;
  final List<String?> groups;

  const RegexMatchResult({
    required this.full,
    required this.start,
    required this.end,
    required this.groups,
  });
}

class RegexResult {
  final List<RegexMatchResult> matches;
  final String? error;
  final bool capped;

  const RegexResult({required this.matches, this.error, this.capped = false});

  static const empty = RegexResult(matches: []);
}

RegexResult runRegex(
  String pattern,
  String input, {
  bool caseSensitive = true,
  bool multiLine = false,
  bool dotAll = false,
  bool unicode = false,
}) {
  if (pattern.isEmpty) return RegexResult.empty;
  try {
    final re = RegExp(
      pattern,
      caseSensitive: caseSensitive,
      multiLine: multiLine,
      dotAll: dotAll,
      unicode: unicode,
    );
    final all = re.allMatches(input);
    final taken = all.take(_kMaxMatches + 1).toList();
    final capped = taken.length > _kMaxMatches;
    final matches = taken.take(_kMaxMatches).map((m) {
      return RegexMatchResult(
        full: m.group(0) ?? '',
        start: m.start,
        end: m.end,
        groups: [for (int i = 1; i <= m.groupCount; i++) m.group(i)],
      );
    }).toList();
    return RegexResult(matches: matches, capped: capped);
  } on FormatException catch (e) {
    return RegexResult(matches: [], error: e.message);
  }
}
