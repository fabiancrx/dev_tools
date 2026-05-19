class TimestampConversion {
  final int seconds;
  final int milliseconds;
  final String iso8601Utc;
  final String iso8601Local;
  final String relativeDisplay;

  const TimestampConversion({
    required this.seconds,
    required this.milliseconds,
    required this.iso8601Utc,
    required this.iso8601Local,
    required this.relativeDisplay,
  });
}

TimestampConversion fromSeconds(int seconds) {
  final dt = DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true);
  return TimestampConversion(
    seconds: seconds,
    milliseconds: seconds * 1000,
    iso8601Utc: dt.toIso8601String(),
    iso8601Local: dt.toLocal().toIso8601String(),
    relativeDisplay: _relativeTime(dt),
  );
}

TimestampConversion fromMilliseconds(int ms) {
  final dt = DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
  return TimestampConversion(
    seconds: ms ~/ 1000,
    milliseconds: ms,
    iso8601Utc: dt.toIso8601String(),
    iso8601Local: dt.toLocal().toIso8601String(),
    relativeDisplay: _relativeTime(dt),
  );
}

TimestampConversion? fromIso8601(String iso) {
  try {
    final dt = DateTime.parse(iso).toUtc();
    final ms = dt.millisecondsSinceEpoch;
    return TimestampConversion(
      seconds: ms ~/ 1000,
      milliseconds: ms,
      iso8601Utc: dt.toIso8601String(),
      iso8601Local: dt.toLocal().toIso8601String(),
      relativeDisplay: _relativeTime(dt),
    );
  } catch (_) {
    return null;
  }
}

TimestampConversion now() => fromMilliseconds(DateTime.now().millisecondsSinceEpoch);

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
