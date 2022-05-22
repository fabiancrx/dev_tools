import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final jsonProvider = StateProvider<JsonPageController>((ref) {
  return JsonPageController();
});

class JsonPageState {
  final JsonProcessing mode;
  final JsonIndent indent;
  final bool autoProcess;

// final String jsonPath;

  JsonPageState({required this.mode, required this.indent, this.autoProcess = true});

  factory JsonPageState.initial() => JsonPageState(mode: JsonProcessing.prettify, indent: JsonIndent.twoSpaces);
}

class JsonPageController extends StateNotifier<JsonPageState> {
  JsonPageController({JsonPageState? state}) : super(state ?? JsonPageState.initial());

  /// Paste a sample json text in the input field
  String sample() => _kSampleJson;

  String processSync(String json) {
    switch (state.mode) {
      case JsonProcessing.prettify:
        final encoder = JsonEncoder.withIndent(state.indent.indent);
        return encoder.convert(json);
      case JsonProcessing.minify:
        const encoder = JsonEncoder();
        return encoder.convert(json);
      case JsonProcessing.encode:
      case JsonProcessing.decode:
        throw UnimplementedError("${state.mode.name} not implemented yet!!");
    }
  }

  /// Modifies the indentation of the text
  void changeIndent(JsonIndent indent) {
    state = JsonPageState(indent: indent, mode: JsonProcessing.prettify);
  }

  /// Change the processing mode
  void changeMode(JsonProcessing mode) {
    state = JsonPageState(mode: mode, indent: state.indent);
  }

  @override
  void dispose() {
    super.dispose();
  }
}

enum JsonProcessing { prettify, minify, encode, decode }

enum JsonIndent {
  twoSpaces("  "),
  fourSpaces("    "),
  tab("\t");

  final String indent;

  const JsonIndent(this.indent);
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
