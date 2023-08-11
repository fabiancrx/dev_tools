import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final jsonControllerProvider = StateNotifierProvider<JsonPageController, JsonPageState>((ref) {
  return JsonPageController();
});

class JsonPageState with EquatableMixin {
  final JsonMode mode;
  final bool autoProcess;
// final String jsonPath;

  const JsonPageState({required this.mode, this.autoProcess = true});

  factory JsonPageState.initial() => const JsonPageState(mode: JsonMode.twoSpaces);

  @override
  String toString() {
    return 'JsonPageState{mode: $mode, autoProcess: $autoProcess}';
  }

  @override
  List<Object?> get props => [mode, autoProcess];
}

class JsonPageController extends StateNotifier<JsonPageState> {
  JsonPageController({JsonPageState? state}) : super(state ?? JsonPageState.initial());

  final JsonDecoder _decoder = const JsonDecoder();

  /// Paste a sample json text in the input field
  String get sample => _kSampleJson;

  String processSync(String raw) {
    switch (state.mode) {
      case JsonMode.twoSpaces:
      case JsonMode.fourSpaces:
      case JsonMode.tab:
      case JsonMode.minify:
        final json = _decoder.convert(raw);
        final encoder = JsonEncoder.withIndent(state.mode.indent);
        return encoder.convert(json);
      case JsonMode.encode:
        const encoder = JsonEncoder();
        final result = encoder.convert(raw);

        if (result.length > 2 && (result[0] == '"' && result[result.length - 1] == '"')) {
          return result.substring(1, result.length - 2);
        }

        return result;
      case JsonMode.decode:
        return _decoder.convert(unEscapeJson(raw));
    }
  }

  /// Change the processing mode
  void changeMode(JsonMode? mode) {
    if (mode == null) return;
    state = JsonPageState(mode: mode);
  }

  @override
  void dispose() {
    super.dispose();
  }
}

enum JsonMode {
  minify,
  encode,
  decode,
  twoSpaces("  "),
  fourSpaces("    "),
  tab("\t");

  final String? indent;

  const JsonMode([this.indent]);
}

const _kSampleJson = r'''{
    "widget": {
    "debug": "on",
    "window": {
        "title": "Sample Konfabulator Widget",
        "name": "main_window",
        "width": 500,
        "height": 500
    },
    "image": { 
        "src": "Images/Sun.png",
        "name": "sun1",
        "hOffset": 250,
        "vOffset": 250,
        "alignment": "center"
    },
    "text": {
        "data": "Click Here",
        "size": 36,
        "style": "bold",
        "name": "text1",
        "hOffset": 250,
        "vOffset": 100,
        "alignment": "center",
        "onMouseUp": "sun1.opacity = (sun1.opacity / 100) * 90;"
    }
}}    
    ''';
String unEscapeJson(String t) {
  if (t.isEmpty) return t;

  const escapes = [r'\"', r"\\", r"\/"];
  const lb = [
    r"\b",
    r"\f",
    r"\n",
    r"\r",
    r"\t",
    // r"\u",
  ];
  final StringBuffer sb = StringBuffer();

  for (int i = 0; i < t.length; i++) {
    if (i + 1 == t.length) continue;
    if (escapes.contains(t[i] + t[i + 1])) {
      continue;
    } else if (lb.contains(t[i] + t[i + 1])) {
      i++;
      continue;
    } else {
      sb.write(t[i]);
    }
  }
  return sb.toString();
}
