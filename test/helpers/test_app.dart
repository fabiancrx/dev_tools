import 'package:dash_tools/common/app_settings.dart';
import 'package:dash_tools/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Minimal widget test harness: MaterialApp + localizations.
/// Pass [withRiverpod: true] for screens that use flutter_riverpod.
Widget testApp(Widget child, {bool withRiverpod = false}) {
  final app = MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
  return withRiverpod ? ProviderScope(child: app) : app;
}

/// Resets shared state before each widget test.
Future<void> setUpTestEnv() async {
  SharedPreferences.setMockInitialValues({});
  await AppSettings.init();
}

/// Sets the test view to a desktop-sized window to prevent layout overflows
/// in screens with wide action bars. Call at the start of each testWidgets.
void setUpView(WidgetTester tester) {
  tester.view.physicalSize = const Size(1280, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}
