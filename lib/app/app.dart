import "package:dash_tools/tools/tools.dart";
import "package:dash_tools/widgets/adaptive_navigation.dart";
import "package:flutter/material.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:dash_tools/l10n/l10n.dart";
import "package:yaru/yaru.dart";

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: YaruTheme(
          data: YaruThemeData(variant: YaruVariant.orange),
          child: DropdownButtonHideUnderline(child: _AdaptiveNavigation())),
    );
  }
}

class _AdaptiveNavigation extends StatefulWidget {
  const _AdaptiveNavigation({Key? key}) : super(key: key);

  @override
  State<_AdaptiveNavigation> createState() => _AdaptiveNavigationState();
}

class _AdaptiveNavigationState extends State<_AdaptiveNavigation> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AdaptiveNavigation(
      selectedIndex: selectedIndex,
      destinations: destinations,
      showNavigationBar: true,
      onDestinationSelected: (int index) {
        setState(() {
          selectedIndex = index;
        });
      },
      child: tools[selectedIndex].screen,
    );
  }
}
