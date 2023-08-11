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
