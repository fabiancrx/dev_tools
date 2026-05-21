import 'package:json2yaml/json2yaml.dart';
import 'package:yaml/yaml.dart';

String formatYaml(String input) {
  final parsed = loadYaml(input);
  return json2yaml(_deepConvert(parsed)).trimRight();
}

dynamic _deepConvert(dynamic node) => switch (node) {
      YamlMap() => {for (final e in node.entries) e.key.toString(): _deepConvert(e.value)},
      YamlList() => [for (final e in node) _deepConvert(e)],
      _ => node,
    };

const kSampleYaml = '''name:   John Doe
age:   30
address:  {street: "123 Main St",city: Anytown, zip: "10001"}
hobbies: [reading, coding, hiking]
active: true''';
