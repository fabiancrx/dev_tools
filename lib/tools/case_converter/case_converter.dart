import 'package:recase/recase.dart';

enum CaseStyle {
  camel,
  pascal,
  snake,
  constant,
  kebab,
  dot,
  path,
  sentence,
  title,
}

extension CaseStyleX on CaseStyle {
  String get label => switch (this) {
        CaseStyle.camel => 'camelCase',
        CaseStyle.pascal => 'PascalCase',
        CaseStyle.snake => 'snake_case',
        CaseStyle.constant => 'CONSTANT_CASE',
        CaseStyle.kebab => 'kebab-case',
        CaseStyle.dot => 'dot.case',
        CaseStyle.path => 'path/case',
        CaseStyle.sentence => 'Sentence case',
        CaseStyle.title => 'Title Case',
      };

  String convert(String input) {
    if (input.isEmpty) return '';
    final rc = ReCase(input);
    return switch (this) {
      CaseStyle.camel => rc.camelCase,
      CaseStyle.pascal => rc.pascalCase,
      CaseStyle.snake => rc.snakeCase,
      CaseStyle.constant => rc.constantCase,
      CaseStyle.kebab => rc.paramCase,
      CaseStyle.dot => rc.dotCase,
      CaseStyle.path => rc.pathCase,
      CaseStyle.sentence => rc.sentenceCase,
      CaseStyle.title => rc.titleCase,
    };
  }
}

Map<CaseStyle, String> convertAllCases(String input) {
  if (input.isEmpty) return {for (final s in CaseStyle.values) s: ''};
  final rc = ReCase(input);
  return {
    CaseStyle.camel: rc.camelCase,
    CaseStyle.pascal: rc.pascalCase,
    CaseStyle.snake: rc.snakeCase,
    CaseStyle.constant: rc.constantCase,
    CaseStyle.kebab: rc.paramCase,
    CaseStyle.dot: rc.dotCase,
    CaseStyle.path: rc.pathCase,
    CaseStyle.sentence: rc.sentenceCase,
    CaseStyle.title: rc.titleCase,
  };
}
