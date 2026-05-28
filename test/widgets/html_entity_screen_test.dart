import 'package:dash_tools/common/app_settings.dart';
import 'package:dash_tools/tools/html_entity/html_entity_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../robots/html_entity_robot.dart';

void main() {
  setUp(setUpTestEnv);

  group('HTML entity — round-trip', () {
    testWidgets('encode <p> → &lt;p&gt; then decode back to <p>', (tester) async {
      setUpView(tester);
      // HtmlEntityController.setInput only auto-processes when autoRun is true.
      await AppSettings.instance.setAutoRun(true);
      await tester.pumpWidget(testApp(const HtmlEntityScreen()));
      await tester.pumpAndSettle();

      final robot = HtmlEntityRobot(tester);

      await robot.scaffold.enterInput('<p>');
      await robot.scaffold.verifyOutputContains('&lt;p&gt;');

      await robot.selectDecodeMode();
      await robot.scaffold.enterInput('&lt;p&gt;');
      await robot.scaffold.verifyOutputContains('<p>');
    });
  });
}
