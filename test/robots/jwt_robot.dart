import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class JwtRobot {
  const JwtRobot(this.tester);
  final WidgetTester tester;

  // The token field is the only TextField with minLines: 4 on the decode tab.
  Finder get _tokenField =>
      find.byWidgetPredicate((w) => w is TextField && w.minLines == 4);

  Future<void> enterToken(String jwt) async {
    await tester.enterText(_tokenField, jwt);
    await tester.pump();
  }

  Future<void> tapClear() async {
    await tester.tap(find.byTooltip('Clear'));
    await tester.pumpAndSettle();
  }

  Future<void> verifyStatusText(String text) async {
    expect(find.text(text), findsOneWidget);
  }

  // The _ColorLegend always shows "Header" and "Payload" text.
  // Use "Subject" (the sub claim breakdown label) as a proxy for the payload
  // _JwtDetails section being rendered — it only appears in the claims breakdown.
  Future<void> verifyPayloadSectionVisible() async {
    expect(find.text('Subject'), findsOneWidget);
  }

  Future<void> verifyPayloadSectionAbsent() async {
    expect(find.text('Subject'), findsNothing);
  }

  Future<void> verifyErrorContains(String fragment) async {
    final matching = find.byWidgetPredicate(
      (w) => w is Text && (w.data?.contains(fragment) ?? false),
    );
    expect(matching, findsWidgets);
  }
}
