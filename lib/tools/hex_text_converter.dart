import 'package:dash_tools/l10n/l10n.dart';
import 'package:dash_tools/tools/clipboard_service.dart';
import 'package:dash_tools/tools/hex_text_controller.dart';
import 'package:dash_tools/widgets/copy_button.dart';
import 'package:dash_tools/widgets/tool_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:yaru/yaru.dart';

class HexToTextConverterScreen extends StatefulWidget {
  @Preview(name: 'Hex/Text Converter', group: 'Tools', size: Size(900, 600))
  const HexToTextConverterScreen({super.key});

  @override
  State<HexToTextConverterScreen> createState() => _HexToTextConverterScreenState();
}

class _HexToTextConverterScreenState extends State<HexToTextConverterScreen> {
  late final _controller = HexTextController();
  late final _inputTec = TextEditingController(text: _controller.input);
  late final _outputTec = TextEditingController(text: _controller.output);

  @override
  void initState() {
    super.initState();
    _inputTec.addListener(() => _controller.setInput(_inputTec.text));
    _controller.addListener(() => _outputTec.text = _controller.output);
  }

  @override
  void dispose() {
    _inputTec.dispose();
    _outputTec.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ToolScaffold(
      actions: [
        ListenableBuilder(
          listenable: _controller,
          builder: (_, _) => Row(
            mainAxisSize: MainAxisSize.min,
            children: HexTextConvertMode.values
                .map((e) => YaruRadioButton(
                      value: e,
                      groupValue: _controller.mode,
                      onChanged: (_) => _controller.setMode(e),
                      title: Text(e.localizedName(l10n)),
                    ))
                .toList(),
          ),
        ),
        const Spacer(),
        CopyButton(copyCallback: () => pasteContentToClipboard(_controller.output)),
      ],
      input: TextField(
        controller: _inputTec,
        textAlignVertical: TextAlignVertical.top,
        decoration: InputDecoration(labelText: l10n.input, alignLabelWithHint: true),
        expands: true,
        maxLines: null,
        minLines: null,
      ),
      output: TextField(
        controller: _outputTec,
        textAlignVertical: TextAlignVertical.top,
        decoration: InputDecoration(labelText: l10n.output, alignLabelWithHint: true),
        expands: true,
        maxLines: null,
        minLines: null,
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
