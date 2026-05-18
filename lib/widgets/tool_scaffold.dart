import 'package:dash_tools/widgets/flex_action_bar.dart';
import 'package:dash_tools/widgets/vendored/split.dart';
import 'package:flutter/material.dart';

/// Two-pane input/output layout shared by most converter tools.
///
/// Top half: [FlexActionBar] with [actions], then [input] (fills remaining space).
/// Bottom half: [output] (fills the pane).
class ToolScaffold extends StatelessWidget {
  final List<Widget> actions;
  final Widget input;
  final Widget output;

  const ToolScaffold({
    super.key,
    required this.actions,
    required this.input,
    required this.output,
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
                FlexActionBar(children: actions),
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
