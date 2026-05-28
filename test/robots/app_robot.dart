import 'package:dash_tools/app/app.dart';
import 'package:dash_tools/app/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppRobot {
  const AppRobot(this.tester);
  final WidgetTester tester;

  /// Pumps the full app at a desktop-sized window and waits for the tool list
  /// to load from SharedPreferences (ToolOrderNotifier is async).
  Future<void> pumpApp() async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();
  }

  /// Taps the nav rail item for [toolId] and waits for the screen to settle.
  Future<void> navigateTo(String toolId) async {
    final key = AdaptiveNavigationPane.navItemKey(toolId);
    await tester.tap(find.byKey(key));
    await tester.pumpAndSettle();
  }

  /// Asserts the nav rail item for [toolId] is present in the widget tree.
  Future<void> verifyToolVisible(String toolId) async {
    expect(find.byKey(AdaptiveNavigationPane.navItemKey(toolId)), findsOneWidget);
  }
}
