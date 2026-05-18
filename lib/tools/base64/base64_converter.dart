import 'package:dash_tools/l10n/l10n.dart';
import 'package:dash_tools/tools/base64/base64_controller.dart';
import 'package:dash_tools/tools/clipboard_service.dart';
import 'package:dash_tools/widgets/copy_button.dart';
import 'package:dash_tools/widgets/flex_action_bar.dart';
import 'package:dash_tools/widgets/vendored/split.dart';
import 'package:flutter/material.dart';
import 'package:yaru/widgets.dart';

class Base64ConverterScreen extends StatefulWidget {
  const Base64ConverterScreen({super.key});

  @override
  State<Base64ConverterScreen> createState() => _Base64ConverterScreenState();
}

class _Base64ConverterScreenState extends State<Base64ConverterScreen> {
  late final _controller = Base64Controller();

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
                        ...Base64ConverterMode.values.map((e) => YaruRadioButton(
                              value: e,
                              groupValue: _controller.mode,
                              onChanged: (_) => _controller.setMode(e),
                              title: Text(e.localizedName(l10n)),
                            )),
                        const SizedBox.square(dimension: 8),
                        Tooltip(
                          message: l10n.encoding,
                          child: YaruPopupMenuButton(
                            child: Text(_controller.codec.displayName),
                            itemBuilder: (ctx) => Codec.values
                                .map((e) => PopupMenuItem(
                                      value: e,
                                      onTap: () => _controller.setCodec(e),
                                      child: Text(e.displayName),
                                    ))
                                .toList(),
                          ),
                        ),
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

extension Base64ConverterModeX on Base64ConverterMode {
  String localizedName(AppLocalizations l10n) => switch (this) {
        Base64ConverterMode.encode => l10n.base64ModeEncode,
        Base64ConverterMode.decode => l10n.base64ModeDecode,
      };
}
