import 'package:dash_tools/common/tool_input_cache.dart';
import 'package:dash_tools/l10n/l10n.dart';
import 'package:dash_tools/tools/clipboard_service.dart';
import 'package:dash_tools/tools/yaml/yaml_formatter.dart';
import 'package:dash_tools/tools/yaml/yaml_formatter_controller.dart';
import 'package:dash_tools/widgets/copy_button.dart';
import 'package:dash_tools/widgets/output_text_field.dart';
import 'package:dash_tools/widgets/tool_scaffold.dart';
import 'package:flutter/material.dart';

const _kCacheKey = 'yaml_formatter';

class YamlFormatterScreen extends StatefulWidget {
  const YamlFormatterScreen({super.key});

  @override
  State<YamlFormatterScreen> createState() => _YamlFormatterScreenState();
}

class _YamlFormatterScreenState extends State<YamlFormatterScreen> {
  final _controller = YamlFormatterController();
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
        OutlinedButton(
          onPressed: () => _inputTec.text = kSampleYaml,
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
        saveExtension: 'yaml',
      ),
    );
  }
}
