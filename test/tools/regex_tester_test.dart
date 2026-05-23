import 'package:dash_tools/tools/regex_tester/regex_tester.dart';
import 'package:dash_tools/tools/regex_tester/regex_tester_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('runRegex', () {
    test('returns empty result for empty pattern', () {
      final result = runRegex('', 'hello');
      expect(result.matches, isEmpty);
      expect(result.error, isNull);
    });

    test('finds simple matches', () {
      final result = runRegex(r'\d+', 'abc 123 def 456');
      expect(result.matches.length, 2);
      expect(result.matches[0].full, '123');
      expect(result.matches[1].full, '456');
    });

    test('captures groups', () {
      final result = runRegex(r'(\w+)@(\w+)', 'user@example');
      expect(result.matches.length, 1);
      expect(result.matches[0].groups, ['user', 'example']);
    });

    test('respects caseSensitive flag', () {
      final sensitive = runRegex('hello', 'Hello world', caseSensitive: true);
      expect(sensitive.matches, isEmpty);

      final insensitive = runRegex('hello', 'Hello world', caseSensitive: false);
      expect(insensitive.matches.length, 1);
    });

    test('respects multiLine flag', () {
      final singleLine = runRegex(r'^bar', 'foo\nbar', multiLine: false);
      expect(singleLine.matches, isEmpty);

      final multiLine = runRegex(r'^bar', 'foo\nbar', multiLine: true);
      expect(multiLine.matches.length, 1);
    });

    test('respects dotAll flag', () {
      final noDotAll = runRegex(r'a.b', 'a\nb', dotAll: false);
      expect(noDotAll.matches, isEmpty);

      final dotAll = runRegex(r'a.b', 'a\nb', dotAll: true);
      expect(dotAll.matches.length, 1);
    });

    test('returns error for invalid pattern', () {
      final result = runRegex(r'[invalid', 'test');
      expect(result.error, isNotNull);
      expect(result.matches, isEmpty);
    });

    test('reports start and end positions', () {
      final result = runRegex('foo', 'barfoobaz');
      expect(result.matches[0].start, 3);
      expect(result.matches[0].end, 6);
    });

    test('does not crash on any flag combination', () {
      const pattern = r'\w+';
      const input = 'hello\nworld';
      for (final cs in [true, false])
        for (final ml in [true, false]) {
          for (final da in [true, false]) {
            for (final uc in [true, false]) {
              final r = runRegex(pattern, input, caseSensitive: cs, multiLine: ml, dotAll: da, unicode: uc);
              expect(r.error, isNull);
            }
        }
          }
    });
  });

  group('RegexTesterScreen', () {
    Widget wrap() => const MaterialApp(home: RegexTesterScreen());

    testWidgets('shows match count after entering pattern and input', (tester) async {
      await tester.pumpWidget(wrap());

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), r'\w+');
      await tester.pump();
      await tester.enterText(fields.at(1), 'hello world');
      await tester.pump();

      expect(find.text('2 matches'), findsOneWidget);
    });

    testWidgets('toggling multiline chip updates matches without crashing', (tester) async {
      await tester.pumpWidget(wrap());

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), r'^hello');
      await tester.pump();
      await tester.enterText(fields.at(1), 'hello\nworld\nhello again');
      await tester.pump();

      expect(find.text('1 match'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilterChip, 'Multiline'));
      await tester.pump();

      expect(find.text('2 matches'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilterChip, 'Multiline'));
      await tester.pump();

      expect(find.text('1 match'), findsOneWidget);
    });

    testWidgets('cycling all flag chips does not crash', (tester) async {
      await tester.pumpWidget(wrap());

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), r'hello');
      await tester.pump();
      await tester.enterText(fields.at(1), 'Hello\nhello');
      await tester.pump();

      const chips = ['Case sensitive', 'Multiline', 'Dot-all', 'Unicode'];
      for (final chip in [...chips, ...chips]) {
        await tester.tap(find.widgetWithText(FilterChip, chip));
        await tester.pump();
      }

      expect(find.byType(RegexTesterScreen), findsOneWidget);
    });

    testWidgets('invalid pattern shows error state', (tester) async {
      await tester.pumpWidget(wrap());

      await tester.enterText(find.byType(TextField).at(0), r'[invalid');
      await tester.pump();

      expect(find.text('Fix the pattern to see matches'), findsOneWidget);
    });
  });
}
