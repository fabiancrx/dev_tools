import 'package:dash_tools/app/app.dart';
import 'package:dash_tools/app/home.dart';
import 'package:dash_tools/common/clipboard_recognizer.dart';
import 'package:dash_tools/common/tool_order.dart';
import 'package:dash_tools/l10n/generated/app_localizations.dart';
import 'package:dash_tools/widgets/tool_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppRobot {
  const AppRobot(this.tester);
  final WidgetTester tester;

  void _setUpView() {
    // 1600px wide: labelledExtended nav rail (~250px) leaves ~675px per tool pane,
    // enough for action bars that include mode selectors + Run button + copy.
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  /// Pumps the full app. Reserved for future true integration tests
  /// once window_manager / YaruTheme platform channels are mocked.
  Future<void> pumpApp() async {
    _setUpView();
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();
  }

  /// Pumps [AdaptiveNavigationPane] directly, bypassing the full App widget.
  /// Avoids window_manager and YaruTheme GTK platform channel calls.
  Future<void> pumpNavPane(
    ToolOrderNotifier notifier,
    ClipboardRecognizer recognizer,
  ) async {
    _setUpView();
    await tester.pumpWidget(
      ProviderScope(
        child: DropdownButtonHideUnderline(
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: AdaptiveNavigationPane(
              toolOrder: notifier,
              clipboardRecognizer: recognizer,
            ),
          ),
        ),
      ),
    );
    // YaruNavigationPage has continuous animations; pump a fixed window
    // matching what the minimal smoke test confirmed works.
    await tester.pump(const Duration(milliseconds: 100));
  }

  /// Taps the nav rail item for [toolId] and pumps through the slide transition.
  Future<void> navigateTo(String toolId) async {
    final key = AdaptiveNavigationPane.navItemKey(toolId);
    await tester.ensureVisible(find.byKey(key));
    await tester.tap(find.byKey(key));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  /// Asserts the nav rail item for [toolId] is present in the widget tree.
  Future<void> verifyToolVisible(String toolId) async {
    expect(find.byKey(AdaptiveNavigationPane.navItemKey(toolId)), findsOneWidget);
  }

  /// Asserts the nav rail item for [toolId] is absent (tool is hidden).
  Future<void> verifyToolHidden(String toolId) async {
    expect(find.byKey(AdaptiveNavigationPane.navItemKey(toolId)), findsNothing);
  }

  /// Asserts the ⌘K search prompt is rendered in the title bar.
  void verifySearchBarVisible() {
    expect(find.byIcon(Icons.search), findsWidgets);
  }

  /// Asserts the current tool screen is a standard ToolScaffold layout.
  void verifyCurrentScreenHasScaffold() {
    expect(find.byKey(ToolScaffold.inputKey), findsOneWidget);
    expect(find.byKey(ToolScaffold.outputKey), findsOneWidget);
  }
}
