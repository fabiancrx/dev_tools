import "package:flutter/foundation.dart";



class JsonPageState {
  final JsonMode mode;
  final String indent;

// final String jsonPath;

  JsonPageState(this.mode, this.indent);

  factory JsonPageState.initial() => JsonPageState(JsonMode.prettify, "  ");
}

class JsonPageController extends ValueNotifier<JsonPageState> {
  JsonPageController(super.value);

  /// Pastes the clipboard into the input field
  void pasteFromClipboard() {}

  /// Paste a sample json text in the input field
  void useSample() {}

  /// Clears the input field
  void clear() {}

  /// Copies the processed input into the clipboard
  void copyOutput() {}

  /// Modifies the indentation of the text
  void changeIndent(String newIndent) {}
}

  enum JsonMode {
  prettify,
  minify,
//  convertToYaml
}
