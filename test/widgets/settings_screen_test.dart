import 'package:dash_tools/app/reorder_screen.dart';
import 'package:dash_tools/common/tool_order.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../robots/settings_robot.dart';

Future<void> _pumpSettings(WidgetTester tester) async {
  final notifier = await ToolOrderNotifier.load();
  await tester.pumpWidget(testApp(ReorderScreen(notifier: notifier)));
  await tester.pumpAndSettle();
}

void main() {
  setUp(setUpTestEnv);

  group('Settings — initial state', () {
    testWidgets('autoRun is on by default', (tester) async {
      setUpView(tester);
      await _pumpSettings(tester);
      await SettingsRobot(tester).verifyAutoRun(true);
    });

    testWidgets('compact mode is off by default', (tester) async {
      setUpView(tester);
      await _pumpSettings(tester);
      await SettingsRobot(tester).verifyCompactMode(false);
    });
  });

  group('Settings — toggles', () {
    testWidgets('turning off Process as you type disables autoRun', (tester) async {
      setUpView(tester);
      await _pumpSettings(tester);

      final robot = SettingsRobot(tester);
      await robot.verifyAutoRun(true);
      await robot.tapAutoRunToggle();
      await robot.verifyAutoRun(false);
    });

    testWidgets('turning on Compact mode enables compactMode', (tester) async {
      setUpView(tester);
      await _pumpSettings(tester);

      final robot = SettingsRobot(tester);
      await robot.verifyCompactMode(false);
      await robot.tapCompactModeToggle();
      await robot.verifyCompactMode(true);
    });
  });

  group('Settings — license page', () {
    testWidgets('tapping Licenses opens the license page', (tester) async {
      setUpView(tester);
      await _pumpSettings(tester);

      final robot = SettingsRobot(tester);
      await robot.tapLicenses();
      await robot.verifyLicensePageVisible();
    });
  });
}
