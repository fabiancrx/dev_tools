import 'package:code_forge/code_forge.dart';
import 'package:dash_tools/common/code_field.dart';
import 'package:dash_tools/common/tool_input_cache.dart';
import 'package:dash_tools/l10n/l10n.dart';
import 'package:dash_tools/tools/clipboard_service.dart';
import 'package:dash_tools/tools/json_yaml/json_yaml_converter.dart';
import 'package:dash_tools/tools/json_yaml/json_yaml_converter_controller.dart';
import 'package:dash_tools/widgets/copy_button.dart';
import 'package:dash_tools/widgets/tool_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/themes/androidstudio.dart';
import 'package:flutter_highlight/themes/atom-one-light.dart';
import 'package:re_highlight/languages/json.dart';
import 'package:re_highlight/languages/yaml.dart';
import 'package:yaru/widgets.dart';

const _kCacheKey = 'json_yaml_converter';

class JsonYamlConverterScreen extends StatefulWidget {
  const JsonYamlConverterScreen({super.key});

  @override
  State<JsonYamlConverterScreen> createState() => _JsonYamlConverterScreenState();
}

class _JsonYamlConverterScreenState extends State<JsonYamlConverterScreen> {
  final _controller = JsonYamlConverterController();
  late final _inputController = CodeForgeController();
  late final _outputController = CodeForgeController();

  @override
  void initState() {
    super.initState();
    _inputController.addListener(_onInput);
    _controller.addListener(() {
      if (_outputController.text != _controller.output) {
        _outputController.text = _controller.output;
      }
    });
    ToolInputCache.load(_kCacheKey).then((v) {
      if (mounted && v != null && v.isNotEmpty) _inputController.text = v;
    });
  }

  void _onInput() {
    _controller.setInput(_inputController.text);
    ToolInputCache.save(_kCacheKey, _inputController.text);
  }

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Map<String, TextStyle> get _theme => switch (Theme.of(context).brightness) {
        Brightness.light => atomOneLightTheme,
        Brightness.dark => androidstudioTheme,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ToolScaffold(
      onRun: _controller.run,
      onFileDropped: (text) => _inputController.text = text,
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
        builder: (context, _) => Column(
          children: [
            Expanded(
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(context).colorScheme.outline),
                ),
                child: CodeForge(
                  editorTheme: _theme,
                  language: _controller.mode == JsonYamlMode.jsonToYaml ? langJson : langYaml,
                  controller: _inputController,
                  lineWrap: false,
                  enableGutter: true,
                  enableFolding: true,
                  finderBuilder: (context, controller) => CodeFindPanelView(controller: controller),
                ),
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
      output: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) => Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
          child: CodeForge(
            editorTheme: _theme,
            language: _controller.mode == JsonYamlMode.jsonToYaml ? langYaml : langJson,
            controller: _outputController,
            readOnly: true,
            lineWrap: false,
            enableGutter: true,
            enableFolding: true,
            finderBuilder: (context, controller) => CodeFindPanelView(controller: controller),
          ),
        ),
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
