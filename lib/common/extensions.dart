extension ListUtils<T> on List<T> {
  List<T> interleave(T separator) => [
    for (var i = 0; i < length; i++) ...[
      this[i],
      if (i < length - 1) separator,
    ],
  ];
}

extension ExtensionNum on num {
  String get twoDigits => toString().padLeft(2, "0");
}

extension ExtensionDuration on Duration {
  String get humanize =>
      "${inDays > 0 ? '${inDays}d ' : ''}${inHours.remainder(24).twoDigits}h:${inMinutes.remainder(60).twoDigits}m:${inSeconds.remainder(60).twoDigits}s";
}