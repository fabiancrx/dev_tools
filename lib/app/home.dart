import "dart:io";

import "package:dash_tools/tools/tools.dart";
import "package:dash_tools/widgets/clear_text.dart";
import "package:flutter/material.dart";
import "package:yaru_widgets/yaru_widgets.dart";

class SearchField extends StatefulWidget {
  final String hint;

  const SearchField({super.key, required this.hint});

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
    return IgnorePointer(
      ignoring: true,
      child: Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 5),
        child: ListenableBuilder(
            listenable: searchFocus,
            builder: (context, child) {
              return TextField(
                  controller: searchController,
                  textAlign: searchFocus.hasFocus ? TextAlign.start :TextAlign.center,
                  focusNode: searchFocus,
                  decoration: InputDecoration(
                      prefixIcon: searchFocus.hasFocus ? const Icon(Icons.search) : SizedBox.shrink(),

                      hintText: searchFocus.hasFocus ? 'Search...' : widget.hint,
                      hintStyle: const TextStyle(),
                      suffixIcon: ClearTextIcon(controller: searchController, focusNode: searchFocus)));
            }),
      ),
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
      leading: SizedBox(height: Platform.isMacOS ? 46 : 24),
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
        label: Text(tools[index].name),
        style: itemStyle,
      ),
      pageBuilder: (context, index) => YaruDetailPage(
        appBar: YaruWindowTitleBar(
            leading: Navigator.of(context).canPop() ? const YaruBackButton() : null,
            title: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 46, maxWidth: 420), child: SearchField(hint: tools[index].name))),
        body: tools[index].screen,
      ),
    );
  }
}
