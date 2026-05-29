import 'package:dash_tools/common/app_settings.dart';
import 'package:dash_tools/common/clipboard_recognizer.dart';
import 'package:dash_tools/common/tool_order.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // ── A: Settings × Tool behavior ──────────────────────────────────────────

  group('A — Settings × Tool behavior', () {
    testWidgets('autoRun toggle shows Run button on the active tool without restart', (tester) async {
      await pump(tester);
      await app.navigateTo('url_encoder');

      // Default: autoRun=true → no Run button
      await UrlEncoderRobot(tester).scaffold.verifyRunButtonAbsent();

      // ToolScaffold observes AppSettings via ListenableBuilder — change propagates immediately
      await AppSettings.instance.setAutoRun(false);
      await tester.pump(const Duration(milliseconds: 100));

      await UrlEncoderRobot(tester).scaffold.verifyRunButtonVisible();
    });

    testWidgets('with autoRun off typing produces no output until Run is tapped', (tester) async {
      await AppSettings.instance.setAutoRun(false);
      await pump(tester);
      await app.navigateTo('url_encoder');

      final robot = UrlEncoderRobot(tester);
      // setInput stores input but skips _update() when autoRun=false
      await robot.scaffold.enterInput('hello world');
      await robot.scaffold.verifyOutputIsEmpty();

      // run() calls _update() unconditionally
      await robot.scaffold.tapRun();
      await robot.scaffold.verifyOutputContains('hello%20world');
    });
  });

  // ── B: Input caching × Navigation ────────────────────────────────────────

  group('B — Input caching × Navigation', () {
    testWidgets('cached input pre-fills the tool and auto-processes on first open', (tester) async {
      // Seed the live SharedPreferences instance directly — setMockInitialValues
      // would create a new instance that bypasses the one already loaded in setUp.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('tool_input_url_encoder', 'hello world');

      await pump(tester);
      await app.navigateTo('url_encoder');
      // ToolInputCache.load() is a Future — pump to let the .then() callback fire
      await tester.pump(const Duration(milliseconds: 100));

      await UrlEncoderRobot(tester).scaffold.verifyInputContains('hello world');
      // autoRun=true → setInput triggers _update() as soon as cache is restored
      await UrlEncoderRobot(tester).scaffold.verifyOutputContains('hello%20world');
    });

    testWidgets('input is restored when navigating back to a tool', (tester) async {
      await pump(tester);
      await app.navigateTo('url_encoder');

      // Typing calls ToolInputCache.save() — written to the live SharedPreferences mock
      await UrlEncoderRobot(tester).scaffold.enterInput('hello world');

      // Navigate away — YaruNavigationPage rebuilds via Navigator+ValueKey so page is destroyed
      await app.navigateTo('base64_text');

      // Navigate back — fresh page created, initState calls ToolInputCache.load()
      await app.navigateTo('url_encoder');
      await tester.pump(const Duration(milliseconds: 100)); // let load() Future complete

      await UrlEncoderRobot(tester).scaffold.verifyInputContains('hello world');
    });
  });

  // ── C: Tool ordering × Navigation ────────────────────────────────────────

  group('C — Tool ordering × Navigation', () {
    testWidgets('hiding a tool removes its nav rail item', (tester) async {
      await pump(tester);
      await app.verifyToolVisible('url_encoder');

      // toggleHidden notifies ToolOrderNotifier → ListenableBuilder in AdaptiveNavigationPane rebuilds
      await notifier.toggleHidden('url_encoder');
      await tester.pump(const Duration(milliseconds: 100));

      await app.verifyToolHidden('url_encoder');
    });

    testWidgets('unhiding a tool restores its nav item and the tool is navigable', (tester) async {
      await notifier.toggleHidden('url_encoder');
      await pump(tester);
      await app.verifyToolHidden('url_encoder');

      await notifier.toggleHidden('url_encoder');
      await tester.pump(const Duration(milliseconds: 100));

      await app.verifyToolVisible('url_encoder');
      await app.navigateTo('url_encoder');
      app.verifyCurrentScreenHasScaffold();
    });
  });

  // ── E: Processing × Mode switch ──────────────────────────────────────────

  group('E — Processing × Mode switch', () {
    testWidgets('switching encode/decode mode immediately reprocesses existing input', (tester) async {
      await pump(tester);
      await app.navigateTo('url_encoder');

      final robot = UrlEncoderRobot(tester);

      // Decode: percent-encoded input → plain text output
      await robot.selectDecodeMode();
      await robot.scaffold.enterInput('hello%20world');
      await robot.scaffold.verifyOutputContains('hello world');

      // setMode() always calls _update() — switches back to encode and reprocesses the same input
      await robot.selectEncodeMode();
      // encoding "hello%20world" → "hello%2520world" (the % itself is encoded)
      await robot.scaffold.verifyOutputContains('hello%2520world');
    });
  });
}
