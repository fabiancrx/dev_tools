import 'package:flutter_test/flutter_test.dart';

import 'tool_scaffold_robot.dart';

class UrlEncoderRobot {
  const UrlEncoderRobot(this.tester);
  final WidgetTester tester;

  ToolScaffoldRobot get scaffold => ToolScaffoldRobot(tester);

  Future<void> selectEncodeMode() async {
    await tester.tap(find.text('Encode'));
    await tester.pumpAndSettle();
  }

  Future<void> selectDecodeMode() async {
    await tester.tap(find.text('Decode'));
    await tester.pumpAndSettle();
  }

  void verifyModeButtonsVisible() {
    expect(find.text('Encode'), findsWidgets);
    expect(find.text('Decode'), findsWidgets);
  }
}
