enum UrlEncodeMode { encode, decode }

enum UrlEncodeType { component, full }

String encodeUrl(String input, UrlEncodeType type) {
  if (input.isEmpty) return '';
  return switch (type) {
    UrlEncodeType.component => Uri.encodeComponent(input),
    UrlEncodeType.full => Uri.encodeFull(input),
  };
}

String decodeUrl(String input, UrlEncodeType type) {
  if (input.isEmpty) return '';
  try {
    return switch (type) {
      UrlEncodeType.component => Uri.decodeComponent(input),
      UrlEncodeType.full => Uri.decodeFull(input),
    };
  } catch (_) {
    return '';
  }
}
