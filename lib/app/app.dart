import "package:dash_tools/app/home.dart";
import "package:dash_tools/common/app_theme.dart";
import "package:dash_tools/common/clipboard_recognizer.dart";
import "package:dash_tools/common/tool_order.dart";
import "package:dash_tools/l10n/generated/app_localizations.dart";
import "package:flutter/material.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:window_manager/window_manager.dart";
import "package:yaru/yaru.dart";

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WindowListener {
  ToolOrderNotifier? _toolOrder;
  final _clipboardRecognizer = ClipboardRecognizer();

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    ToolOrderNotifier.load().then((n) {
      if (mounted) setState(() => _toolOrder = n);
    });
    _clipboardRecognizer.check();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    _toolOrder?.dispose();
    _clipboardRecognizer.dispose();
    super.dispose();
  }

  @override
  void onWindowFocus() => _clipboardRecognizer.check();

  @override
  Widget build(BuildContext context) {
    return YaruTheme(
      data: const YaruThemeData(variant: YaruVariant.orange),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: yaruLight.copyWith(extensions: const [AppTheme()]),
        darkTheme: yaruDark.copyWith(extensions: const [AppTheme()]),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: switch (_toolOrder) {
          null => const SizedBox.shrink(),
          final order => DropdownButtonHideUnderline(
              child: AdaptiveNavigationPane(
                toolOrder: order,
                clipboardRecognizer: _clipboardRecognizer,
              ),
            ),
        },
      ),
    );
  }
}
