import 'package:flutter_test/flutter_test.dart';

import 'tool_scaffold_robot.dart';

class UrlEncoderRobot {
  const UrlEncoderRobot(this.tester);
  final WidgetTester tester;

  ToolScaffoldRobot get scaffold => ToolScaffoldRobot(tester);

  // Fixed pump: pumpAndSettle hangs in the nav pane context (cursor tickers).
  Future<void> selectEncodeMode() async {
    await tester.tap(find.text('Encode'));
    await tester.pump(const Duration(milliseconds: 100));
  }

  Future<void> selectDecodeMode() async {
    await tester.tap(find.text('Decode'));
    await tester.pump(const Duration(milliseconds: 100));
  }

  void verifyModeButtonsVisible() {
    expect(find.text('Encode'), findsWidgets);
    expect(find.text('Decode'), findsWidgets);
  }
}
