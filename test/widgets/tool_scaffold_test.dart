import 'package:dash_tools/common/app_settings.dart';
import 'package:dash_tools/l10n/generated/app_localizations.dart';
import 'package:dash_tools/widgets/tool_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _wrap(Widget child) => MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );

Widget _scaffold({VoidCallback? onRun, List<Widget> actions = const []}) =>
    _wrap(ToolScaffold(
      actions: actions,
      onRun: onRun,
      input: const TextField(key: Key('input')),
      output: const TextField(key: Key('output'), readOnly: true),
    ));

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppSettings.init();
  });

  group('Run button visibility', () {
    testWidgets('hidden when autoRun is on', (tester) async {
      await AppSettings.instance.setAutoRun(true);
      await tester.pumpWidget(_scaffold(onRun: () {}));
      await tester.pumpAndSettle();
      expect(find.byKey(ToolScaffold.runButtonKey), findsNothing);
    });

    testWidgets('visible when autoRun is off and onRun is set', (tester) async {
      await AppSettings.instance.setAutoRun(false);
      await tester.pumpWidget(_scaffold(onRun: () {}));
      await tester.pumpAndSettle();
      expect(find.byKey(ToolScaffold.runButtonKey), findsOneWidget);
    });

    testWidgets('hidden when onRun is null even if autoRun is off', (tester) async {
      await AppSettings.instance.setAutoRun(false);
      await tester.pumpWidget(_scaffold(onRun: null));
      await tester.pumpAndSettle();
      expect(find.byKey(ToolScaffold.runButtonKey), findsNothing);
    });

    testWidgets('appears after autoRun is toggled off', (tester) async {
      await AppSettings.instance.setAutoRun(true);
      await tester.pumpWidget(_scaffold(onRun: () {}));
      await tester.pumpAndSettle();
      expect(find.byKey(ToolScaffold.runButtonKey), findsNothing);

      await AppSettings.instance.setAutoRun(false);
      await tester.pumpAndSettle();
      expect(find.byKey(ToolScaffold.runButtonKey), findsOneWidget);
    });
  });

  group('Run button callback', () {
    testWidgets('calls onRun when tapped', (tester) async {
      var called = false;
      await AppSettings.instance.setAutoRun(false);
      await tester.pumpWidget(_scaffold(onRun: () => called = true));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(ToolScaffold.runButtonKey));
      await tester.pump();
      expect(called, isTrue);
    });
  });

  group('Input / output keys', () {
    testWidgets('input and output panes are present', (tester) async {
      await tester.pumpWidget(_scaffold(onRun: () {}));
      await tester.pumpAndSettle();
      expect(find.byKey(ToolScaffold.inputKey), findsOneWidget);
      expect(find.byKey(ToolScaffold.outputKey), findsOneWidget);
    });

    testWidgets('input key wraps the provided input widget', (tester) async {
      await tester.pumpWidget(_scaffold(onRun: () {}));
      await tester.pumpAndSettle();
      final inputTf = find.descendant(
        of: find.byKey(ToolScaffold.inputKey),
        matching: find.byKey(const Key('input')),
      );
      expect(inputTf, findsOneWidget);
    });
  });

  group('Actions bar', () {
    testWidgets('renders custom actions', (tester) async {
      await AppSettings.instance.setAutoRun(true);
      await tester.pumpWidget(_scaffold(
        onRun: () {},
        actions: [const Text('CustomAction')],
      ));
      await tester.pumpAndSettle();
      expect(find.text('CustomAction'), findsOneWidget);
    });

    testWidgets('action bar absent when actions empty and autoRun on', (tester) async {
      await AppSettings.instance.setAutoRun(true);
      await tester.pumpWidget(_scaffold(onRun: () {}));
      await tester.pumpAndSettle();
      expect(find.byKey(ToolScaffold.runButtonKey), findsNothing);
    });
  });
}
