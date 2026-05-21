import 'package:dash_tools/common/tool_input_cache.dart';
import 'package:dash_tools/l10n/l10n.dart';
import 'package:dash_tools/tools/clipboard_service.dart';
import 'package:dash_tools/tools/hash_generator/hash_generator.dart';
import 'package:dash_tools/tools/hash_generator/hash_generator_controller.dart';
import 'package:dash_tools/widgets/copy_button.dart';
import 'package:dash_tools/widgets/tool_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:yaru/widgets.dart';

const _kCacheInput = 'hash_generator_input';
const _kCacheHmac = 'hash_generator_hmac';

class HashGeneratorScreen extends StatefulWidget {
  const HashGeneratorScreen({super.key});

  @override
  State<HashGeneratorScreen> createState() => _HashGeneratorScreenState();
}

class _HashGeneratorScreenState extends State<HashGeneratorScreen> {
  final _controller = HashGeneratorController();
  late final _inputTec = TextEditingController();
  late final _hmacTec = TextEditingController();

  @override
  void initState() {
    super.initState();
    _inputTec.addListener(_onInput);
    _hmacTec.addListener(_onHmac);
    ToolInputCache.load(_kCacheInput).then((v) {
      if (mounted && v != null && v.isNotEmpty) _inputTec.text = v;
    });
    ToolInputCache.load(_kCacheHmac).then((v) {
      if (mounted && v != null && v.isNotEmpty) _hmacTec.text = v;
    });
  }

  void _onInput() {
    _controller.setInput(_inputTec.text);
    ToolInputCache.save(_kCacheInput, _inputTec.text);
  }

  void _onHmac() {
    _controller.setHmacKey(_hmacTec.text);
    ToolInputCache.save(_kCacheHmac, _hmacTec.text);
  }

  @override
  void dispose() {
    _inputTec.dispose();
    _hmacTec.dispose();
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
          builder: (_, _) => YaruPopupMenuButton<HashAlgorithm>(
            child: Text(_controller.algorithm.label),
            itemBuilder: (_) => HashAlgorithm.values
                .map((a) => PopupMenuItem(
                      value: a,
                      onTap: () => _controller.setAlgorithm(a),
                      child: Text(a.label),
                    ))
                .toList(),
          ),
        ),
        const SizedBox.square(dimension: 8),
        SizedBox(
          width: 200,
          child: TextField(
            controller: _hmacTec,
            decoration: const InputDecoration(
              labelText: 'HMAC key (optional)',
              isDense: true,
            ),
          ),
        ),
      ],
      outputActions: [
        CopyButton(copyCallback: () => pasteContentToClipboard(_controller.result.hex)),
      ],
      input: TextField(
        controller: _inputTec,
        textAlignVertical: TextAlignVertical.top,
        decoration: InputDecoration(labelText: l10n.input, alignLabelWithHint: true),
        expands: true,
        maxLines: null,
        minLines: null,
      ),
      output: ListenableBuilder(
        listenable: _controller,
        builder: (_, _) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HashRow(label: 'Hex', value: _controller.result.hex),
              const SizedBox.square(dimension: 8),
              _HashRow(label: 'Base64', value: _controller.result.base64),
            ],
          ),
        ),
      ),
    );
  }
}

class _HashRow extends StatelessWidget {
  final String label;
  final String value;
  const _HashRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: TextEditingController(text: value),
            readOnly: true,
            style: const TextStyle(fontFamily: 'monospace'),
            decoration: InputDecoration(labelText: label),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: CopyButton(
            showText: false,
            copyCallback: () => pasteContentToClipboard(value),
          ),
        ),
      ],
    );
  }
}
