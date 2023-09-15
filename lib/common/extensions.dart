extension ListUtils<T> on List<T> {
  List<T> interleave(T element) {
    return _interleave(this, element).toList();
  }

  Iterable<T> _interleave<T>(List<T> list, T element) sync* {
    for (var i = 0; i < list.length; i++) {
      yield list[i];
      if (i != list.length - 1) {
        yield element;
      }
    }
  }
}

extension ExtensionNum on num {
  String get twoDigits => toString().padLeft(2, "0");
}

extension ExtensionDuration on Duration {
  String get humanize =>
      "${inDays > 0 ? '${inDays}d ' : ''}${inHours.remainder(24).twoDigits}h:${inMinutes.remainder(60).twoDigits}m:${inSeconds.remainder(60).twoDigits}s";
}