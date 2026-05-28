import 'package:dash_tools/common/app_settings.dart';
import 'package:dash_tools/tools/url_encoder/url_encoder_screen.dart';
import 'package:dash_tools/widgets/tool_scaffold.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../robots/url_encoder_robot.dart';

void main() {
  setUp(setUpTestEnv);

  group('URL Encoder — encode flow', () {
    testWidgets('encodes input automatically when autoRun is on', (tester) async {
      setUpView(tester);
      await AppSettings.instance.setAutoRun(true);
      await tester.pumpWidget(testApp(const UrlEncoderScreen()));
      await tester.pumpAndSettle();

      final robot = UrlEncoderRobot(tester);
      await robot.scaffold.enterInput('hello world');
      await tester.pump();

      await robot.scaffold.verifyOutputContains('hello%20world');
    });

    testWidgets('encodes on Run tap when autoRun is off', (tester) async {
      setUpView(tester);
      await AppSettings.instance.setAutoRun(false);
      await tester.pumpWidget(testApp(const UrlEncoderScreen()));
      await tester.pumpAndSettle();

      final robot = UrlEncoderRobot(tester);
      await robot.scaffold.verifyRunButtonVisible();
      await robot.scaffold.enterInput('a=1&b=2');
      await robot.scaffold.tapRun();

      await robot.scaffold.verifyOutputContains('a%3D1%26b%3D2');
    });
  });

  group('URL Encoder — decode flow', () {
    testWidgets('decodes percent-encoded input', (tester) async {
      setUpView(tester);
      await AppSettings.instance.setAutoRun(true);
      await tester.pumpWidget(testApp(const UrlEncoderScreen()));
      await tester.pumpAndSettle();

      final robot = UrlEncoderRobot(tester);
      await robot.selectDecodeMode();
      await robot.scaffold.enterInput('hello%20world');
      await tester.pump();

      await robot.scaffold.verifyOutputContains('hello world');
    });
  });

  group('URL Encoder — UI', () {
    testWidgets('input and output panes are present', (tester) async {
      setUpView(tester);
      await tester.pumpWidget(testApp(const UrlEncoderScreen()));
      await tester.pumpAndSettle();

      expect(find.byKey(ToolScaffold.inputKey), findsOneWidget);
      expect(find.byKey(ToolScaffold.outputKey), findsOneWidget);
    });

    testWidgets('Encode and Decode mode buttons are visible', (tester) async {
      setUpView(tester);
      await tester.pumpWidget(testApp(const UrlEncoderScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Encode'), findsWidgets);
      expect(find.text('Decode'), findsWidgets);
    });
  });
}
