import "dart:io";

import "package:dash_tools/app/command_palette.dart";
import "package:dash_tools/app/reorder_screen.dart";
import "package:dash_tools/common/clipboard_recognizer.dart";
import "package:dash_tools/common/tool_order.dart";
import "package:dash_tools/l10n/l10n.dart";
import "package:dash_tools/tools/registry.dart";
import "package:dash_tools/widgets/clear_text.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
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
  final ToolOrderNotifier toolOrder;
  final ClipboardRecognizer clipboardRecognizer;

  const AdaptiveNavigationPane({
    super.key,
    required this.toolOrder,
    required this.clipboardRecognizer,
  });

  @override
  State<AdaptiveNavigationPane> createState() => _AdaptiveNavigationPaneState();
}

class _AdaptiveNavigationPaneState extends State<AdaptiveNavigationPane> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    widget.clipboardRecognizer.addListener(_onClipboardMatch);
    HardwareKeyboard.instance.addHandler(_handleKey);
  }

  @override
  void dispose() {
    widget.clipboardRecognizer.removeListener(_onClipboardMatch);
    HardwareKeyboard.instance.removeHandler(_handleKey);
    super.dispose();
  }

  bool _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    final isK = event.logicalKey == LogicalKeyboardKey.keyK;
    final modifier = HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed;
    if (isK && modifier) {
      _showPalette();
      return true;
    }
    return false;
  }

  void _showPalette() {
    showDialog<void>(
      context: context,
      builder: (_) => CommandPalette(
        allTools: toolRegistry,
        hiddenIds: widget.toolOrder.hiddenIds,
        onSelect: (id) {
          Navigator.of(context).pop();
          _navigateTo(id);
        },
      ),
    );
  }

  void _onClipboardMatch() {
    final match = widget.clipboardRecognizer.match;
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearMaterialBanners();
    if (match == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showMaterialBanner(
        _ClipboardBanner(
          match: match,
          onOpen: () {
            widget.clipboardRecognizer.dismiss();
            _navigateTo(match.id);
          },
          onDismiss: widget.clipboardRecognizer.dismiss,
        ),
      );
    });
  }

  Future<void> _navigateTo(String toolId) async {
    if (widget.toolOrder.isHidden(toolId)) {
      await widget.toolOrder.unhide(toolId);
    }
    if (!mounted) return;
    final idx = widget.toolOrder.visibleTools.indexWhere((t) => t.id == toolId);
    if (idx >= 0) setState(() => selectedIndex = idx);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final normalWindowSize = width > 800 && width < 1200;
    final wideWindowSize = width > 1200;
    final itemStyle = normalWindowSize
        ? YaruNavigationRailStyle.labelled
        : wideWindowSize
            ? YaruNavigationRailStyle.labelledExtended
            : YaruNavigationRailStyle.compact;

    final paneWidth = itemStyle == YaruNavigationRailStyle.compact ? 70.0 : null;

    return ListenableBuilder(
      listenable: widget.toolOrder,
      builder: (context, _) {
        final tools = widget.toolOrder.visibleTools;
        final clampedIndex = selectedIndex.clamp(0, (tools.length - 1).clamp(0, double.maxFinite.toInt()));

        return YaruNavigationPage(
          trailing: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: YaruNavigationRailItem(
              icon: const Icon(Icons.settings),
              label: Text(context.l10n.settings),
              width: paneWidth,
              style: itemStyle,
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ReorderScreen(notifier: widget.toolOrder),
                ));
              },
            ),
          ),
          leading: SizedBox(height: Platform.isMacOS ? 44 : 24),
          length: tools.length,
          onSelected: (value) => setState(() => selectedIndex = value),
          initialIndex: clampedIndex,
          itemBuilder: (context, index, selected) => YaruNavigationRailItem(
            tooltip: wideWindowSize
                ? context.l10n.toolDescription(tools[index].id)
                : context.l10n.toolName(tools[index].id),
            icon: Icon(tools[index].icon),
            label: Text(context.l10n.toolName(tools[index].id)),
            style: itemStyle,
          ),
          pageBuilder: (context, index) => YaruDetailPage(
            appBar: YaruWindowTitleBar(
                title: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 46, maxWidth: 420),
                    child: SearchField(hint: context.l10n.toolName(tools[index].id)))),
            body: tools[index].builder(context),
          ),
        );
      },
    );
  }
}

class _ClipboardBanner extends MaterialBanner {
  _ClipboardBanner({
    required ToolDescriptor match,
    required VoidCallback onOpen,
    required VoidCallback onDismiss,
  }) : super(
          content: Row(
            children: [
              Icon(match.icon, size: 18),
              const SizedBox(width: 8),
              Builder(
                builder: (context) => Text(
                  'Clipboard looks like ${match.name(context)}',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: onOpen, child: const Text('Open')),
            TextButton(onPressed: onDismiss, child: const Text('Dismiss')),
          ],
        );
}
