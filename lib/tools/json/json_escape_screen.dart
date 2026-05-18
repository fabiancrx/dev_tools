import 'package:dash_tools/l10n/l10n.dart';
import 'package:dash_tools/tools/clipboard_service.dart';
import 'package:dash_tools/tools/json/json_escape_controller.dart';
import 'package:dash_tools/widgets/copy_button.dart';
import 'package:dash_tools/widgets/flex_action_bar.dart';
import 'package:dash_tools/widgets/vendored/split.dart';
import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

class JsonConverterScreen extends StatefulWidget {
  const JsonConverterScreen({super.key});

  @override
  State<JsonConverterScreen> createState() => _JsonConverterScreenState();
}

class _JsonConverterScreenState extends State<JsonConverterScreen> {
  late final _controller = JsonEscapeController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
                  listenable: _controller,
                  builder: (_, _) {
                    return FlexActionBar(
                      children: [
                        ...JsonEncodeMode.values.map((e) => YaruRadioButton(
                              value: e,
                              groupValue: _controller.mode,
                              onChanged: (_) => _controller.setMode(e),
                              title: Text(e.localizedName(l10n)),
                            )),
                        const Spacer(),
                        CopyButton(copyCallback: () {
                          pasteContentToClipboard(_controller.outputController.text);
                        }),
                      ],
                    );
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _controller.inputController,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(labelText: l10n.input, alignLabelWithHint: true),
                    expands: true,
                    maxLines: null,
                    minLines: null,
                  ),
                ),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller.outputController,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(labelText: l10n.output, alignLabelWithHint: true),
                    expands: true,
                    maxLines: null,
                    minLines: null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

extension JsonEncodeModeX on JsonEncodeMode {
  String localizedName(AppLocalizations l10n) => switch (this) {
        JsonEncodeMode.escape => l10n.jsonEscapeModeEscape,
        JsonEncodeMode.unescape => l10n.jsonEscapeModeUnescape,
      };
}
