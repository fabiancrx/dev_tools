import "dart:io";

import "package:dash_tools/l10n/l10n.dart";
import "package:dash_tools/tools/registry.dart";
import "package:dash_tools/widgets/app_logo.dart";
import "package:dash_tools/widgets/clear_text.dart";
import "package:flutter/material.dart";
import "package:yaru/widgets.dart";

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
                  textAlign: searchFocus.hasFocus ? TextAlign.start : TextAlign.center,
                  focusNode: searchFocus,
                  decoration: InputDecoration(
                      prefixIcon: searchFocus.hasFocus ? const Icon(Icons.search) : const SizedBox.shrink(),
                      hintText: searchFocus.hasFocus ? context.l10n.search : widget.hint,
                      hintStyle: const TextStyle(),
                      suffixIcon: ClearTextIcon(controller: searchController, focusNode: searchFocus)));
            }),
      ),
    );
  }
}

class AdaptiveNavigationPane extends StatefulWidget {
  final List<ToolDescriptor> tools;

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

    final paneWidth = itemStyle == YaruNavigationRailStyle.compact ? 70.0 : null;
    return YaruNavigationPage(
      trailing: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: YaruNavigationRailItem(
          icon: const Icon(Icons.settings),
          label: Text(context.l10n.settings),
          width: paneWidth,
          style: itemStyle,
          onTap: () {
            const licensePage = LicensePage(
                applicationIcon: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: AppLogo(),
                ),
                applicationVersion: '0.0.1');

            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const YaruDetailPage(
                      appBar: YaruWindowTitleBar(title: Text(AppLogo.name)),
                      body: licensePage,
                    )));
          },
        ),
      ),
      leading: SizedBox(height: Platform.isMacOS ? 44 : 24),
      length: widget.tools.length,
      onSelected: (value) {
        setState(() {
          selectedIndex = value;
        });
      },
      initialIndex: selectedIndex,
      itemBuilder: (context, index, selected) => YaruNavigationRailItem(
        tooltip: wideWindowSize ? context.l10n.toolDescription(widget.tools[index].id) : context.l10n.toolName(widget.tools[index].id),
        icon: Icon(widget.tools[index].icon),
        label: Text(context.l10n.toolName(widget.tools[index].id)),
        style: itemStyle,
      ),
      pageBuilder: (context, index) => YaruDetailPage(
        appBar: YaruWindowTitleBar(
            title: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 46, maxWidth: 420),
                child: SearchField(hint: context.l10n.toolName(widget.tools[index].id)))),
        body: widget.tools[index].builder(context),
      ),
    );
  }
}
