import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:json_path/json_path.dart';

final jsonControllerProvider = NotifierProvider(JsonPageController.new);

class JsonPageState with EquatableMixin {
  final JsonMode mode;
  final bool autoProcess;

  const JsonPageState({required this.mode, this.autoProcess = true});

  factory JsonPageState.initial() =>
      const JsonPageState(mode: JsonMode.twoSpaces);

  @override
  String toString() {
    return 'JsonPageState{mode: $mode, autoProcess: $autoProcess}';
  }

  @override
  List<Object?> get props => [mode, autoProcess];
}

class JsonPageController extends Notifier<JsonPageState> {
  final JsonDecoder _decoder = const JsonDecoder();

  /// Paste a sample json text in the input field
  String get sample => kSampleJson;

  String processSync(String raw) {
    final json = _decoder.convert(raw);
    return JsonEncoder.withIndent(state.mode.indent).convert(json);
  }

  /// Runs [expression] against [rawJson] and returns the matched values as
  /// formatted JSON. Throws on invalid JSON or invalid expression.
  String queryJson(String rawJson, String expression) {
    final decoded = jsonDecode(rawJson);
    final results = JsonPath(expression).read(decoded).map((m) => m.value).toList();
    final encoder = JsonEncoder.withIndent(state.mode.indent);
    return results.length == 1 ? encoder.convert(results.first) : encoder.convert(results);
  }

  /// Change the processing mode
  void changeMode(JsonMode? mode) {
    if (mode == null) return;
    state = JsonPageState(mode: mode);
  }

  @override
  JsonPageState build({JsonPageState? state}) {
    return state ?? JsonPageState.initial();
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
