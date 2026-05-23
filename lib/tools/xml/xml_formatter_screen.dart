import 'package:dash_tools/common/tool_input_cache.dart';
import 'package:dash_tools/l10n/l10n.dart';
import 'package:dash_tools/tools/clipboard_service.dart';
import 'package:dash_tools/tools/xml/xml_formatter.dart';
import 'package:dash_tools/tools/xml/xml_formatter_controller.dart';
import 'package:dash_tools/widgets/copy_button.dart';
import 'package:dash_tools/widgets/output_text_field.dart';
import 'package:dash_tools/widgets/tool_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:yaru/widgets.dart';

const _kCacheKey = 'xml_formatter';

class XmlFormatterScreen extends StatefulWidget {
  const XmlFormatterScreen({super.key});

  @override
  State<XmlFormatterScreen> createState() => _XmlFormatterScreenState();
}

class _XmlFormatterScreenState extends State<XmlFormatterScreen> {
  final _controller = XmlFormatterController();
  late final _inputTec = TextEditingController();
  late final _outputTec = TextEditingController();

  @override
  void initState() {
    super.initState();
    _inputTec.addListener(_onInput);
    _controller.addListener(() {
      if (_outputTec.text != _controller.output) {
        _outputTec.text = _controller.output;
      }
    });
    ToolInputCache.load(_kCacheKey).then((v) {
      if (mounted && v != null && v.isNotEmpty) _inputTec.text = v;
    });
  }

  void _onInput() {
    _controller.setInput(_inputTec.text);
    ToolInputCache.save(_kCacheKey, _inputTec.text);
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
      onRun: _controller.run,
      onFileDropped: (text) => _inputTec.text = text,
      actions: [
        ListenableBuilder(
          listenable: _controller,
          builder: (_, _) => Row(
            mainAxisSize: MainAxisSize.min,
            children: XmlMode.values
                .map((e) => YaruRadioButton<XmlMode>(
                      value: e,
                      groupValue: _controller.mode,
                      onChanged: (_) => _controller.setMode(e),
                      title: Text(e.label),
                    ))
                .toList(),
          ),
        ),
        OutlinedButton(
          onPressed: () => _inputTec.text = kSampleXml,
          child: Text(l10n.sample),
        ),
      ],
      outputActions: [
        CopyButton(copyCallback: () => pasteContentToClipboard(_controller.output)),
      ],
      input: ListenableBuilder(
        listenable: _controller,
        builder: (_, _) => Column(
          children: [
            Expanded(
              child: TextField(
                controller: _inputTec,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(labelText: l10n.input, alignLabelWithHint: true),
                expands: true,
                maxLines: null,
                minLines: null,
              ),
            ),
            if (_controller.error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(_controller.error, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
              ),
          ],
        ),
      ),
      output: OutputTextField(
        controller: _outputTec,
        label: l10n.output,
        saveExtension: 'xml',
      ),
    );
  }
}

extension XmlModeX on XmlMode {
  String get label => switch (this) {
        XmlMode.twoSpaces => '2 Spaces',
        XmlMode.fourSpaces => '4 Spaces',
        XmlMode.tab => 'Tab',
        XmlMode.minify => 'Minify',
      };
}
