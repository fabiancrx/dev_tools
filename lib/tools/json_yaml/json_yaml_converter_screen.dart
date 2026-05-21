import 'package:dash_tools/common/tool_input_cache.dart';
import 'package:dash_tools/l10n/l10n.dart';
import 'package:dash_tools/tools/clipboard_service.dart';
import 'package:dash_tools/tools/json_yaml/json_yaml_converter.dart';
import 'package:dash_tools/tools/json_yaml/json_yaml_converter_controller.dart';
import 'package:dash_tools/widgets/copy_button.dart';
import 'package:dash_tools/widgets/tool_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:yaru/widgets.dart';

const _kCacheKey = 'json_yaml_converter';

class JsonYamlConverterScreen extends StatefulWidget {
  const JsonYamlConverterScreen({super.key});

  @override
  State<JsonYamlConverterScreen> createState() => _JsonYamlConverterScreenState();
}

class _JsonYamlConverterScreenState extends State<JsonYamlConverterScreen> {
  final _controller = JsonYamlConverterController();
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
      actions: [
        ListenableBuilder(
          listenable: _controller,
          builder: (_, _) => Row(
            mainAxisSize: MainAxisSize.min,
            children: JsonYamlMode.values
                .map((e) => YaruRadioButton<JsonYamlMode>(
                      value: e,
                      groupValue: _controller.mode,
                      onChanged: (_) => _controller.setMode(e),
                      title: Text(e.label(l10n)),
                    ))
                .toList(),
          ),
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

extension JsonYamlModeX on JsonYamlMode {
  String label(AppLocalizations l10n) => switch (this) {
        JsonYamlMode.jsonToYaml => l10n.jsonYamlModeJsonToYaml,
        JsonYamlMode.yamlToJson => l10n.jsonYamlModeYamlToJson,
      };
}
