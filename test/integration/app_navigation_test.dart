import 'package:dash_tools/common/app_settings.dart';
import 'package:dash_tools/common/clipboard_recognizer.dart';
import 'package:dash_tools/common/tool_order.dart';
import 'package:dash_tools/widgets/tool_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../robots/app_robot.dart';
import '../robots/url_encoder_robot.dart';

void main() {
  late ToolOrderNotifier notifier;
  late ClipboardRecognizer recognizer;
  late AppRobot app;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppSettings.init();
    notifier = await ToolOrderNotifier.load();
    recognizer = ClipboardRecognizer();
  });

  tearDown(() {
    notifier.dispose();
    recognizer.dispose();
  });

  group('App — opens correctly', () {
    testWidgets('nav pane renders with search bar and tool list', (tester) async {
      app = AppRobot(tester);
      await app.pumpNavPane(notifier, recognizer);

      // Search prompt (⌘K bar in the title bar) is present
      expect(find.byIcon(Icons.search), findsWidgets);

      // First tool nav item key is in the tree
      await app.verifyToolVisible('base64_text');
    });

    testWidgets('initial page renders ToolScaffold input and output panes', (tester) async {
      app = AppRobot(tester);
      await app.pumpNavPane(notifier, recognizer);

      expect(find.byKey(ToolScaffold.inputKey), findsOneWidget);
      expect(find.byKey(ToolScaffold.outputKey), findsOneWidget);
    });
  });

  group('App — navigation', () {
    testWidgets('tapping url_encoder nav item renders Encode / Decode buttons', (tester) async {
      app = AppRobot(tester);
      await app.pumpNavPane(notifier, recognizer);

      await app.navigateTo('url_encoder');

      expect(find.text('Encode'), findsWidgets);
      expect(find.text('Decode'), findsWidgets);
    });

    testWidgets('navigating between tools updates the active screen', (tester) async {
      app = AppRobot(tester);
      await app.pumpNavPane(notifier, recognizer);

      // Navigate to url_encoder and confirm scaffold key is there
      await app.navigateTo('url_encoder');
      expect(find.byKey(ToolScaffold.inputKey), findsOneWidget);

      // Navigate away to base64_text and scaffold key is still there
      await app.navigateTo('base64_text');
      expect(find.byKey(ToolScaffold.inputKey), findsOneWidget);

      // Mode buttons on base64 screen confirm we switched
      expect(find.text('Encode'), findsWidgets);
    });
  });
}
