import 'package:dash_tools/l10n/l10n.dart';
import 'package:dash_tools/tools/clipboard_service.dart';
import 'package:dash_tools/tools/url_encoder/url_encoder.dart';
import 'package:dash_tools/tools/url_encoder/url_encoder_controller.dart';
import 'package:dash_tools/widgets/copy_button.dart';
import 'package:dash_tools/widgets/tool_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:yaru/widgets.dart';

class UrlEncoderScreen extends StatefulWidget {
  const UrlEncoderScreen({super.key});

  @override
  State<UrlEncoderScreen> createState() => _UrlEncoderScreenState();
}

class _UrlEncoderScreenState extends State<UrlEncoderScreen> {
  final _controller = UrlEncoderController();
  late final _inputTec = TextEditingController();
  late final _outputTec = TextEditingController();

  @override
  void initState() {
    super.initState();
    _inputTec.addListener(() => _controller.setInput(_inputTec.text));
    _controller.addListener(() {
      if (_outputTec.text != _controller.output) {
        _outputTec.text = _controller.output;
      }
    });
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
              ...UrlEncodeMode.values.map((e) => YaruRadioButton<UrlEncodeMode>(
                    value: e,
                    groupValue: _controller.mode,
                    onChanged: (_) => _controller.setMode(e),
                    title: Text(e == UrlEncodeMode.encode ? 'Encode' : 'Decode'),
                  )),
              const SizedBox.square(dimension: 8),
              YaruPopupMenuButton<UrlEncodeType>(
                child: Text(_controller.type == UrlEncodeType.component ? 'Component' : 'Full URL'),
                itemBuilder: (_) => UrlEncodeType.values
                    .map((t) => PopupMenuItem(
                          value: t,
                          onTap: () => _controller.setType(t),
                          child: Text(t == UrlEncodeType.component ? 'Component' : 'Full URL'),
                        ))
                    .toList(),
              ),
            ],
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
        readOnly: true,
        textAlignVertical: TextAlignVertical.top,
        decoration: InputDecoration(labelText: l10n.output, alignLabelWithHint: true),
        expands: true,
        maxLines: null,
        minLines: null,
      ),
    );
  }
}
