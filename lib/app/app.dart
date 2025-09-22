import "package:dash_tools/app/home.dart";
import "package:dash_tools/l10n/generated/app_localizations.dart";
import "package:dash_tools/tools/tools.dart";
import "package:flutter/material.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:yaru/yaru.dart";

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return YaruTheme(
      data: const YaruThemeData(variant: YaruVariant.orange),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: yaruLight,
        darkTheme: yaruDark,
        localizationsDelegates:  const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const DropdownButtonHideUnderline(child: AdaptiveNavigationPane(tools: tools)),
      ),
    );
  }
}
