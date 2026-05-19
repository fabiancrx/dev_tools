class CronParseException implements Exception {
  final String message;
  const CronParseException(this.message);
  @override
  String toString() => message;
}

Set<int> _parseField(String field, int min, int max) {
  if (field == '*') return {for (var i = min; i <= max; i++) i};
  final result = <int>{};
  for (final part in field.split(',')) {
    if (part.contains('/')) {
      final stepParts = part.split('/');
      final step = int.tryParse(stepParts[1]);
      if (step == null || step < 1) throw CronParseException('Invalid step in "$part"');
      final range = stepParts[0];
      int start, end;
      if (range == '*') {
        start = min;
        end = max;
      } else if (range.contains('-')) {
        final r = range.split('-');
        start = int.parse(r[0]);
        end = int.parse(r[1]);
      } else {
        start = int.parse(range);
        end = max;
      }
      for (var i = start; i <= end; i += step) {
        result.add(i);
      }
    } else if (part.contains('-')) {
      final r = part.split('-');
      final start = int.parse(r[0]);
      final end = int.parse(r[1]);
      for (var i = start; i <= end; i++) {
        result.add(i);
      }
    } else {
      result.add(int.parse(part));
    }
  }
  if (result.any((v) => v < min || v > max)) {
    throw CronParseException('Value out of range [$min–$max] in "$field"');
  }
  return result;
}

List<DateTime> nextRuns(String expression, {int count = 10}) {
  final parts = expression.trim().split(RegExp(r'\s+'));
  if (parts.length != 5) {
    throw CronParseException('Expected 5 fields, got ${parts.length}');
  }
  final minutes = _parseField(parts[0], 0, 59);
  final hours = _parseField(parts[1], 0, 23);
  final days = _parseField(parts[2], 1, 31);
  final months = _parseField(parts[3], 1, 12);
  // Cron: 0=Sun,1=Mon..6=Sat,7=Sun. Dart: 1=Mon..7=Sun.
  final rawWeekdays = _parseField(parts[4], 0, 7);
  // Normalise 7 (alt Sunday) to 0
  final weekdays = rawWeekdays.map((d) => d == 7 ? 0 : d).toSet();

  final results = <DateTime>[];
  // Start 1 minute in the future, truncated to whole minutes
  var cursor = DateTime.now().add(const Duration(minutes: 1));
  cursor = DateTime(cursor.year, cursor.month, cursor.day, cursor.hour, cursor.minute);

  final limit = cursor.add(const Duration(days: 366 * 4));
  while (results.length < count && cursor.isBefore(limit)) {
    // Dart weekday: Mon=1..Sun=7 → cron: Mon=1..Sat=6,Sun=0
    final cronDow = cursor.weekday % 7;
    if (months.contains(cursor.month) &&
        days.contains(cursor.day) &&
        hours.contains(cursor.hour) &&
        minutes.contains(cursor.minute) &&
        weekdays.contains(cronDow)) {
      results.add(cursor);
    }
    cursor = cursor.add(const Duration(minutes: 1));
  }
  return results;
}

String describeExpression(String expression) {
  final parts = expression.trim().split(RegExp(r'\s+'));
  if (parts.length != 5) return '';
  final min = parts[0];
  final hr = parts[1];
  final dom = parts[2];
  final mon = parts[3];
  final dow = parts[4];

  final timePart = (hr == '*' && min == '*')
      ? 'every minute'
      : hr == '*'
          ? 'at minute $min of every hour'
          : min == '*'
              ? 'every minute of hour $hr'
              : 'at $hr:${min.padLeft(2, '0')}';

  final dayPart = dom == '*' && dow == '*'
      ? 'every day'
      : dom != '*'
          ? 'on day $dom of the month'
          : 'on ${_dowName(dow)}';

  final monthPart = mon == '*' ? '' : 'in ${_monthName(mon)}';

  return [timePart, dayPart, monthPart].where((s) => s.isNotEmpty).join(', ');
}

String _dowName(String field) {
  const names = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  final idx = int.tryParse(field);
  if (idx != null && idx >= 0 && idx <= 6) return names[idx];
  return field;
}

String _monthName(String field) {
  const names = ['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
  final idx = int.tryParse(field);
  if (idx != null && idx >= 1 && idx <= 12) return names[idx];
  return field;
}
