import 'package:code_forge/code_forge.dart';
import 'package:dash_tools/common/code_field.dart';
import 'package:dash_tools/common/tool_input_cache.dart';
import 'package:dash_tools/tools/clipboard_service.dart';
import 'package:dash_tools/tools/docker/docker_run_to_compose.dart';
import 'package:dash_tools/tools/docker/docker_run_to_compose_controller.dart';
import 'package:dash_tools/widgets/copy_button.dart';
import 'package:dash_tools/widgets/tool_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/themes/androidstudio.dart';
import 'package:flutter_highlight/themes/atom-one-light.dart';
import 'package:re_highlight/languages/bash.dart';
import 'package:re_highlight/languages/yaml.dart';

const _kCacheKey = 'docker_run_compose';

class DockerRunToComposeScreen extends StatefulWidget {
  const DockerRunToComposeScreen({super.key});

  @override
  State<DockerRunToComposeScreen> createState() => _DockerRunToComposeScreenState();
}

class _DockerRunToComposeScreenState extends State<DockerRunToComposeScreen> {
  final _controller = DockerRunToComposeController();
  final _inputController = CodeForgeController();
  final _outputController = CodeForgeController();

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
    return ToolScaffold(
      onRun: _controller.run,
      actions: [
        TextButton.icon(
          icon: const Icon(Icons.auto_awesome_outlined, size: 16),
          label: const Text('Sample'),
          onPressed: () => _inputController.text = dockerRunSample.trim(),
        ),
      ],
      outputActions: [
        ListenableBuilder(
          listenable: _controller,
          builder: (_, _) => CopyButton(copyCallback: () => pasteContentToClipboard(_controller.output)),
        ),
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
                  language: langBash,
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
      output: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
        child: CodeForge(
          editorTheme: _theme,
          language: langYaml,
          controller: _outputController,
          readOnly: true,
          lineWrap: false,
          enableGutter: true,
          enableFolding: true,
          finderBuilder: (context, controller) => CodeFindPanelView(controller: controller),
        ),
      ),
    );
  }
}
