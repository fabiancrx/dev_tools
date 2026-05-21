import 'dart:convert';

import 'package:json2yaml/json2yaml.dart';
import 'package:yaml/yaml.dart';

enum JsonYamlMode { jsonToYaml, yamlToJson }

String convertJsonToYaml(String input) {
  final decoded = jsonDecode(input);
  return json2yaml(decoded).trimRight();
}

String convertYamlToJson(String input, {String? indent = '  '}) {
  final parsed = loadYaml(input);
  final plain = _deepConvert(parsed);
  return JsonEncoder.withIndent(indent).convert(plain);
}

dynamic _deepConvert(dynamic node) => switch (node) {
      YamlMap() => {for (final e in node.entries) e.key.toString(): _deepConvert(e.value)},
      YamlList() => [for (final e in node) _deepConvert(e)],
      _ => node,
    };
