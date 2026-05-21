import 'package:dash_tools/l10n/l10n.dart';
import 'package:dash_tools/tools/base64/base64_controller.dart';
import 'package:dash_tools/tools/clipboard_service.dart';
import 'package:dash_tools/widgets/copy_button.dart';
import 'package:dash_tools/widgets/tool_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:yaru/widgets.dart';

class Base64ConverterScreen extends StatefulWidget {
  @Preview(name: 'Base64 Converter', group: 'Tools', size: Size(900, 700))
  const Base64ConverterScreen({super.key});

  @override
  State<Base64ConverterScreen> createState() => _Base64ConverterScreenState();
}

class _Base64ConverterScreenState extends State<Base64ConverterScreen> {
  late final _controller = Base64Controller();
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
            ],
          ),
        ),
      ],
      outputActions: [
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

extension Base64ConverterModeX on Base64ConverterMode {
  String localizedName(AppLocalizations l10n) => switch (this) {
        Base64ConverterMode.encode => l10n.base64ModeEncode,
        Base64ConverterMode.decode => l10n.base64ModeDecode,
      };
}
