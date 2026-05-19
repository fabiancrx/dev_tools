import "package:dash_tools/app/home.dart";
import "package:dash_tools/common/tool_order.dart";
import "package:dash_tools/l10n/generated/app_localizations.dart";
import "package:flutter/material.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:yaru/yaru.dart";

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  ToolOrderNotifier? _toolOrder;

  @override
  void initState() {
    super.initState();
    ToolOrderNotifier.load().then((n) {
      if (mounted) setState(() => _toolOrder = n);
    });
  }

  @override
  void dispose() {
    _toolOrder?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YaruTheme(
      data: const YaruThemeData(variant: YaruVariant.orange),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: yaruLight,
        darkTheme: yaruDark,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: _toolOrder == null
            ? const SizedBox.shrink()
            : DropdownButtonHideUnderline(
                child: AdaptiveNavigationPane(toolOrder: _toolOrder!),
              ),
      ),
    );
  }
}
