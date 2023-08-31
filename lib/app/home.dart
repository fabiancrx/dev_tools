import "package:dash_tools/tools/tools.dart";
import "package:dash_tools/widgets/app_logo.dart";
import "package:dash_tools/widgets/clear_text.dart";
import "package:flutter/material.dart";
import "package:yaru_widgets/yaru_widgets.dart";

class SearchField extends StatefulWidget {
  const SearchField({super.key});

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final searchController = TextEditingController();
  late final searchFocus = FocusNode();

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
    searchFocus.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 5),
      child: TextField(
          controller: searchController,
          focusNode: searchFocus,
          decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Search...',
              hintStyle: TextStyle(),
              suffixIcon: ClearTextIcon(controller: searchController, focusNode: searchFocus))),
    );
  }
}

class AdaptiveNavigationPane extends StatefulWidget {
  final List<Tool> tools;

  const AdaptiveNavigationPane({super.key, required this.tools});

  @override
  State<AdaptiveNavigationPane> createState() => _AdaptiveNavigationPaneState();
}

class _AdaptiveNavigationPaneState extends State<AdaptiveNavigationPane> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // todo move to breakpoints extension
    var normalWindowSize = width > 800 && width < 1200;
    var wideWindowSize = width > 1200;
    final itemStyle = normalWindowSize
        ? YaruNavigationRailStyle.labelled
        : wideWindowSize
            ? YaruNavigationRailStyle.labelledExtended
            : YaruNavigationRailStyle.compact;
    return YaruNavigationPage(
      trailing: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: YaruNavigationRailItem(
          icon: const Icon(Icons.settings),
          label: const Text('Settings'),
          style: itemStyle,
          onTap: () => showDialog(
            context: context,
            builder: (context) => const LicensePage(),
          ),
        ),
      ),
      leading: AnimatedContainer(
        width: normalWindowSize
            ? 100
            : wideWindowSize
                ? 250
                : 60,
        duration: const Duration(milliseconds: 200),
        child: YaruWindowTitleBar(
          title: wideWindowSize
              ? ConstrainedBox(constraints: const BoxConstraints(maxHeight: 44), child: const SearchField())
              : const AppLogo(),
          style: YaruTitleBarStyle.undecorated,
        ),
      ),
      length: widget.tools.length,
      onSelected: (value) {
        setState(() {
          selectedIndex = value;
        });
      },
      initialIndex: selectedIndex,
      itemBuilder: (context, index, selected) => YaruNavigationRailItem(
        tooltip: wideWindowSize ? tools[index].description : tools[index].name,
        icon: tools[index].icon ?? const Icon(Icons.compare_arrows),
        label: Text(tools[index].name), style: itemStyle,
        // tooltip: pageItems[index].tooltipMessage,
      ),
      pageBuilder: (context, index) => YaruDetailPage(
        appBar: YaruWindowTitleBar(
          leading: Navigator.of(context).canPop() ? const YaruBackButton() : null,
          title: Text(tools[index].name),
        ),
        body: tools[index].screen,
      ),
    );
  }
}
