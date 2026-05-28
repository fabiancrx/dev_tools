import 'package:flutter_test/flutter_test.dart';

import 'tool_scaffold_robot.dart';

class Base64Robot {
  const Base64Robot(this.tester);
  final WidgetTester tester;

  ToolScaffoldRobot get scaffold => ToolScaffoldRobot(tester);

  Future<void> selectEncodeMode() async {
    await tester.tap(find.text('Encode'));
    await tester.pump();
  }

  Future<void> selectDecodeMode() async {
    await tester.tap(find.text('Decode'));
    await tester.pump();
  }
}
