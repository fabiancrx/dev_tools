import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class RegexRobot {
  const RegexRobot(this.tester);
  final WidgetTester tester;

  Finder get _patternField => find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.labelText == 'Regular expression',
      );

  Finder get _testInputField => find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.labelText == 'Test input',
      );

  Future<void> enterPattern(String pattern) async {
    await tester.enterText(_patternField, pattern);
    await tester.pump();
  }

  Future<void> enterTestInput(String input) async {
    await tester.enterText(_testInputField, input);
    await tester.pump();
  }

  Future<void> verifyPatternHasError() async {
    final field = tester.widget<TextField>(_patternField);
    expect(field.decoration?.errorText, isNotNull);
  }

  Future<void> verifyPatternHasNoError() async {
    final field = tester.widget<TextField>(_patternField);
    expect(field.decoration?.errorText, isNull);
  }

  Future<void> verifyMatchCount(String text) async {
    expect(find.text(text), findsOneWidget);
  }

  Future<void> verifyNoMatchesVisible() async {
    expect(find.text('No matches'), findsOneWidget);
  }

  Future<void> verifyErrorHelperVisible() async {
    expect(find.text('Fix the pattern to see matches'), findsOneWidget);
  }
}
