import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final jsonControllerProvider = StateNotifierProvider<JsonPageController, JsonPageState>((ref) => JsonPageController());

class JsonPageState with EquatableMixin {
  final JsonMode mode;
  final bool autoProcess;

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
  String get sample => kSampleJson;

  String processSync(String raw) {
    switch (state.mode) {
      case JsonMode.twoSpaces:
      case JsonMode.fourSpaces:
      case JsonMode.tab:
      case JsonMode.minify:
        final json = _decoder.convert(raw);
        final encoder = JsonEncoder.withIndent(state.mode.indent);
        return encoder.convert(json);
    }
  }

  /// Change the processing mode
  void changeMode(JsonMode? mode) {
    if (mode == null) return;
    state = JsonPageState(mode: mode);
  }
}

enum JsonMode {
  minify,
  twoSpaces("  "),
  fourSpaces("    "),
  tab("\t");

  final String? indent;

  const JsonMode([this.indent]);
}

const kSampleJson = r'''{
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
