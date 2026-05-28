import 'package:dash_tools/common/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class SettingsRobot {
  const SettingsRobot(this.tester);
  final WidgetTester tester;

  Future<void> tapAutoRunToggle() async {
    await tester.tap(find.text('Process as you type'));
    await tester.pumpAndSettle();
  }

  Future<void> tapCompactModeToggle() async {
    await tester.tap(find.text('Compact mode'));
    await tester.pumpAndSettle();
  }

  Future<void> tapLicenses() async {
    await tester.tap(find.text('Licenses'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> verifyAutoRun(bool expected) async {
    expect(AppSettings.instance.autoRun, expected);
  }

  Future<void> verifyCompactMode(bool expected) async {
    expect(AppSettings.instance.compactMode, expected);
  }

  Future<void> verifyLicensePageVisible() async {
    expect(find.byType(LicensePage), findsOneWidget);
  }
}
