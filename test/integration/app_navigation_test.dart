import 'package:dash_tools/common/clipboard_recognizer.dart';
import 'package:dash_tools/common/tool_order.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../robots/app_robot.dart';
import '../robots/url_encoder_robot.dart';

void main() {
  late ToolOrderNotifier notifier;
  late ClipboardRecognizer recognizer;
  late AppRobot app;

  setUp(() async {
    await setUpTestEnv();
    notifier = await ToolOrderNotifier.load();
    recognizer = ClipboardRecognizer();
  });

  tearDown(() {
    notifier.dispose();
    recognizer.dispose();
  });

  Future<void> pump(WidgetTester tester) async {
    app = AppRobot(tester);
    await app.pumpNavPane(notifier, recognizer);
  }

  group('App — opens correctly', () {
    testWidgets('nav pane renders with search bar and tool list', (tester) async {
      await pump(tester);

      app.verifySearchBarVisible();
      await app.verifyToolVisible('base64_text');
    });

    testWidgets('initial page renders ToolScaffold input and output panes', (tester) async {
      await pump(tester);

      app.verifyCurrentScreenHasScaffold();
    });
  });

  group('App — navigation', () {
    testWidgets('tapping url_encoder nav item shows Encode and Decode buttons', (tester) async {
      await pump(tester);

      await app.navigateTo('url_encoder');

      UrlEncoderRobot(tester).verifyModeButtonsVisible();
    });

    testWidgets('navigating between tools updates the active screen', (tester) async {
      await pump(tester);

      await app.navigateTo('url_encoder');
      app.verifyCurrentScreenHasScaffold();

      await app.navigateTo('base64_text');
      app.verifyCurrentScreenHasScaffold();
      UrlEncoderRobot(tester).verifyModeButtonsVisible(); // base64 also shows Encode/Decode
    });
  });
}
