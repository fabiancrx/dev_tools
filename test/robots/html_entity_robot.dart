import 'package:flutter_test/flutter_test.dart';

import 'tool_scaffold_robot.dart';

class HtmlEntityRobot {
  const HtmlEntityRobot(this.tester);
  final WidgetTester tester;

  ToolScaffoldRobot get scaffold => ToolScaffoldRobot(tester);

  Future<void> selectEncodeMode() async {
    await tester.tap(find.text('Encode').first);
    await tester.pump();
  }

  Future<void> selectDecodeMode() async {
    await tester.tap(find.text('Decode').first);
    await tester.pump();
  }
}
