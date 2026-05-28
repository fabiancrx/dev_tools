import 'package:dash_tools/widgets/tool_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class ToolScaffoldRobot {
  const ToolScaffoldRobot(this.tester);
  final WidgetTester tester;

  Finder get _inputField => find.descendant(
        of: find.byKey(ToolScaffold.inputKey),
        matching: find.byType(TextField),
      );

  Finder get _outputField => find.descendant(
        of: find.byKey(ToolScaffold.outputKey),
        matching: find.byType(TextField),
      );

  Future<void> enterInput(String text) async {
    await tester.enterText(_inputField, text);
    await tester.pump();
  }

  Future<void> tapRun() async {
    await tester.tap(find.byKey(ToolScaffold.runButtonKey));
    await tester.pumpAndSettle();
  }

  Future<void> verifyOutputContains(String expected) async {
    final field = tester.widget<TextField>(_outputField);
    expect(field.controller?.text ?? '', contains(expected));
  }

  Future<void> verifyOutputEquals(String expected) async {
    final field = tester.widget<TextField>(_outputField);
    expect(field.controller?.text ?? '', equals(expected));
  }

  Future<void> verifyRunButtonVisible() async {
    expect(find.byKey(ToolScaffold.runButtonKey), findsOneWidget);
  }

  Future<void> verifyRunButtonAbsent() async {
    expect(find.byKey(ToolScaffold.runButtonKey), findsNothing);
  }
}
