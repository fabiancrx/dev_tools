import 'package:dash_tools/l10n/l10n.dart';
import 'package:dash_tools/tools/clipboard_service.dart';
import 'package:dash_tools/tools/hex_text_controller.dart';
import 'package:dash_tools/widgets/copy_button.dart';
import 'package:dash_tools/widgets/flex_action_bar.dart';
import 'package:dash_tools/widgets/vendored/split.dart';
import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

class HexToTextConverterScreen extends StatefulWidget {
  const HexToTextConverterScreen({super.key});

  @override
  State<HexToTextConverterScreen> createState() => _HexToTextConverterScreenState();
}

class _HexToTextConverterScreenState extends State<HexToTextConverterScreen> {
  late final _controller = HexTextController();

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
          axis: Axis.horizontal,
          initialFractions: const [0.5, 0.5],
          minSizes: const [80, 160],
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                FlexActionBar(children: [
                  ListenableBuilder(
                    listenable: _controller,
                    builder: (_, _) {
                      return Row(
                        children: HexTextConvertMode.values
                            .map((e) => YaruRadioButton(
                                  value: e,
                                  groupValue: _controller.mode,
                                  onChanged: (_) => _controller.setMode(e),
                                  title: Text(e.localizedName(l10n)),
                                ))
                            .toList(),
                      );
                    },
                  ),
                ]),
                Expanded(
                  child: TextField(
                    controller: _controller.inputController,
                    textAlignVertical: TextAlignVertical.top,
                    expands: true,
                    maxLines: null,
                    minLines: null,
                  ),
                ),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FlexActionBar(children: [
                  CopyButton(copyCallback: () {
                    pasteContentToClipboard(_controller.outputController.text);
                  }),
                ]),
                Expanded(
                  child: TextField(
                    controller: _controller.outputController,
                    textAlignVertical: TextAlignVertical.top,
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

extension HexTextConvertModeX on HexTextConvertMode {
  String localizedName(AppLocalizations l10n) => switch (this) {
        HexTextConvertMode.hexToText => l10n.hexTextModeHexToText,
        HexTextConvertMode.textToHex => l10n.hexTextModeTextToHex,
      };
}
