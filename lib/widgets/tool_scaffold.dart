import 'package:dash_tools/common/app_settings.dart';
import 'package:dash_tools/widgets/flex_action_bar.dart';
import 'package:dash_tools/widgets/vendored/split.dart';
import 'package:flutter/material.dart';

/// Two-pane input/output layout shared by most converter tools.
class ToolScaffold extends StatelessWidget {
  final List<Widget> actions;
  final Widget input;
  final Widget output;

  /// Called when the user presses the Run button (visible when autoRun is off).
  /// Pass `null` to opt out of the Run button entirely.
  final VoidCallback? onRun;

  const ToolScaffold({
    super.key,
    required this.actions,
    required this.input,
    required this.output,
    this.onRun,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SplitWrap(
          axis: Axis.vertical,
          initialFractions: const [0.5, 0.5],
          minSizes: const [278, 80],
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                ListenableBuilder(
                  listenable: AppSettings.instance,
                  builder: (context, _) {
                    final showRun = !AppSettings.instance.autoRun && onRun != null;
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
                Expanded(child: input),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(child: output),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
