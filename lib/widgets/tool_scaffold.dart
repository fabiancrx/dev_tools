import 'package:dash_tools/common/app_settings.dart';
import 'package:dash_tools/common/app_theme.dart';
import 'package:dash_tools/common/platform_keys.dart';
import 'package:dash_tools/widgets/file_drop_zone.dart';
import 'package:dash_tools/widgets/flex_action_bar.dart';
import 'package:dash_tools/widgets/vendored/split.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Two-pane input/output layout shared by most converter tools.
class ToolScaffold extends StatefulWidget {
  static const inputKey = Key('tool_scaffold_input');
  static const outputKey = Key('tool_scaffold_output');
  static const runButtonKey = Key('tool_scaffold_run_button');

  final List<Widget> actions;
  final List<Widget> outputActions;
  final Widget input;
  final Widget output;

  /// Called when the user presses the Run button (visible when autoRun is off).
  /// Pass `null` to opt out of the Run button entirely.
  final VoidCallback? onRun;

  /// When non-null, the input pane becomes a file drop target; dropped files
  /// are read as UTF-8 and their contents passed to this callback.
  final ValueChanged<String>? onFileDropped;

  const ToolScaffold({
    super.key,
    required this.actions,
    required this.input,
    required this.output,
    this.outputActions = const [],
    this.onRun,
    this.onFileDropped,
  });

  @override
  State<ToolScaffold> createState() => _ToolScaffoldState();
}

class _ToolScaffoldState extends State<ToolScaffold> {
  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKey);
    super.dispose();
  }

  bool _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    if (event.logicalKey != LogicalKeyboardKey.enter) return false;
    if (!PlatformKeys.isPrimaryModifierPressed(HardwareKeyboard.instance)) return false;
    if (AppSettings.instance.autoRun || widget.onRun == null) return false;
    widget.onRun!();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.toolPadding),
        child: SplitWrap(
          axis: Axis.horizontal,
          initialFractions: const [0.5, 0.5],
          minSizes: const [200, 200],
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                ListenableBuilder(
                  listenable: AppSettings.instance,
                  builder: (context, _) {
                    final showRun = !AppSettings.instance.autoRun && widget.onRun != null;
                    if (widget.actions.isEmpty && !showRun) return const SizedBox.shrink();
                    return FlexActionBar(
                      children: [
                        ...widget.actions,
                        if (showRun) ...[
                          const SizedBox(width: AppSpacing.gap),
                          Tooltip(
                            message: 'Run  ${PlatformKeys.run}',
                            child: FilledButton.icon(
                              key: ToolScaffold.runButtonKey,
                              onPressed: widget.onRun,
                              icon: const Icon(Icons.play_arrow, size: 16),
                              label: const Text('Run'),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
                Expanded(
                  child: KeyedSubtree(
                    key: ToolScaffold.inputKey,
                    child: widget.onFileDropped != null
                        ? FileDropZone(onText: widget.onFileDropped!, child: widget.input)
                        : widget.input,
                  ),
                ),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                if (widget.outputActions.isNotEmpty)
                  FlexActionBar(children: widget.outputActions),
                Expanded(child: KeyedSubtree(key: ToolScaffold.outputKey, child: widget.output)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
