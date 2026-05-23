import 'package:dash_tools/common/app_settings.dart';
import 'package:dash_tools/widgets/file_drop_zone.dart';
import 'package:dash_tools/widgets/flex_action_bar.dart';
import 'package:dash_tools/widgets/vendored/split.dart';
import 'package:flutter/material.dart';

/// Two-pane input/output layout shared by most converter tools.
class ToolScaffold extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
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
                    final showRun = !AppSettings.instance.autoRun && onRun != null;
                    if (actions.isEmpty && !showRun) return const SizedBox.shrink();
                    return FlexActionBar(
                      children: [
                        ...actions,
                        if (showRun) ...[
                          const SizedBox(width: 8),
                          FilledButton.icon(
                            onPressed: onRun,
                            icon: const Icon(Icons.play_arrow, size: 16),
                            label: const Text('Run'),
                          ),
                        ],
                      ],
                    );
                  },
                ),
                Expanded(
                  child: onFileDropped != null
                      ? FileDropZone(onText: onFileDropped!, child: input)
                      : input,
                ),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                if (outputActions.isNotEmpty)
                  FlexActionBar(children: outputActions),
                Expanded(child: output),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
