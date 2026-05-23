import "package:flutter/foundation.dart";
import "package:dash_tools/app/command_palette.dart";
import "package:dash_tools/app/reorder_screen.dart";
import "package:dash_tools/app/tray.dart";
import "package:dash_tools/common/app_theme.dart";
import "package:dash_tools/common/clipboard_recognizer.dart";
import "package:dash_tools/common/platform_keys.dart";
import "package:dash_tools/common/tool_order.dart";
import "package:dash_tools/l10n/l10n.dart";
import "package:dash_tools/tools/registry.dart";
import "package:dash_tools/widgets/adaptive_navigation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:yaru/widgets.dart";

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
  bool _isMovingDown = true;
  bool _forceCollapsed = false;

  @override
  void initState() {
    super.initState();
    widget.clipboardRecognizer.addListener(_onClipboardMatch);
    HardwareKeyboard.instance.addHandler(_handleKey);
    if (isTraySupported) {
      TrayService.instance.lastActionStatus.addListener(_onTrayStatus);
    }
  }

  @override
  void dispose() {
    widget.clipboardRecognizer.removeListener(_onClipboardMatch);
    HardwareKeyboard.instance.removeHandler(_handleKey);
    if (isTraySupported) {
      TrayService.instance.lastActionStatus.removeListener(_onTrayStatus);
    }
    super.dispose();
  }

  void _onTrayStatus() {
    final msg = TrayService.instance.lastActionStatus.value;
    if (msg == null || !mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 3)));
  }

  bool _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    if (!PlatformKeys.isPrimaryModifierPressed(HardwareKeyboard.instance)) return false;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.keyK || key == LogicalKeyboardKey.slash) {
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
    final itemStyle = _forceCollapsed
        ? YaruNavigationRailStyle.compact
        : normalWindowSize
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

        final navTransition = PageTransitionsTheme(builders: {
          TargetPlatform.linux: DirectionalSlideBuilder(down: _isMovingDown),
          TargetPlatform.macOS: DirectionalSlideBuilder(down: _isMovingDown),
          TargetPlatform.windows: DirectionalSlideBuilder(down: _isMovingDown),
        });
        return YaruNavigationPageTheme(
          data: YaruNavigationPageThemeData(pageTransitions: navTransition),
          child: YaruNavigationPage(
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
          leading: SizedBox(height: defaultTargetPlatform == TargetPlatform.macOS ? 44 : 0),
          length: tools.length,
          onSelected: (value) => setState(() {
                _isMovingDown = value > selectedIndex;
                selectedIndex = value;
              }),
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
                leading: IconButton(
                  tooltip: _forceCollapsed ? 'Expand sidebar' : 'Collapse sidebar',
                  icon: SvgPicture.asset(
                    _forceCollapsed
                        ? 'assets/icons/sidebar-right-svgrepo-com.svg'
                        : 'assets/icons/sidebar-left-svgrepo-com.svg',
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(
                      IconTheme.of(context).color ?? Theme.of(context).iconTheme.color ?? Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  onPressed: () => setState(() => _forceCollapsed = !_forceCollapsed),
                ),
                title: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 46, maxWidth: 420),
                    child: PaletteSearchPrompt(
                      currentToolName: context.l10n.toolName(tools[index].id),
                      onTap: _showPalette,
                    ))),
            body: tools[index].builder(context),
          ),
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
