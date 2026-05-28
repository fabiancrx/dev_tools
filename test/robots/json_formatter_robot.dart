import 'package:dash_tools/tools/json/json_screen_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class JsonFormatterRobot {
  const JsonFormatterRobot(this.tester);
  final WidgetTester tester;

  Future<void> selectMode(String modeLabel) async {
    await tester.tap(find.byType(DropdownButton<JsonMode>));
    await tester.pump();
    // CodeForge has a continuous cursor animation — avoid pumpAndSettle which
    // never settles. Pump a fixed duration for the overlay open animation.
    await tester.pump(const Duration(milliseconds: 300));
    // The overlay renders the item twice (in-place + overlay menu item);
    // tap the last occurrence to hit the overlay item.
    await tester.tap(find.text(modeLabel).last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> tapFormat() async {
    await tester.tap(find.text('Format'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  Future<void> tapClear() async {
    await tester.tap(find.byIcon(Icons.clear_rounded).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  Future<void> verifyModeSelected(JsonMode mode) async {
    final dropdown = tester.widget<DropdownButton<JsonMode>>(
      find.byType(DropdownButton<JsonMode>),
    );
    expect(dropdown.value, mode);
  }

  Future<void> verifyFormatButtonVisible() async {
    expect(find.text('Format'), findsOneWidget);
  }
}
