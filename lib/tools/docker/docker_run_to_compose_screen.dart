import 'package:dash_tools/common/tool_input_cache.dart';
import 'package:dash_tools/l10n/l10n.dart';
import 'package:dash_tools/tools/clipboard_service.dart';
import 'package:dash_tools/tools/docker/docker_run_to_compose.dart';
import 'package:dash_tools/tools/docker/docker_run_to_compose_controller.dart';
import 'package:dash_tools/widgets/copy_button.dart';
import 'package:dash_tools/widgets/tool_scaffold.dart';
import 'package:flutter/material.dart';

const _kCacheKey = 'docker_run_compose';

class DockerRunToComposeScreen extends StatefulWidget {
  const DockerRunToComposeScreen({super.key});

  @override
  State<DockerRunToComposeScreen> createState() => _DockerRunToComposeScreenState();
}

class _DockerRunToComposeScreenState extends State<DockerRunToComposeScreen> {
  final _controller = DockerRunToComposeController();
  final _inputTec = TextEditingController();
  final _outputTec = TextEditingController();

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
        TextButton.icon(
          icon: const Icon(Icons.auto_awesome_outlined, size: 16),
          label: const Text('Sample'),
          onPressed: () => _inputTec.text = dockerRunSample.trim(),
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
        builder: (_, _) => TextField(
          controller: _inputTec,
          textAlignVertical: TextAlignVertical.top,
          style: const TextStyle(fontFamily: 'monospace'),
          decoration: InputDecoration(
            labelText: 'docker run command',
            alignLabelWithHint: true,
            errorText: _controller.error.isEmpty ? null : _controller.error,
          ),
          expands: true,
          maxLines: null,
          minLines: null,
        ),
      ),
      output: TextField(
        controller: _outputTec,
        readOnly: true,
        textAlignVertical: TextAlignVertical.top,
        style: const TextStyle(fontFamily: 'monospace'),
        decoration: InputDecoration(labelText: l10n.output, alignLabelWithHint: true),
        expands: true,
        maxLines: null,
        minLines: null,
      ),
    );
  }
}
