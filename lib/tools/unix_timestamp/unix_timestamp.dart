class TimestampConversion {
  final int seconds;
  final int milliseconds;
  final String iso8601Utc;
  final String iso8601Local;
  final String iso9075;
  final String rfc3339;
  final String rfc7231;
  final String relativeDisplay;

  const TimestampConversion({
    required this.seconds,
    required this.milliseconds,
    required this.iso8601Utc,
    required this.iso8601Local,
    required this.iso9075,
    required this.rfc3339,
    required this.rfc7231,
    required this.relativeDisplay,
  });
}

TimestampConversion fromSeconds(int seconds) {
  final dt = DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true);
  return _build(dt, seconds * 1000);
}

TimestampConversion fromMilliseconds(int ms) {
  final dt = DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
  return _build(dt, ms);
}

TimestampConversion? fromIso8601(String iso) {
  try {
    final dt = DateTime.parse(iso).toUtc();
    return _build(dt, dt.millisecondsSinceEpoch);
  } catch (_) {
    return null;
  }
}

TimestampConversion _build(DateTime dt, int ms) => TimestampConversion(
      seconds: ms ~/ 1000,
      milliseconds: ms,
      iso8601Utc: dt.toIso8601String(),
      iso8601Local: dt.toLocal().toIso8601String(),
      iso9075: _formatIso9075(dt),
      rfc3339: _formatRfc3339(dt),
      rfc7231: _formatRfc7231(dt),
      relativeDisplay: _relativeTime(dt),
    );

TimestampConversion now() => fromMilliseconds(DateTime.now().millisecondsSinceEpoch);

// ISO 9075 — SQL datetime: "YYYY-MM-DD HH:MM:SS"
String _formatIso9075(DateTime dt) {
  final d = dt.toUtc();
  final date = '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
  final time = '${d.hour.toString().padLeft(2, '0')}:'
      '${d.minute.toString().padLeft(2, '0')}:'
      '${d.second.toString().padLeft(2, '0')}';
  return '$date $time';
}

// RFC 3339 — like ISO 8601 but explicit +00:00 offset, no milliseconds
String _formatRfc3339(DateTime dt) {
  final iso = dt.toUtc().toIso8601String(); // …T…Z or …T….000Z
  final noMs = iso.contains('.') ? iso.substring(0, iso.indexOf('.')) : iso.replaceAll('Z', '');
  return '$noMs+00:00';
}

// RFC 7231 — HTTP date: "Mon, 15 Jan 2024 13:45:00 GMT"
const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

String _formatRfc7231(DateTime dt) {
  final d = dt.toUtc();
  return '${_weekdays[d.weekday - 1]}, '
      '${d.day.toString().padLeft(2, '0')} '
      '${_months[d.month - 1]} '
      '${d.year} '
      '${d.hour.toString().padLeft(2, '0')}:'
      '${d.minute.toString().padLeft(2, '0')}:'
      '${d.second.toString().padLeft(2, '0')} GMT';
}

String _relativeTime(DateTime dt) {
  final diff = DateTime.now().toUtc().difference(dt);
  final abs = diff.abs();
  final suffix = diff.isNegative ? 'from now' : 'ago';
  if (abs.inSeconds < 60) return '${abs.inSeconds}s $suffix';
  if (abs.inMinutes < 60) return '${abs.inMinutes}m $suffix';
  if (abs.inHours < 24) return '${abs.inHours}h $suffix';
  if (abs.inDays < 30) return '${abs.inDays}d $suffix';
  if (abs.inDays < 365) return '${abs.inDays ~/ 30}mo $suffix';
  return '${abs.inDays ~/ 365}y $suffix';
}
