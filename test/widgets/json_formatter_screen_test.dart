import 'package:dash_tools/tools/json/json_formatter_screen.dart';
import 'package:dash_tools/tools/json/json_screen_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../robots/json_formatter_robot.dart';

// CodeForge editor runs a cursor-blink animation that never settles.
// Use pump(duration) instead of pumpAndSettle throughout this file.
Future<void> _pumpJsonFormatter(WidgetTester tester) async {
  await tester.pumpWidget(
    testApp(const JsonFormatterScreen(key: ValueKey('json_formatter')), withRiverpod: true),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  setUp(setUpTestEnv);

  group('JSON Formatter — initial state', () {
    testWidgets('Format button and mode dropdown are present', (tester) async {
      setUpView(tester);
      await _pumpJsonFormatter(tester);

      final robot = JsonFormatterRobot(tester);
      await robot.verifyFormatButtonVisible();
      await robot.verifyModeSelected(JsonMode.twoSpaces);
    });
  });

  group('JSON Formatter — mode selection', () {
    testWidgets('switching to Minify updates the dropdown', (tester) async {
      setUpView(tester);
      await _pumpJsonFormatter(tester);

      final robot = JsonFormatterRobot(tester);
      await robot.selectMode('Minify');
      await robot.verifyModeSelected(JsonMode.minify);
    });

    testWidgets('switching to 4 Spaces updates the dropdown', (tester) async {
      setUpView(tester);
      await _pumpJsonFormatter(tester);

      final robot = JsonFormatterRobot(tester);
      await robot.selectMode('4 Spaces');
      await robot.verifyModeSelected(JsonMode.fourSpaces);
    });
  });

  group('JSON Formatter — actions', () {
    testWidgets('tapping Format does not throw', (tester) async {
      setUpView(tester);
      await _pumpJsonFormatter(tester);

      final robot = JsonFormatterRobot(tester);
      await robot.tapFormat();
    });

    testWidgets('tapping Clear does not throw', (tester) async {
      setUpView(tester);
      await _pumpJsonFormatter(tester);

      final robot = JsonFormatterRobot(tester);
      await robot.tapClear();
    });
  });
}
